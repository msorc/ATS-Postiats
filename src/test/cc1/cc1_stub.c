/* C parts of the C1 test (shared by the ATS1 and the ATS2 drivers) */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* the doubles of the file environments: the cells [filenv_getref_tmpcstimpmap/tmpvardecmap]; the filenv is the integer k cast to a pointer */
static void *cc1_cells[64][3] ;
void *cc1_fenv_cell (void *fenv, int k) { return &cc1_cells[((long)fenv) & 63][k] ; }

/* the level that [the_d2varlev_get] returns (trans2_env double) */
static int cc1_lev = 0 ;
int cc1_getlev (void) { return cc1_lev ; }
void cc1_setlev (int k) { cc1_lev = k ; }

/* CC1_ONLY=k (1-based): run only the k-th scenario; 0: all of them */
int cc1_getonly (void) { char *s = getenv ("CC1_ONLY") ; return s ? atoi (s) : 0 ; }

/* a table of pointers that the doubles of hidexp_ccomp read (the d2vars of the scenario) */
static void *cc1_tbl[16] ;
void cc1_tbl_set (int k, void *p) { cc1_tbl[k & 15] = p ; }
void *cc1_tbl_get (int k) { return cc1_tbl[k & 15] ; }

/* a string "what:a:b:c" (never freed, but kept reachable in a table: no report of the leak sanitizer) */
static char **cc1_strs = 0 ; static int cc1_nstrs = 0, cc1_cap = 0 ;
char *cc1_str4 (const char *what, int a, int b, int c) {
  char *p = (char*) malloc (strlen (what) + 64) ;
  sprintf (p, "%s:%d:%d:%d", what, a, b, c) ;
  if (cc1_nstrs >= cc1_cap) { cc1_cap = cc1_cap ? 2*cc1_cap : 1024 ; cc1_strs = (char**) realloc (cc1_strs, cc1_cap * sizeof (char*)) ; }
  cc1_strs[cc1_nstrs++] = p ;
  return p ;
}

/* CC1EXIT=k: run the case k of cc1_exit.hats (the process ends) instead of the scenarios */
int cc1_getexit (void) { char *s = getenv ("CC1EXIT") ; return s ? atoi (s) : 0 ; }
