/* shared by d1dump1.dats (ATS1) and d1dump.dats (ATS2): the whole-file test of the level-1 translation */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pardump.cats"
/* the set of the strings (the full names of the staloaded files) that were dumped */
#define D1DUMP_NSEEN 4096
struct d1dump_seen_node { char *s ; struct d1dump_seen_node *next ; } ;
static struct d1dump_seen_node *d1dump_seen_tbl[D1DUMP_NSEEN] ;
/* returns 1 if [s] was already seen, else registers it and returns 0 */
static int d1dump_seen (const char *s)
{
  unsigned long h = 5381 ; const char *p ; struct d1dump_seen_node *q ;
  for (p = s ; *p ; p++) h = h * 33 + (unsigned char)*p ;
  h %= D1DUMP_NSEEN ;
  for (q = d1dump_seen_tbl[h] ; q ; q = q->next) if (strcmp(q->s, s) == 0) return 1 ;
  q = (struct d1dump_seen_node*)malloc(sizeof(*q)) ;
  q->s = strdup(s) ; q->next = d1dump_seen_tbl[h] ; d1dump_seen_tbl[h] = q ;
  return 0 ;
}
static void d1dump_flush (void) { fflush(stdout) ; fflush(stderr) ; }
static void d1dump_exit (int code) { fflush(stdout) ; fflush(stderr) ; exit(code) ; }
static int d1dump_atoi (const char *s) { return atoi(s) ; }
/* defined by pats_utils.dats (the environment variables PATSHOME, PATSCONTRIB) */
extern void patsopt_PATSHOME_set() ;
extern void *patsopt_PATSHOME_get() ;
extern void patsopt_PATSCONTRIB_set() ;
