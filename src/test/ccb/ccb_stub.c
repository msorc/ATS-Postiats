/* C parts of the test of ccomp group B (shared by the ATS1 and the ATS2 drivers) */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

/* the doubles of the file environments: the cells of [filenv_getref_d3eclistopt/tmpcstimpmap/tmpvardecmap]; the filenv is the integer k cast to a pointer */
static void *hd_cells[16][3] ;
void *hd_fenv_cell (void *fenv, int k) { return &hd_cells[((long)fenv) & 15][k] ; }

/* the double of the_d2varlev (pats_trans2_env.dats) */
static int the_d2varlev = 0 ;
int ccb_d2varlev_get (void) { return the_d2varlev ; }
void ccb_d2varlev_set (int n) { the_d2varlev = n ; }

/* emit_ident of pats_ccomp_emit.dats: the characters that are not alphanumeric or '_' are escaped */
void ccb_c_emit_ident (void *out0, void *name0) {
  FILE *out = (FILE*)out0 ; const char *name = (const char*)name0 ;
  for ( ; *name ; name++) {
    int c = (unsigned char)*name ;
    if (isalnum (c)) fputc (c, out) ;
    else if (c == '_') fputc ('_', out) ;
    else if (c == '$') fputs ("__", out) ;
    else fprintf (out, "_%.3o_", (unsigned int)c) ;
  }
}

/* HDEXIT-like switch is not needed here */

/* ---------------------------------------------------------------------------------------------------------------------------------------------------
   the double of the environment of pats_ccomp_ccompenv.dats (the part that the modules of group B use): the state is kept here (values are void*),
   ccb_mock.hats (the same text for ATS1 and ATS2) implements the functions of pats_ccomp.sats with these.
   The structure of ATS1 (a list of marks and entries, with the maps d2var -> stack of primvals) is kept: ccompenv_push/pop/localjoin as in ATS1. */
enum { K_MARK, K_VAR, K_FUNDEC, K_FUNDEC2, K_IMPDEC, K_IMPDEC2, K_STALOAD, K_TMPSUB, K_TMPCSTMAT, K_TMPVARMAT, K_TEMPENVER } ;
typedef struct ent { int kind ; void *a ; struct ent *next ; } ent ;
typedef struct kv { void *k ; void *v ; struct kv *next ; } kv ;
typedef struct lst { void *x ; struct lst *next ; } lst ;
typedef struct stk { void *x ; struct stk *next ; } stk ;     /* a stack of pointers (the lists/sets that the stacks hold) */
typedef struct env {
  int tmplevel, tmprecdepth ;
  ent *marks ;
  kv *vball ;                 /* the maps of vbindmapall: d2var -> stack of values (newest first) */
  stk *vbenv ;                /* a stack of kv* (the top map first) */
  stk *freecon ;              /* a stack of lst* */
  stk *dvarset ;              /* a stack of d2envset_vt (ATS values) */
  stk *flabset ;              /* a stack of funlabset_vt (ATS values) */
} env ;

void *ccb_env_make (void) { env *e = (env*)calloc (1, sizeof (env)) ; return e ; }

int ccb_env_tmprecdepth_get (void *e0) { return ((env*)e0)->tmprecdepth ; }
void ccb_env_tmprecdepth_set (void *e0, int n) { ((env*)e0)->tmprecdepth = n ; }
int ccb_env_tmplevel_get (void *e0) { return ((env*)e0)->tmplevel ; }
void ccb_env_tmplevel_set (void *e0, int n) { ((env*)e0)->tmplevel = n ; }

/* the stacks */
static void *stk_push (stk **s, void *x) { stk *c = (stk*)malloc (sizeof (stk)) ; c->x = x ; c->next = *s ; *s = c ; return x ; }
static void *stk_pop (stk **s) { stk *c = *s ; void *x = c->x ; *s = c->next ; free (c) ; return x ; }
static void *stk_top (stk *s) { return s->x ; }
static void stk_settop (stk *s, void *x) { s->x = x ; }

