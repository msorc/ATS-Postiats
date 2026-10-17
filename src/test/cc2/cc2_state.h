/* the C part of the test doubles of the ccomp group C2 test (pats_ccomp_{dynexp,decl,claulst}.dats): see cc2_gen.py and ../../PORTING.md, "ccomp group C2".
   The state of the doubles of pats_ccomp_ccompenv (the environment of the compilation), of the instruction sequences, and of the stamps is kept
   here, once for the ATS1 and the ATS2 driver; the values are pointers/integers (the handles of the trees). */
#ifndef CC2_STATE_H
#define CC2_STATE_H
void cc2_reset (void) ;
int cc2_stamp_make (int kind) ;
/* the level of the dynamic variables (trans2_env) */
int cc2_lev_get (void) ;
void cc2_lev_inc (void) ;
void cc2_lev_dec (void) ;
/* growing vectors of handles (instruction sequences) */
void *cc2_vec_new (void) ;
void cc2_vec_add (void *v, void *x) ;
int cc2_vec_len (void *v) ;
void *cc2_vec_get (void *v, int i) ;
void cc2_vec_free (void *v) ;
/* the scoped bindings of the variables */
void cc2_vb_push (void) ;
void cc2_vb_pop (void) ;
void cc2_vb_localjoin (void) ;
void cc2_vb_add (void *key, void *val) ;
void *cc2_vb_find (void *key) ;
/* the level of templates */
int cc2_tl_get (void) ;
void cc2_tl_inc (void) ;
void cc2_tl_dec (void) ;
/* the tail-call environment: frames of function labels */
void cc2_tc_push (void) ;
void cc2_tc_add (void *fl) ;
void cc2_tc_pop (void) ;
int cc2_tc_find (void *fl) ;
void cc2_fl_reg (void *fl, void *d2c, void *d2v, int istmp) ;
void *cc2_tc_find_cst (void *d2c, int istmp) ;
void *cc2_tc_find_var (void *d2v, int istmp, int *ntl) ;
/* the sets of function labels / environment variables of a function (inc / add / getdec) and the free constructors of a clause */
void cc2_set_inc (int kind) ;
void cc2_set_add (int kind, void *x) ;
void *cc2_set_dec (int kind) ;
/* the cells that hold words (funlab: funent) and the designated [sizeof] constant */
void cc2_sizeof_set (void *d2c) ;
int cc2_sizeof_is (void *d2c) ;
void cc2_fl_namereg (void *fl, char *name) ;
char *patsopt_funlab_get_name (void *fl) ;
#endif
