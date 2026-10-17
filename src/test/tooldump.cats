/* shared by tooldump1.dats/comdump1.dats (ATS1) and tooldump.dats/comdump.dats (ATS2): the differential tests of
   pats_comarg, pats_depgen, pats_taggen, pats_jsonize (see PORTING.md, section Tools) */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pardump.cats"
/* defined by pats_utils.dats (the environment variables PATSHOME, PATSCONTRIB, PATSRELOCROOT) */
extern void patsopt_PATSHOME_set() ;
extern void *patsopt_PATSHOME_get() ;
extern void patsopt_PATSCONTRIB_set() ;
extern void patsopt_PATSRELOCROOT_set() ;
static void tooldump_flush (void) { fflush(stdout) ; fflush(stderr) ; }
static void tooldump_exit (int code) { fflush(stdout) ; fflush(stderr) ; exit(code) ; }
static int tooldump_atoi (const char *s) { return atoi(s) ; }
/* strings that live until the next jz_pool_reset */
#define JZ_POOLMAX 100000
static char *jz_pool[JZ_POOLMAX] ;
static int jz_npool = 0 ;
static char *jz_pool_add (char *s)
{
  if (jz_npool >= JZ_POOLMAX) { fprintf(stderr, "jz_pool full\n") ; exit(9) ; }
  jz_pool[jz_npool++] = s ; return s ;
}
static void jz_pool_reset (void)
{
  int i ; for (i = 0 ; i < jz_npool ; i++) free(jz_pool[i]) ; jz_npool = 0 ;
}
/* the text printed into a temporary file */
static void *jz_tmp_begin (void) { FILE *f = tmpfile() ; if (!f) { perror("tmpfile") ; exit(9) ; } return f ; }
static char *jz_tmp_end (void *fp)
{
  FILE *f = (FILE*)fp ; long n ; char *s ;
  fflush(f) ; n = ftell(f) ; rewind(f) ;
  s = (char*)malloc((size_t)n + 1) ;
  if (n > 0 && fread(s, 1, (size_t)n, f) != (size_t)n) { perror("fread") ; exit(9) ; }
  s[n] = 0 ; fclose(f) ; return jz_pool_add(s) ;
}
/* the string of the characters lo..hi */
static char *jz_mkstr (int lo, int hi)
{
  char *s = (char*)malloc((size_t)(hi - lo + 2)) ; int i, n = 0 ;
  for (i = lo ; i <= hi ; i++) s[n++] = (char)i ;
  s[n] = 0 ; return jz_pool_add(s) ;
}
static char *jz_mkstr_cat (const char *a, const char *b)
{
  char *s = (char*)malloc(strlen(a) + strlen(b) + 1) ;
  strcpy(s, a) ; strcat(s, b) ; return jz_pool_add(s) ;
}
static double jz_double (int k)
{
  switch (k) {
  case 0: return 0.0 ; case 1: return 1.5 ; case 2: return -2.25 ; case 3: return 1e10 ;
  case 4: return 3.14159265358979 ; case 5: return 1e-7 ; case 6: return 123456789.123456789 ;
  case 7: return -0.0 ; default: return 1e300 ;
  }
}
/* the -IATS directories of the DEPI kinds are pushed once */
static int tooldump_iats_done = 0 ;
static int tooldump_iats_once (void) { if (tooldump_iats_done) return 0 ; tooldump_iats_done = 1 ; return 1 ; }
static char *tooldump_path (const char *a, const char *b)
{
  char *s = (char*)malloc(strlen(a) + strlen(b) + 1) ; strcpy(s, a) ; strcat(s, b) ; return s ;
}
