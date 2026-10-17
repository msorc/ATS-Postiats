/* C parts of the test of pats_hidynexp / pats_typerase (shared by the ATS1 and the ATS2 drivers) */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* the doubles of the file environments: the cells of [filenv_getref_d3eclistopt/tmpcstimpmap/tmpvardecmap]; the filenv is the integer k cast to a pointer */
static void *hd_cells[16][3] ;
void *hd_fenv_cell (void *fenv, int k) { return &hd_cells[((long)fenv) & 15][k] ; }

/* the names of the funlabs of the cases (the funlab is the integer i cast to a pointer) */
static char fl_names[16][24] ;
char *hd_funlab_name (void *fl) {
  long i = (long)fl & 15 ;
  sprintf (fl_names[i], "FL%ld", (long)fl) ;
  return fl_names[i] ;
}
/* the function that pats_histaexp_funlab.dats calls (implemented by pats_ccomp in the compiler) */
char *patsopt_funlab_get_name (void *fl) { return hd_funlab_name (fl) ; }

/* HDEXIT=k: run the case k of hd_exit.hats (the process ends) instead of the scenarios */
int hd_getexit (void) { char *s = getenv ("HDEXIT") ; return s ? atoi (s) : 0 ; }
