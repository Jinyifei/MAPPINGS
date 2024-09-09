#include "zls.h"


CPUCoords gZLS_GlobalCPUTimer;

CPUCoords gZLS_PrevProgressGlobalCPUTimer;
CPUCoords gZLS_PrevDataGlobalCPUTimer;
CPUCoords gZLS_PrevFrameGlobalCPUTimer;

#ifndef NCPUs
#define NCPUs 1
#endif //

//====================================================================================

int zlst_ClearCPUTimes( CPUCoordPtr ct ){
  int err = noErr;

  ct->cpuusr[0]      = 0;
  ct->cpusys[0]      = 0;
  ct->cputot[0]      = 0;
  ct->realtime[0]    = 0;

  ct->cpuusr[1]      = 0;
  ct->cpusys[1]      = 0;
  ct->cputot[1]      = 0;
  ct->realtime[1]    = 0;

  return(err);
}

int zlst_InitGlobalTiming      ( CPUCoordPtr gctp ){
  int err = noErr;
  struct tms  cb;

  clock_t c =  times(&cb);

  gctp->cpuusr[0]      = cb.tms_utime;
  gctp->cpusys[0]      = cb.tms_stime;
  gctp->cputot[0]      = gctp->cpuusr[0]+gctp->cpusys[0];
  gctp->realtime[0]    = c;

  gctp->cpuusr[1]      = cb.tms_utime;
  gctp->cpusys[1]      = cb.tms_stime;
  gctp->cputot[1]      = gctp->cpuusr[0]+gctp->cpusys[0];
  gctp->realtime[1]    = c;

  zlst_CopyCPUTimes(&gZLS_PrevProgressGlobalCPUTimer, gctp);
  zlst_CopyCPUTimes(&gZLS_PrevDataGlobalCPUTimer    , gctp);
  zlst_CopyCPUTimes(&gZLS_PrevFrameGlobalCPUTimer   , gctp);

  return(err);
}

int zlst_StartCPUTimes( CPUCoordPtr ct ){
  int err = noErr;
  struct tms  cb;

  clock_t c =  times(&cb);

  ct->cpuusr[0]      = cb.tms_utime;
  ct->cpusys[0]      = cb.tms_stime;
  ct->cputot[0]      = ct->cpuusr[0]+ct->cpusys[0];
  ct->realtime[0]    = c;

  ct->cpuusr[1]      = cb.tms_utime;
  ct->cpusys[1]      = cb.tms_stime;
  ct->cputot[1]      = ct->cpuusr[0]+ct->cpusys[0];
  ct->realtime[1]    = c;

  return(err);
}


int zlst_SaveCPUTimes( CPUCoordPtr ct_old, CPUCoordPtr ct){
  int err = noErr;
  struct tms  cb;

  ct_old->cpuusr  [0]    = ct->cpuusr  [0];
  ct_old->cpusys  [0]    = ct->cpusys  [0];
  ct_old->cputot  [0]    = ct->cputot  [0];
  ct_old->realtime[0]    = ct->realtime[0];

  clock_t c =  times(&cb);

  ct_old->cpuusr  [1]    = cb.tms_utime;
  ct_old->cpusys  [1]    = cb.tms_stime;
  ct_old->cputot  [1]    = ct->cpuusr[1]+ct->cpusys[1];
  ct_old->realtime[1]    = c;

  return(err);
}

int zlst_ResumeCPUTimes( CPUCoordPtr ct, CPUCoordPtr ct_old ){
  int err = noErr;
  struct tms  cb;
  clock_t c =  times(&cb);

  Counter delta      = ct_old->cpuusr[1] - ct_old->cpuusr[0];
  ct->cpuusr[0]      = cb.tms_utime - delta;

  delta              = ct_old->cpusys[1] - ct_old->cpusys[0];
  ct->cpusys[0]      = cb.tms_stime - delta;

  delta              = ct_old->cputot[1] - ct_old->cputot[0];
  Counter ttot       = cb.tms_stime + cb.tms_utime;
  ct->cputot[0]      = ttot - delta;

  ct->realtime[0]    = c - (ct_old->realtime[1]-ct_old->realtime[0]);

  return(err);
}

