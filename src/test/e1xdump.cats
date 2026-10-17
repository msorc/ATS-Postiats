/* shared by e1xdump1.dats (ATS1) and e1xdump.dats (ATS2): the operands and operators of an
   application chain, being resolved by a precedence climbing (see e1xdump.dats) */
#include <stdlib.h>
static void *e1xd_it_e[65536] ;
static int e1xd_it_p[65536] ;
static int e1xd_it_n = 0 ;
static int e1xd_it_cur = 0 ;
static int e1xd_it_push (void *e, int prec) { e1xd_it_e[e1xd_it_n] = e ; e1xd_it_p[e1xd_it_n] = prec ; return e1xd_it_n++ ; }
static int e1xd_it_count (void) { return e1xd_it_n ; }
static void *e1xd_it_gete (int i) { return e1xd_it_e[i] ; }
static int e1xd_it_getp (int i) { return e1xd_it_p[i] ; }
static void e1xd_it_truncate (int n) { e1xd_it_n = n ; }
static int e1xd_it_cur_get (void) { return e1xd_it_cur ; }
static void e1xd_it_cur_set (int i) { e1xd_it_cur = i ; }
/* the precedence of the infix operators (and 100 for the prefix [~]), 0 for the rest */
#include <string.h>
static int e1xd_oprec (const char *s)
{
  if (!strcmp(s, "~")) return -1 ;
  if (!strcmp(s, "*") || !strcmp(s, "/")) return 60 ;
  if (!strcmp(s, "+") || !strcmp(s, "-")) return 50 ;
  if (!strcmp(s, "<<") || !strcmp(s, ">>")) return 45 ;
  if (!strcmp(s, "<") || !strcmp(s, "<=") || !strcmp(s, ">") || !strcmp(s, ">=")) return 40 ;
  if (!strcmp(s, "==") || !strcmp(s, "!=") || !strcmp(s, "<>") || !strcmp(s, "=")) return 40 ;
  if (!strcmp(s, "&&")) return 30 ;
  if (!strcmp(s, "||")) return 20 ;
  return 0 ;
}
#include <stdio.h>
static void e1xd_flush (void) { fflush(stdout) ; }