void ccb_freecon_push (void *e0) { stk_push (&((env*)e0)->freecon, 0) ; }
void *ccb_freecon_pop (void *e0) { return stk_pop (&((env*)e0)->freecon) ; }
void ccb_freecon_add (void *e0, void *pmv) {
  env *e = (env*)e0 ; lst *c = (lst*)malloc (sizeof (lst)) ;
  c->x = pmv ; c->next = (lst*)stk_top (e->freecon) ; stk_settop (e->freecon, c) ;
}
void *ccb_lst_x (void *l) { return ((lst*)l)->x ; }
void *ccb_lst_next (void *l) { return ((lst*)l)->next ; }
void ccb_lst_free (void *l) { while (l) { lst *c = (lst*)l ; l = c->next ; free (c) ; } }

void ccb_dvarset_push (void *e0, void *set) { stk_push (&((env*)e0)->dvarset, set) ; }
void *ccb_dvarset_pop (void *e0) { return stk_pop (&((env*)e0)->dvarset) ; }
int ccb_dvarset_nonempty (void *e0) { return ((env*)e0)->dvarset != 0 ; }
void *ccb_dvarset_top (void *e0) { return stk_top (((env*)e0)->dvarset) ; }
void ccb_dvarset_settop (void *e0, void *set) { stk_settop (((env*)e0)->dvarset, set) ; }
void ccb_flabset_push (void *e0, void *set) { stk_push (&((env*)e0)->flabset, set) ; }
void *ccb_flabset_pop (void *e0) { return stk_pop (&((env*)e0)->flabset) ; }
int ccb_flabset_nonempty (void *e0) { return ((env*)e0)->flabset != 0 ; }
void *ccb_flabset_top (void *e0) { return stk_top (((env*)e0)->flabset) ; }
void ccb_flabset_settop (void *e0, void *set) { stk_settop (((env*)e0)->flabset, set) ; }
void ccb_vbenv_push (void *e0) { stk_push (&((env*)e0)->vbenv, 0) ; }

/* the maps */
static void kv_insert (kv **m, void *k, void *v) { kv *c = (kv*)malloc (sizeof (kv)) ; c->k = k ; c->v = v ; c->next = *m ; *m = c ; }
static kv *kv_find (kv *m, void *k) { for ( ; m ; m = m->next) if (m->k == k) return m ; return 0 ; }
static void kv_remove (kv **m, void *k) {
  for ( ; *m ; m = &(*m)->next) if ((*m)->k == k) { kv *c = *m ; *m = c->next ; free (c) ; return ; }
}
void ccb_vbenv_add (void *e0, void *d2v, void *pmv) {
  env *e = (env*)e0 ; kv *m = (kv*)stk_top (e->vbenv) ;
  kv *c = kv_find (m, d2v) ;
  if (c) c->v = pmv ; else { kv_insert (&m, d2v, pmv) ; stk_settop (e->vbenv, m) ; }
}
void *ccb_vbenv_find (void *e0, void *d2v, void *found0) {
  int *found = (int*)found0 ; env *e = (env*)e0 ; kv *c = kv_find ((kv*)stk_top (e->vbenv), d2v) ;
  *found = c != 0 ; return c ? c->v : 0 ;
}
void ccb_vball_add (void *e0, void *d2v, void *pmv) { env *e = (env*)e0 ; ent *c = (ent*)malloc (sizeof (ent)) ; kv_insert (&e->vball, d2v, pmv) ; c->kind = K_VAR ; c->a = d2v ; c->next = e->marks ; e->marks = c ; }
void *ccb_vball_find (void *e0, void *d2v, void *found0) {
  int *found = (int*)found0 ; env *e = (env*)e0 ; kv *c = kv_find (e->vball, d2v) ;
  *found = c != 0 ; return c ? c->v : 0 ;
}

