/*
 *  $Id: ccl_get.c,v 1.1.1.1 2006/04/24 03:23:09 ralph Exp $
 *
 *  Copyright (C) 2004 Stephen F. Booth
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 */
#include "ccl.h"

#include <stdlib.h> 	/* malloc, free */
#include <stdio.h>	/* fopen, fread, fclose */
#include <string.h>	/* strcmp, strdup */
#include <ctype.h>	/* isspace */
#include <errno.h>	/* ENOMEM, EINVAL, ENOENT */

#ifndef PACKAGE
#define PACKAGE 'ccl'
#endif

#define CCL_BUFSIZE 65536UL
#define CCL_TOKSIZE 256UL

enum {
  CCL_PARSE_INITIAL,
  CCL_PARSE_COMMENT,
  CCL_PARSE_QUOTED,
  CCL_PARSE_UNQUOTED,
  CCL_HANDLE_NEWLINE,
  CCL_HANDLE_SEP
};

const char*
ccl_get(const struct ccl_t *data,
        const char *key)
{
  const struct ccl_pair_t * pair;
  struct ccl_pair_t 		temp;

  if(data == NULL || key == NULL)
    return NULL;

  temp.key   = (char *) key;
  temp.value = NULL;

  pair = (const struct ccl_pair_t *) bst_find(data->table, &temp);

  return pair == NULL ? NULL : pair->value;
}

void
ccl_reset(struct ccl_t *data)
{
  if(data != 0) {
    data->iterating = 0;
  }
}


static void
ccl_bst_item_func(void *bst_item,
                  void *bst_param)
{
#pragma unused(bst_param)
  
  struct ccl_pair_t *pair = (struct ccl_pair_t*) bst_item;
  free(pair->key);
  free(pair->value);
  free(pair);
}

void
ccl_release(struct ccl_t *data)
{
  if(data == NULL)
    return;

  bst_destroy(data->table, ccl_bst_item_func);
}

static int
ccl_bst_comparison_func(const void *bst_a,
                        const void *bst_b,
                        void *bst_param)
{
  const struct ccl_pair_t *a = (const struct ccl_pair_t*) bst_a;
  const struct ccl_pair_t *b = (const struct ccl_pair_t*) bst_b;
  // zlsio_Printf( "ccl_bst_comparison_func  %s %s %s %s \n",a->key,a->value,b->key,b->value);
  return strcmp(a->key, b->key);
}

const struct ccl_pair_t*
ccl_iterate(struct ccl_t *data)
{
  struct ccl_pair_t *pair;

  if(data == NULL)
    return NULL;

  if(data->iterating) {
    pair = bst_t_next(&data->traverser);
  }
  else {
    data->iterating = 1;
    pair = bst_t_first(&data->traverser, data->table);
  }

  return pair;
}

