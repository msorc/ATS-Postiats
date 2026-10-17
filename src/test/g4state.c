/* the state of the test doubles of the group 4 test (t3g4/g4env.tmpl), shared by ATS1 and ATS2 */
#include "g4state.h"
static int g4_karr[16];
static void* g4_parr[16];
static void* g4_fenv_cell[4];
int g4_getk_c (int i) { return g4_karr[i]; }
void g4_setk_c (int i, int v) { g4_karr[i] = v; return; }
void* g4_getp_c (int i) { return g4_parr[i]; }
void g4_setp_c (int i, void* p) { g4_parr[i] = p; return; }
int g4_isnull_c (void* p) { return (p == 0) ? 1 : 0; }
void* g4_fenv_cell_c (int i) { return &g4_fenv_cell[i]; }
void g4_fenv_clear_c (void) { g4_fenv_cell[0] = 0; return; }
