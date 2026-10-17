/* C parts of the test of pats_histaexp (shared by the ATS1 and the ATS2 drivers) */
#include <stdio.h>
#include <string.h>

/* the table of the "pervasive" constants of the stub of pats_stacst2: name -> s2cst */
static const char *tnames[64] ; static void *tvals[64] ; static int tn = 0 ;
void *hs_tbl_find (const char *name) {
  int i ; for (i = 0 ; i < tn ; i++) if (strcmp (tnames[i], name) == 0) return tvals[i] ;
  return 0 ;
}
void hs_tbl_set (const char *name, void *v) { tnames[tn] = name ; tvals[tn] = v ; tn++ ; }

/* the names of the funlabs of the cases (the funlab is the integer i cast to a pointer) */
static char fl_names[16][16] ;
char *hs_funlab_name (void *fl) {
  long i = (long)fl & 15 ;
  sprintf (fl_names[i], "FL%ld", (long)fl) ;
  return fl_names[i] ;
}
/* the function that pats_histaexp_funlab.dats calls (implemented by pats_ccomp in the compiler) */
char *patsopt_funlab_get_name (void *fl) { return hs_funlab_name (fl) ; }
