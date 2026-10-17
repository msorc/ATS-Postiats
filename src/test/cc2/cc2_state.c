/* see cc2_state.h */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cc2_state.h"

typedef struct { int n, cap ; void **a ; } cc2_vec ;
void *cc2_vec_new (void) { cc2_vec *v = calloc (1, sizeof (cc2_vec)) ; return v ; }
void cc2_vec_add (void *v0, void *x) {
  cc2_vec *v = v0 ;
  if (v->n >= v->cap) { v->cap = v->cap ? 2 * v->cap : 8 ; v->a = realloc (v->a, v->cap * sizeof (void*)) ; }
  v->a[v->n++] = x ;
}
int cc2_vec_len (void *v0) { return ((cc2_vec*)v0)->n ; }
void *cc2_vec_get (void *v0, int i) { return ((cc2_vec*)v0)->a[i] ; }
void cc2_vec_free (void *v0) { cc2_vec *v = v0 ; free (v->a) ; free (v) ; }

static int stamps[8] ;
int cc2_stamp_make (int kind) { return stamps[kind & 7]++ ; }

static int lev ;
int cc2_lev_get (void) { return lev ; }
void cc2_lev_inc (void) { lev++ ; }
void cc2_lev_dec (void) { lev-- ; }

/* ---- the bindings: a stack of frames, each a pair of vectors (keys, values) */
#define MAXF 256
typedef struct { cc2_vec *ks, *vs ; } vbframe ;
static vbframe vbs[MAXF] ;
static int nvb ;
void cc2_vb_push (void) { vbs[nvb].ks = cc2_vec_new () ; vbs[nvb].vs = cc2_vec_new () ; nvb++ ; }
void cc2_vb_pop (void) { if (nvb > 0) { nvb-- ; cc2_vec_free (vbs[nvb].ks) ; cc2_vec_free (vbs[nvb].vs) ; } }
void cc2_vb_add (void *k, void *v) {
  if (nvb == 0) cc2_vb_push () ;
  cc2_vec_add (vbs[nvb-1].ks, k) ; cc2_vec_add (vbs[nvb-1].vs, v) ;
}
void *cc2_vb_find (void *k) {
  int i, j ;
  for (i = nvb - 1 ; i >= 0 ; i--)
    for (j = vbs[i].ks->n - 1 ; j >= 0 ; j--) if (vbs[i].ks->a[j] == k) return vbs[i].vs->a[j] ;
  return 0 ;
}
/* local ... in ... end: the two scopes (head, body) are replaced by one that holds the bindings of the body and then those of the head (the later ones are found first) */
void cc2_vb_localjoin (void) {
  int j ;
  if (nvb < 2) return ;
  for (j = 0 ; j < vbs[nvb-2].ks->n ; j++) { cc2_vec_add (vbs[nvb-1].ks, vbs[nvb-2].ks->a[j]) ; cc2_vec_add (vbs[nvb-1].vs, vbs[nvb-2].vs->a[j]) ; }
  cc2_vec_free (vbs[nvb-2].ks) ; cc2_vec_free (vbs[nvb-2].vs) ;
  vbs[nvb-2] = vbs[nvb-1] ; nvb-- ;
}

static int tl ;
int cc2_tl_get (void) { return tl ; }
void cc2_tl_inc (void) { tl++ ; }
void cc2_tl_dec (void) { tl-- ; }