/* the entries of markenvlst */
void ccb_mark_add (void *e0, int kind, void *a) { env *e = (env*)e0 ; ent *c = (ent*)malloc (sizeof (ent)) ; c->kind = kind ; c->a = a ; c->next = e->marks ; e->marks = c ; }
void ccb_mark_push (void *e0) { ccb_mark_add (e0, K_MARK, 0) ; }
void ccb_mark_pop (void *e0) {
  env *e = (env*)e0 ;
  while (e->marks) {
    ent *c = e->marks ; e->marks = c->next ;
    if (c->kind == K_VAR) kv_remove (&e->vball, c->a) ;
    if (c->kind == K_MARK) { free (c) ; break ; }
    free (c) ;
  }
}
/* auxjoin2 / auxpop2 of ATS1 */
static void auxpop2 (ent **xs) {
  while (*xs) {
    ent *c = *xs ;
    if (c->kind == K_MARK) { *xs = c->next ; free (c) ; return ; }
    if (c->kind == K_VAR || c->kind == K_FUNDEC || c->kind == K_FUNDEC2) { xs = &c->next ; continue ; }
    *xs = c->next ; free (c) ;
  }
}
static void auxjoin2 (ent **xs) {
  while (*xs) {
    ent *c = *xs ;
    if (c->kind == K_MARK) { *xs = c->next ; free (c) ; auxpop2 (xs) ; return ; }
    xs = &c->next ;
  }
}
void ccb_mark_join (void *e0) { auxjoin2 (&((env*)e0)->marks) ; }

/* ccompenv_free: the cells of the environment (the values that the stacks and the maps hold belong to the ATS side) */
static void stk_free (stk *s) { while (s) { stk *c = s ; s = c->next ; free (c) ; } }
static void kv_free (kv *m) { while (m) { kv *c = m ; m = c->next ; free (c) ; } }
void ccb_env_free (void *e0) {
  env *e = (env*)e0 ; stk *s ;
  while (e->marks) { ent *c = e->marks ; e->marks = c->next ; free (c) ; }
  kv_free (e->vball) ;
  for (s = e->vbenv ; s ; s = s->next) kv_free ((kv*)s->x) ;
  for (s = e->freecon ; s ; s = s->next) ccb_lst_free (s->x) ;
  stk_free (e->vbenv) ; stk_free (e->freecon) ; stk_free (e->dvarset) ; stk_free (e->flabset) ;
  free (e) ;
}

/* the search of ccompenv_tmpcst_match / ccompenv_tmpvar_match: the entries from the newest; the matching is done by ATS (ccb_mock.hats) */
void *ccb_marks (void *e0) { return ((env*)e0)->marks ; }
void *ccb_ent_next (void *c) { return ((ent*)c)->next ; }
int ccb_ent_kind (void *c) { return ((ent*)c)->kind ; }
void *ccb_ent_a (void *c) { return ((ent*)c)->a ; }

/* the flag of ccompenv_add_tempenver / ccompenv_get2_tempenver */
static int the_tflag = 0 ;
int ccb_tflag_get (void) { return the_tflag ; }
void ccb_tflag_set (int n) { the_tflag = n ; }

/* the global lists of pats_ccomp_ccompenv.dats (the_funlablst, the_exndeclst, ..): add pushes, take returns the elements in the order of the additions (a new list,
   which the caller frees with ccb_lst_free) and empties the list;
   kinds 6 (dyncon) and 7 (dyncst) do not add an element twice */
#define NGL 9
static lst *gl_lists[NGL] ;
void ccb_gl_add (int kind, void *x) {
  lst *c ;
  if (kind == 6 || kind == 7) for (c = gl_lists[kind] ; c ; c = c->next) if (c->x == x) return ;
  c = (lst*)malloc (sizeof (lst)) ; c->x = x ; c->next = gl_lists[kind] ; gl_lists[kind] = c ;
}
void *ccb_gl_take (int kind) {
  lst *res = 0, *c = gl_lists[kind] ;
  for ( ; c ; c = c->next) { lst *d = (lst*)malloc (sizeof (lst)) ; d->x = c->x ; d->next = res ; res = d ; }
  ccb_lst_free (gl_lists[kind]) ; gl_lists[kind] = 0 ;
  return res ;
}
/* the toplevel cells of the_toplevel_getref_tmpvarlst / primdeclst */
static void *the_tmpvarlst_cell = 0, *the_primdeclst_cell = 0 ;
void *ccb_toplevel_tmpvarlst_ref (void) { return &the_tmpvarlst_cell ; }
void *ccb_toplevel_primdeclst_ref (void) { return &the_primdeclst_cell ; }
