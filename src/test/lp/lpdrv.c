/*
** The problem reader shared by the ATS1 and the ATS2 drivers of the linear
** constraint solver (lpdrv1.dats / lpdrv2.dats, see ../Makefile "lp*").
**
** Input: whitespace separated tokens ('#' starts a comment up to the end of
** the line); records
**   P|B <id> <label> N <h> <h indices> <c> <c items>   a problem (B: only solved)
**         item := V knd <N coefficients> | L knd <k> <k items> | E
**   I <a> <b>                                          two integers
** The coefficients are decimal numbers with an optional sign.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAXNODE 400000
#define MAXCOEF 40000000

static char *buf = 0 ;
static size_t len = 0, pos = 0 ;

static int nnode = 0 ;
static int ntype[MAXNODE], nknd[MAXNODE], nch0[MAXNODE], nchn[MAXNODE], ncf0[MAXNODE] ;
static int chlst[MAXNODE] ; static int nchlst = 0 ;
static char *cflst[MAXCOEF] ; static int ncflst = 0 ;
static int vecs[MAXNODE] ; static int nvecs = 0 ;
static int tops[MAXNODE] ; static int ntops = 0 ;
static int hints[MAXNODE] ; static int nhints = 0 ;
static int theN = 0 ;
static char *theid = 0, *thelabel = 0 ;
static char *args[2] ;

void lpdrv_open (char *path) {
  FILE *f = fopen (path, "rb") ;
  if (!f) { fprintf (stderr, "lpdrv: cannot open %s\n", path) ; exit (1) ; }
  fseek (f, 0, SEEK_END) ; len = ftell (f) ; fseek (f, 0, SEEK_SET) ;
  buf = (char*)malloc (len + 1) ;
  if (fread (buf, 1, len, f) != len) { fprintf (stderr, "lpdrv: read error\n") ; exit (1) ; }
  buf[len] = 0 ; fclose (f) ; pos = 0 ;
}

static char *tok () {
  char *r ;
  for (;;) {
    while (pos < len && (buf[pos] == ' ' || buf[pos] == '\n' || buf[pos] == '\t' || buf[pos] == '\r')) pos++ ;
    if (pos < len && buf[pos] == '#') { while (pos < len && buf[pos] != '\n') pos++ ; continue ; }
    break ;
  }
  if (pos >= len) return 0 ;
  r = buf + pos ;
  while (pos < len && !(buf[pos] == ' ' || buf[pos] == '\n' || buf[pos] == '\t' || buf[pos] == '\r')) pos++ ;
  if (pos < len) buf[pos++] = 0 ;
  return r ;
}

static int itok () { char *t = tok () ; if (!t) { fprintf (stderr, "lpdrv: unexpected end\n") ; exit (1) ; } return atoi (t) ; }

static int item () {
  int k = nnode++ ;
  char *t = tok () ;
  int i, m ;
  if (k >= MAXNODE) { fprintf (stderr, "lpdrv: too many nodes\n") ; exit (1) ; }
  if (t[0] == 'V') {
    ntype[k] = 0 ; nknd[k] = itok () ; ncf0[k] = ncflst ;
    for (i = 0 ; i < theN ; i++) cflst[ncflst++] = tok () ;
    vecs[nvecs++] = k ;
  } else if (t[0] == 'L') {
    int *tmp ;
    ntype[k] = 1 ; nknd[k] = itok () ; m = itok () ; nchn[k] = m ;
    tmp = (int*)malloc ((m + 1) * sizeof(int)) ;
    for (i = 0 ; i < m ; i++) tmp[i] = item () ;
    nch0[k] = nchlst ; for (i = 0 ; i < m ; i++) chlst[nchlst++] = tmp[i] ;
    free (tmp) ;
  } else { ntype[k] = 2 ; nknd[k] = 0 ; nchn[k] = 0 ; }
  return k ;
}

// 0: eof, 1: a problem (P), 2: two integers (I), 3: a problem to solve only (B)
int lpdrv_next () {
  char *t = tok () ; int i, c ;
  if (!t) return 0 ;
  nnode = 0 ; nchlst = 0 ; ncflst = 0 ; nvecs = 0 ; ntops = 0 ; nhints = 0 ;
  if (t[0] == 'P' || t[0] == 'B') {
    theid = tok () ; thelabel = tok () ;
    theN = itok () ; nhints = itok () ;
    for (i = 0 ; i < nhints ; i++) hints[i] = itok () ;
    c = itok () ;
    { int *tmp = (int*)malloc ((c + 1) * sizeof(int)) ;
      for (i = 0 ; i < c ; i++) tmp[i] = item () ;
      for (i = 0 ; i < c ; i++) tops[ntops++] = tmp[i] ;
      free (tmp) ; }
    return (t[0] == 'P' ? 1 : 3) ;
  }
  if (t[0] == 'I') { args[0] = tok () ; args[1] = tok () ; return 2 ; }
  fprintf (stderr, "lpdrv: bad record %s\n", t) ; exit (1) ;
}

char *lpdrv_id () { return theid ; }
char *lpdrv_label () { return thelabel ; }
int lpdrv_N () { return theN ; }
int lpdrv_nhint () { return nhints ; }
int lpdrv_hint (int j) { return hints[j] ; }
int lpdrv_ntop () { return ntops ; }
int lpdrv_top (int j) { return tops[j] ; }
int lpdrv_nvec () { return nvecs ; }
int lpdrv_vec (int j) { return vecs[j] ; }
int lpdrv_ntype (int k) { return ntype[k] ; }
int lpdrv_nknd (int k) { return nknd[k] ; }
int lpdrv_nch (int k) { return nchn[k] ; }
int lpdrv_ch (int k, int j) { return chlst[nch0[k] + j] ; }
char *lpdrv_coef (int k, int i) { return cflst[ncf0[k] + i] ; }
char *lpdrv_arg (int j) { return args[j] ; }
int lpdrv_isneg (char *s) { return s[0] == '-' ; }
char *lpdrv_abs (char *s) { return (s[0] == '-' ? s + 1 : s) ; }
