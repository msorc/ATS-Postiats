/*
** HX-2026-10: the run-time system of patsopt / libatsopt with the
** messages of the ATS1 run-time (src/ of the ATS1 build), see PORTING.md,
** "Completion of the port". pats_main.dats is compiled with
** -D_ATS_CCOMP_RUNTIME_NONE_ (no run-time is included by the generated C
** code) and this file includes the ATS2 run-time with the three handlers
** renamed; the handlers are defined here instead:
**
**   exit(ATS): uncaught exception: <mangled-file>__<name>(<tag>)
**   exit(ATS): <loc>: match failure.
**   exit(ATS): <loc>: funarg match failure.
**
** (ATS2: "uncaught exception at run-time:\n<file>:<name>(<tag>)",
**  "unmatched value at run-time:\n<loc>"). <mangled-file> is the path of
** the file that declares the exception as the ATS1 compiler mangles it
** ('/' -> "_2", other characters that are not alphanumeric or '_' ->
** "_" followed by two hexadecimal digits).
*/

#include "pats_ccomp_config.h"
#include "pats_ccomp_basics.h"
#include "pats_ccomp_typedefs.h"
#include "pats_ccomp_instrset.h"
#include "pats_ccomp_memalloc.h"
#include "pats_ccomp_memalloca.h"
#include "pats_ccomp_exception.h"

#include "prelude/CATS/basics.cats"
#include "prelude/CATS/integer.cats"
#include "prelude/CATS/pointer.cats"
#include "prelude/CATS/integer_long.cats"
#include "prelude/CATS/integer_size.cats"
#include "prelude/CATS/integer_short.cats"
#include "prelude/CATS/bool.cats"
#include "prelude/CATS/char.cats"
#include "prelude/CATS/float.cats"
#include "prelude/CATS/integer_ptr.cats"
#include "prelude/CATS/integer_fixed.cats"
#include "prelude/CATS/memory.cats"
#include "prelude/CATS/string.cats"
#include "prelude/CATS/strptr.cats"
#include "prelude/CATS/fprintf.cats"
#include "prelude/CATS/filebas.cats"
#include "prelude/CATS/array.cats"
#include "prelude/CATS/arrayptr.cats"
#include "prelude/CATS/matrix.cats"
#include "prelude/CATS/matrixptr.cats"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define atsruntime_handle_unmatchedval atsruntime_handle_unmatchedval_ats2
#define atsruntime_handle_unmatchedarg atsruntime_handle_unmatchedarg_ats2
#define atsruntime_handle_uncaughtexn_rest atsruntime_handle_uncaughtexn_rest_ats2
#define atsruntime_handle_uncaughtexn atsruntime_handle_uncaughtexn_ats2
#include "pats_ccomp_runtime.c"
#include "pats_ccomp_runtime_memalloc.c"
#include "pats_ccomp_runtime2_dats.c"
#undef atsruntime_handle_unmatchedval
#undef atsruntime_handle_unmatchedarg
#undef atsruntime_handle_uncaughtexn_rest
#undef atsruntime_handle_uncaughtexn

void
atsruntime_handle_unmatchedval (char *msg0)
{
  fprintf(stderr, "exit(ATS): %s: match failure.\n", msg0) ; exit(1) ;
}

void
atsruntime_handle_unmatchedarg (char *msg0)
{
  fprintf(stderr, "exit(ATS): %s: funarg match failure.\n", msg0) ; exit(1) ;
}

void
atsruntime_handle_uncaughtexn_rest (atstype_exncon *exn0)
{
  atsruntime_handle_uncaughtexn(exn0) ;
}

void
atsruntime_handle_uncaughtexn (void *arg0)
{
  atstype_exncon *exn0 = (atstype_exncon*)arg0 ;
  const char *msg = exn0->exnmsg ; /* "<file>:<name>" */
  const char *colon = strrchr(msg, ':') ;
  size_t n = colon ? (size_t)(colon - msg) : 0 ;
  size_t i ;
  fprintf(stderr, "exit(ATS): uncaught exception: ") ;
  for (i = 0 ; i < n ; i += 1) {
    unsigned char c = (unsigned char)msg[i] ;
    if (c == '/') fprintf(stderr, "_2") ;
    else if ((c >= '0' && c <= '9') || (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_')
      fputc(c, stderr) ;
    else fprintf(stderr, "_%02x", c) ;
  }
  fprintf(stderr, "__%s(%d)\n", colon ? colon + 1 : msg, exn0->exntag) ;
  exit(1) ;
}

#include "pats_ccomp_runtime_trywith.c"