int zlst_EndCPUTimes( CPUCoordPtr ct ){
  int err = noErr;
  struct tms  cb;

  clock_t c       =  times(&cb);

  ct->cpuusr[1]   = cb.tms_utime;
  ct->cpusys[1]   = cb.tms_stime;
  ct->cputot[1]   = ct->cpuusr[1]+ct->cpusys[1];
  ct->realtime[1] = c;

  return(err);
}

int zlst_MarkCPUTimes( CPUCoordPtr ct ){ // like end but for continuing use
  int err = noErr;
  struct tms  cb;

  clock_t c       =  times(&cb);

  ct->cpuusr[1]   = cb.tms_utime;
  ct->cpusys[1]   = cb.tms_stime;
  ct->cputot[1]   = ct->cpuusr[1]+ct->cpusys[1];
  ct->realtime[1] = c;

  return(err);
}

int zlst_CopyCPUTimes( CPUCoordPtr ct_dst, CPUCoordPtr ct_src){
  int err = noErr;

  ct_dst->cpuusr  [0]    = ct_src->cpuusr  [0];
  ct_dst->cpusys  [0]    = ct_src->cpusys  [0];
  ct_dst->cputot  [0]    = ct_src->cputot  [0];
  ct_dst->realtime[0]    = ct_src->realtime[0];

  ct_dst->cpuusr  [1]    = ct_src->cpuusr  [1];
  ct_dst->cpusys  [1]    = ct_src->cpusys  [1];
  ct_dst->cputot  [1]    = ct_src->cputot  [1];
  ct_dst->realtime[1]    = ct_src->realtime[1];

  return(err);
}

int zlst_ElapsedCPUTimes( CPUCoordPtr ct, char * title ){

  int err = noErr;
#ifdef OS_GENERIC
  const double spc = 1.0/((double)CLOCKS_PER_SEC);
#endif //
#ifdef OS_GENERICLINUX
  const double spc = 1.0e4/((double)CLOCKS_PER_SEC);
#endif //
#ifdef OS_CENTOS
  const double spc = 1.0e4/((double)CLOCKS_PER_SEC);
#endif //
#ifdef OS_CYGWIN
  const double spc = 1.0/((double)CLOCKS_PER_SEC);
#endif //
#ifdef OS_MACOSXG4
#ifdef OS_MACOSX104TIMING
  const double spc = 1.0/((double)CLOCKS_PER_SEC);
#else
  const double spc = 1.0e4/((double)CLOCKS_PER_SEC);
#endif //
#endif //
#ifdef OS_MACOSXG5
#ifdef OS_MACOSX104TIMING
  const double spc = 1.0/((double)CLOCKS_PER_SEC);
#else
  const double spc = 1.0e4/((double)CLOCKS_PER_SEC);
#endif //
#endif //
#ifdef OS_MACOSXCORE
#ifdef OS_MACOSX104TIMING
  const double spc = 1.0/((double)CLOCKS_PER_SEC);
#else
  const double spc = 1.0e4/((double)CLOCKS_PER_SEC);
#endif //
#endif //
#ifdef OS_SOLARISSPARC
  const double spc = 1.0e4/((double)CLOCKS_PER_SEC);
#endif //
#ifdef OS_SOLARISAMD64
  const double spc = 1.0e4/((double)CLOCKS_PER_SEC);
#endif //

  double usr, sys, tot, rea, f0, f1, f2;
  double invNcpus = 1.0/(NCPUs); // NCPUs is set in zls_OSdefs.h

  usr = ((double)(ct->cpuusr[1]-ct->cpuusr[0]))*spc*invNcpus;
  sys = ((double)(ct->cpusys[1]-ct->cpusys[0]))*spc*invNcpus;
  tot = ((double)(ct->cputot[1]-ct->cputot[0]))*spc*invNcpus;
  rea = ((double)(ct->realtime[1]-ct->realtime[0]))*spc;
  f0 = (usr/rea); f1 =  (sys/rea);  f2 =  (tot/rea);

  printf( "\n Timing for %s.\n", title);
  printf( "%s\n", DIVIDERLINE );
  printf( " ZLS /CPU: %8.4fu %8.4fs %8.4ft %8.4fw\n", usr, sys, tot, rea);
  printf( "    Loads: %6.2f%s %6.2f%s %6.2f%s %6.2f%s \n", f0,  "u/w", f1, "s/w", sys/usr, "s/u", f2, "t/w");
  printf( "%s\n", DIVIDERLINE );

  return(err);
}

//====================================================================================