/* ---- the tail-call environment */
static cc2_vec *tcs[MAXF] ;
static int ntc ;
void cc2_tc_push (void) { tcs[ntc++] = cc2_vec_new () ; }
void cc2_tc_add (void *fl) { if (ntc == 0) cc2_tc_push () ; cc2_vec_add (tcs[ntc-1], fl) ; }
void cc2_tc_pop (void) { if (ntc > 0) cc2_vec_free (tcs[--ntc]) ; }
int cc2_tc_find (void *fl) {
  int i, j ;
  for (i = ntc - 1 ; i >= 0 ; i--)
    for (j = 0 ; j < tcs[i]->n ; j++) if (tcs[i]->a[j] == fl) return j ;
  return -1 ;
}
typedef struct { void *fl, *d2c, *d2v ; int istmp ; } flreg ;
static flreg fls[4096] ;
static int nfl ;
void cc2_fl_reg (void *fl, void *d2c, void *d2v, int istmp) {
  if (nfl < 4096) { fls[nfl].fl = fl ; fls[nfl].d2c = d2c ; fls[nfl].d2v = d2v ; fls[nfl].istmp = istmp ; nfl++ ; }
}
static flreg *fl_find (void *fl) { int i ; for (i = 0 ; i < nfl ; i++) if (fls[i].fl == fl) return &fls[i] ; return 0 ; }
void *cc2_tc_find_cst (void *d2c, int istmp) {
  int i, j ;
  for (i = ntc - 1 ; i >= 0 ; i--)
    for (j = 0 ; j < tcs[i]->n ; j++) {
      flreg *r = fl_find (tcs[i]->a[j]) ;
      if (r && r->d2c == d2c && r->istmp == istmp) return r->fl ;
    }
  return 0 ;
}
void *cc2_tc_find_var (void *d2v, int istmp, int *ntl) {
  int i, j ;
  for (i = ntc - 1 ; i >= 0 ; i--)
    for (j = 0 ; j < tcs[i]->n ; j++) {
      flreg *r = fl_find (tcs[i]->a[j]) ;
      if (r && r->d2v == d2v && r->istmp == istmp) { *ntl = j ; return r->fl ; }
    }
  return 0 ;
}

/* ---- the sets (kind 0: function labels, 1: environment variables, 2: free constructors): a stack of vectors of the elements in the order of the first insertion */
static cc2_vec *sets[3][MAXF] ;
static int nsets[3] ;
void cc2_set_inc (int k) { sets[k][nsets[k]++] = cc2_vec_new () ; }
void cc2_set_add (int k, void *x) {
  int j ;
  if (nsets[k] == 0) cc2_set_inc (k) ;
  if (k < 2) for (j = 0 ; j < sets[k][nsets[k]-1]->n ; j++) if (sets[k][nsets[k]-1]->a[j] == x) return ;
  cc2_vec_add (sets[k][nsets[k]-1], x) ;
}
void *cc2_set_dec (int k) {
  if (nsets[k] == 0) return cc2_vec_new () ;
  return sets[k][--nsets[k]] ;
}

static void *sizeof_cst ;
void cc2_sizeof_set (void *d2c) { sizeof_cst = d2c ; }
int cc2_sizeof_is (void *d2c) { return sizeof_cst != 0 && sizeof_cst == d2c ; }

/* the names of the function labels: [patsopt_funlab_get_name] (called by pats_histaexp_funlab.dats to print a [hisexp] that holds a function label; the labels of the cases
   of the hd test are small integers cast to pointers) */
typedef struct { void *fl ; char *name ; } flname ;
static flname *fln ;
static int nfln, capfln ;
void cc2_fl_namereg (void *fl, char *name) {
  if (nfln >= capfln) { capfln = capfln ? 2 * capfln : 1024 ; fln = realloc (fln, capfln * sizeof (flname)) ; }
  fln[nfln].fl = fl ; fln[nfln].name = name ; nfln++ ;
}
char *patsopt_funlab_get_name (void *fl) {
  int i ;
  static char buf[8][32] ;
  static int k ;
  if ((unsigned long)fl < 65536) { char *b = buf[k++ & 7] ; sprintf (b, "FL%ld", (long)fl) ; return b ; }
  for (i = nfln - 1 ; i >= 0 ; i--) if (fln[i].fl == fl) return fln[i].name ;
  return "?" ;
}

char *cc2_fl_name (int stamp) {
  char *s = malloc (24) ;
  sprintf (s, "_cc2_fl_%d", stamp) ;
  return s ;
}

/* the cells of the file environments (filenv is the integer k cast to a pointer): the double of [filenv_getref_*] of the hd test */
static void *hd_cells[16][3] ;
void *hd_fenv_cell (void *fenv, int k) { return &hd_cells[((long)fenv) & 15][k] ; }

void cc2_reset (void) {
  while (nvb > 0) cc2_vb_pop () ;
  while (ntc > 0) cc2_tc_pop () ;
  { int k ; for (k = 0 ; k < 3 ; k++) while (nsets[k] > 0) cc2_vec_free (sets[k][--nsets[k]]) ; }
  tl = 0 ; lev = 0 ; sizeof_cst = 0 ;
}

/* CC2EXIT=k: run the case k of cc2_exit.hats (the process ends) instead of the scenarios */
int cc2_getexit (void) { char *s = getenv ("CC2EXIT") ; return s ? atoi (s) : 0 ; }
