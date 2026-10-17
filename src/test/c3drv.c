/*
** The problem reader shared by the ATS1 and the ATS2 drivers of the constraint solver (c3dump.dats / c3dump1.dats).
** Input: lines of words; an empty line or a line that starts with '#' is skipped. The registers are tables of pointers
** (one table per type of the values that the drivers build, see c3_gen.py).
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "c3drv.h"

#define MAXLINE 1000000
#define MAXREG 8192
#define NTYPE 32

static FILE *theinp = 0 ;
static char theline[MAXLINE] ;
static int theln = 0 ;
static char *words[MAXLINE/2] ;
static int nwords = 0, iword = 0 ;
static void *regs[NTYPE][MAXREG] ;
static void *theenv = 0 ;

void c3_open (void *path0) {
  char *path = (char*)path0 ;
  theinp = fopen (path, "rb") ;
  if (!theinp) { fprintf (stderr, "c3dump: cannot open %s\n", path) ; exit (1) ; }
}

int c3_line (void) {
  for (;;) {
    char *p ;
    if (!fgets (theline, MAXLINE, theinp)) return 0 ;
    theln++ ;
    if (strlen (theline) >= MAXLINE - 1) { fprintf (stderr, "c3dump: line too long\n") ; exit (1) ; }
    nwords = 0 ; iword = 0 ;
    p = theline ;
    for (;;) {
      while (*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r') p++ ;
      if (!*p) break ;
      words[nwords++] = p ;
      while (*p && !(*p == ' ' || *p == '\t' || *p == '\n' || *p == '\r')) p++ ;
      if (*p) *p++ = 0 ;
    }
    if (nwords == 0 || words[0][0] == '#') continue ;
    return 1 ;
  }
}

int c3_more (void) { return iword < nwords ; }

void *c3_str (void) {
  if (iword >= nwords) { fprintf (stderr, "c3dump: line %d: unexpected end of line\n", theln) ; exit (1) ; }
  return strdup (words[iword++]) ;
}

int c3_int (void) {
  char *s = c3_str () ;
  int r = atoi (s) ;
  free (s) ;
  return r ;
}

void c3_put (int t, int i, void *p) {
  if (t < 0 || t >= NTYPE || i < 0 || i >= MAXREG) { fprintf (stderr, "c3dump: line %d: bad register %d.%d\n", theln, t, i) ; exit (1) ; }
  regs[t][i] = p ;
}
void *c3_get (int t, int i) {
  if (t < 0 || t >= NTYPE || i < 0 || i >= MAXREG) { fprintf (stderr, "c3dump: line %d: bad register %d.%d\n", theln, t, i) ; exit (1) ; }
  return regs[t][i] ;
}
void c3_put_env (void *p) { theenv = p ; }
void *c3_get_env (void) { return theenv ; }
int c3_lineno (void) { return theln ; }
int c3_env_isnull (void) { return theenv == 0 ; }
