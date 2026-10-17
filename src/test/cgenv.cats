/* the environment table of the codegen2/patcst2 tests (see cg_gen.py): prototypes, the definitions are in cgenv_def.cats (included by the drivers) */
#ifndef CGENV_CATS
#define CGENV_CATS
extern void cg_env_clear (void) ;
extern void cg_env_put (int kind, const char *name, void *item) ;
extern void *cg_env_get (int kind, const char *name) ;
extern int cg_getenv_int (void) ;
#endif