int
ccl_parse(struct ccl_t *data,
          const char *path)
{
  FILE 			*f = NULL;
  char 		    *buf = NULL;
  char 		    *p = NULL;
  char 			*token = NULL;
  char          *t = NULL;
  char          *tok_limit = NULL;
  int 			result, state, got_tok, tok_cap;
  size_t  count, line;
  struct ccl_pair_t 	*pair;


  /* Validate arguments */
  if(data == 0 || path == 0)
    return EINVAL;

  /* Setup local variables */
  result = 0;
  pair = NULL;
  line = 1;

  /* Setup data struct */
  data->table = bst_create(ccl_bst_comparison_func, 0, 0);
  if(data->table == 0) {
    result = ENOMEM;
    goto cleanup;
  }
  bst_t_init(&data->traverser, data->table);
  data->iterating = 0;

  /* Open file */
  f = fopen(path, "r");
  if(f == 0) {
    fprintf( stderr, "CCL: Unable to open '%s'\n", path);
    return ENOENT;
  }

  /* Initialize file and token buffers */
  buf = (char*) malloc(sizeof(char) * CCL_BUFSIZE);
  token = (char*) malloc(sizeof(char) * CCL_TOKSIZE);
  if(buf == 0 || token == 0) {
    result = ENOMEM;
    goto cleanup;
  }

  /* Parse file */
  state = CCL_PARSE_INITIAL;
  got_tok = 0;
  tok_cap = CCL_TOKSIZE;
  tok_limit = token + tok_cap;

  do {

    /* Read a chunk */
    count = fread(buf, sizeof(char), CCL_BUFSIZE, f);

    /* Parse the input - manually increment p since not all
     transitions should automatically consume a character */
    for(p = buf; p < (buf + count); /* ++p */ ) {

      switch(state) {

          /* ==================== Initial parsing state */
        case CCL_PARSE_INITIAL:
          if(*p == data->comment_char) {
            state = CCL_PARSE_COMMENT;
            ++p;
          }
          else if(*p == data->str_char) {
            t = token;
            state = CCL_PARSE_QUOTED;
            ++p;
          }
          else if(*p == '\n') {
            state = CCL_HANDLE_NEWLINE;
          }
          else if(*p == data->sep_char) {
            state = CCL_HANDLE_SEP;
            ++p;
          }
          else if(isspace(*p)) {
            ++p;
          }
          else {
            t = token;

            /* Enlarge buffer, if needed */
            if(t > tok_limit) {
              int count1 = (int) (t - token);
              token = (char*) realloc(token, (size_t)(tok_cap * 2));
              if(token == 0) {
                result = ENOMEM;
                goto cleanup;
              }
              tok_cap *= 2;
              tok_limit = token + tok_cap;
              t = token + count1;
            }

            *t++ = *p++;

            state = CCL_PARSE_UNQUOTED;
          }
          break;

          /* ==================== Parse comments */
        case CCL_PARSE_COMMENT:
          if(*p == '\n') {
            state = CCL_HANDLE_NEWLINE;
          } else {
            ++p;
          }
          break;

          /* ==================== Parse quoted strings */
        case CCL_PARSE_QUOTED:
          if(*p == data->str_char) {
            got_tok = 1;
            *t = '\0';
            state = CCL_PARSE_INITIAL;
            ++p;
          }
          else if(*p == '\n') {
            fprintf( stderr, "CCL: Unterminated string (%s:%d)\n",  path, (int)line);
            state = CCL_HANDLE_NEWLINE;
          }
          else {
            /* Enlarge buffer, if needed */
            if(t > tok_limit) {
              int count2 = (int)(t - token);
              token = (char*) realloc(token, (size_t)(tok_cap * 2));
              if(token == 0) {
                result = ENOMEM;
                goto cleanup;
              }
              tok_cap *= 2;
              tok_limit = token + tok_cap;
              t = token + count2;
            }

            *t++ = *p++;
          }
          break;

          /* ==================== Parse unquoted strings */
        case CCL_PARSE_UNQUOTED:
          if(*p == data->comment_char) {
            if(t != token) {
              got_tok = 1;
              *t = '\0';
            }
            state = CCL_PARSE_COMMENT;
            ++p;
          }
          else if(*p == '\n') {
            if(t != token) {
              got_tok = 1;
              *t = '\0';
            }
            state = CCL_HANDLE_NEWLINE;
          }
          else if(*p == data->sep_char) {
            if(t != token) {
              got_tok = 1;
              *t = '\0';
            }
            state = CCL_HANDLE_SEP;
            ++p;
          }
          /* In this mode a space ends the current token */
          else if(isspace(*p)) {
            if(t != token) {
              got_tok = 1;
              *t = '\0';
            }
            state = CCL_PARSE_INITIAL;
            ++p;
          }
          else {
            /* Enlarge buffer, if needed */
            if(t > tok_limit) {
              int count3 = (int)(t - token);
              token = (char*) realloc(token, (size_t)(tok_cap * 2));
              if(token == NULL) {
                result = ENOMEM;
                goto cleanup;
              }
              tok_cap *= 2;
              tok_limit = token + tok_cap;
              t = token + count3;
            }

            *t++ = *p++;
          }
          break;

          /* ==================== Process separator characters */
        case CCL_HANDLE_SEP:
          if(got_tok == 0) {
            pair = NULL;
            fprintf( stderr, "CCL: Missing key (%s:%d)\n", path, (int)line);
          }
          else if(ccl_get(data, token) != 0) {
            pair = NULL;
            fprintf( stderr, "CCL: Ignoring duplicate key '%s' (%s:%d)\n",
                    token, path, (int)line);
          }
          else {
            pair = (struct ccl_pair_t*) malloc(sizeof(struct ccl_pair_t));
            if(pair == NULL) {
              result = ENOMEM;
              goto cleanup;
            }
            pair->key = strdup(token);
            pair->value = NULL;
            if(pair->key == NULL) {
              result = ENOMEM;
              goto cleanup;
            }
          }
          
          got_tok = 0;
          state = CCL_PARSE_INITIAL;
          break;
          
          /* ==================== Process newlines */
        case CCL_HANDLE_NEWLINE:
          if(pair != NULL) {
            /* Some type of token was parsed */
            if(got_tok == 1) {
              pair->value = strdup(token);
            }
            else {
              /* In this case we read a key but no value */
              pair->value = strdup("");
            }
            if(pair->value == NULL) {
              result = ENOMEM;
              goto cleanup;
            }
            if(bst_probe(data->table, pair) == NULL) {
              result = ENOMEM;
              goto cleanup;
            }
          }
          
          got_tok = 0;
          pair = 0;
          state = CCL_PARSE_INITIAL;
          ++line;
          ++p;
          break;
      }
    }
  } while(feof(f) == 0);
  
cleanup:
  if(pair != 0) {
    free(pair->key);
    free(pair->value);
    free(pair);
  }
  if (buf) free(buf);
  if (token) free(token);
  fclose(f);
  
  return result;
}
