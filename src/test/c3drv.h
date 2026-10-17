/* the problem reader of the drivers of the constraint solver (c3dump.dats, c3dump1.dats; see c3_gen.py) */
#ifndef C3DRV_H
#define C3DRV_H
void c3_open (void *path) ;
int c3_line (void) ;      /* 1: a line was read; 0: end of file; the line is split into words */
int c3_more (void) ;      /* 1: there is a word left in the line */
int c3_int (void) ;       /* the next word as an int */
void *c3_str (void) ;     /* the next word (the memory is never freed) */
void c3_put (int t, int i, void *p) ;
void *c3_get (int t, int i) ;
void c3_put_env (void *p) ;
void *c3_get_env (void) ;
int c3_env_isnull (void) ;
int c3_lineno (void) ;
#endif
