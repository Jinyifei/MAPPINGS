# MAPPINGS V DoOxygen Help Documentation

## Quick Start Compiling and Running Standard Doxygen Documentation:

		install doxoygen and node on your system (+ node for dot for flow diagrams)
		varies from system to system, from repositories or macports/homebrew on
		macOS>

### Build
		build the current doxygen files:
		> doxygen mappings_docs.config

		open mv_dox_html/index.html in a modern browser than can display svg graphics:

### Access Docs

<a href="mv_Help_html/index.html">Open Doxygen Code Documentation</a>

		or manually:

		> cd mv_help_html
		> open index.html

## Building a single PDF rather than an HTML directory

		install latex with pdflatex capability,
		edit mappings_docs.config to set
		GENERATE_HTML = NO
		and
		GENERATE_LATEX = YES
		and make sure
		USE_PDFLATEX  = YES
		optionally set PAPER_TYPE = LETTER or a4
		> doxygen mappings_docs.config
		> cd mv_dox_latex
		> make
		> cp refman.pdf ../mv_dox.pdf
		>cd ..
		> rm -rf mv_dox_latex
		open mv_dox.pdf

####* note some latex installations can have unicode issues but a 'q' batchmode
will force continuing compile and completion.
