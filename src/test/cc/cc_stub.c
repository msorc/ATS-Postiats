/* C parts of the ccomp test (shared by the ATS1 and the ATS2 drivers) */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* the doubles of the file environments (as hd_stub.c) */
static void *hd_cells[16][3] ;
void *hd_fenv_cell (void *fenv, int k) { return &hd_cells[((long)fenv) & 15][k] ; }

/* the function level that the double of [the_d2varlev_get] returns */
static int cc_lev = 0 ;
int cc_lev_get (void) { return cc_lev ; }
void cc_lev_set (int k) { cc_lev = k ; }

/* CCEXIT=k: run the case k of cc_exit.hats (the process ends) instead of the scenarios */
int cc_getexit (void) { char *s = getenv ("CCEXIT") ; return s ? atoi (s) : 0 ; }
