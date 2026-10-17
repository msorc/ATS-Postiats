/* the state of the test doubles of the group 4 test (t3g4/g4env.tmpl), shared by ATS1 and ATS2 */
#ifndef G4STATE_H
#define G4STATE_H
extern int g4_getk_c (int i) ;
extern void g4_setk_c (int i, int v) ;
extern void* g4_getp_c (int i) ;
extern void g4_setp_c (int i, void* p) ;
extern int g4_isnull_c (void* p) ;
extern void* g4_fenv_cell_c (int i) ;
extern void g4_fenv_clear_c (void) ;
#endif
