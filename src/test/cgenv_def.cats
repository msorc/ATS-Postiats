/* the definitions of cgenv.cats: a table of (kind, name, item), the latest entry first (the same for the ATS1 and the ATS2 drivers).
   Kinds: 0 the_s2expenv_find, 1 the_d2expenv_find, 2 the_s2expenv_pervasive_find, 3 the universe of the patterns (cg_init_universe).
   cg_env_clear removes the entries of the kinds 0 and 1 (the ones of a scenario). */
#include <stdlib.h>
#include <string.h>
#include "cgenv.cats"
#define CG_ENV_MAX 4096
static struct { int kind; char *name; void *item; } cg_env_tab[CG_ENV_MAX];
static int cg_env_n = 0;
void cg_env_clear (void) {
  int i, j = 0;
  for (i = 0; i < cg_env_n; i++) {
    if (cg_env_tab[i].kind < 2) free (cg_env_tab[i].name);
    else cg_env_tab[j++] = cg_env_tab[i];
  }
  cg_env_n = j;
}
void cg_env_put (int kind, const char *name, void *item) {
  if (cg_env_n >= CG_ENV_MAX) abort ();
  cg_env_tab[cg_env_n].kind = kind;
  cg_env_tab[cg_env_n].name = strdup (name);
  cg_env_tab[cg_env_n].item = item;
  cg_env_n++;
}
void *cg_env_get (int kind, const char *name) {
  int i;
  for (i = cg_env_n - 1; i >= 0; i--)
    if (cg_env_tab[i].kind == kind && strcmp (cg_env_tab[i].name, name) == 0) return cg_env_tab[i].item;
  return 0;
}
/* CG_ERRTEST=n: the driver runs the error test n (an aborting one) instead of the cases */
int cg_getenv_int (void) {
  char *s = getenv ("CG_ERRTEST");
  return s ? atoi (s) : 0;
}
