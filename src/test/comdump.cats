/* shared by comdump1.dats (ATS1) and comdump.dats (ATS2): see tooldump.cats and PORTING.md, section Tools */
#include "tooldump.cats"
/* ------------------------------------------------------------------------------------------------ */
/* the model of the command line loop of pats_main.dats (process_cmdline*): the options are
   interpreted here, the functions of pats_comarg are called through [cm_call] (implemented in ATS) */
extern void *cm_call (int which, void *arg) ;
#define CM_MAX 1024
static int cm_knd[CM_MAX] ;
static char *cm_str[CM_MAX] ;
static int cm_n = 0 ;
static void cm_push (int k, const char *s) { if (cm_n < CM_MAX) { cm_knd[cm_n] = k ; cm_str[cm_n] = strdup(s) ; cm_n++ ; } }
/* the state */
static int cm_waitknd = 0 ; /* 0 none, 1 output, 2 input_sta, 3 input_dyn, 4 inputs_dyn, 5 define, 6 include */
static int cm_ninpfile = 0, cm_depgen = 0, cm_taggen = 0, cm_atsreloc = 0, cm_codegen = 0, cm_jsonize = 0 ;
static int cm_typecheck = 0, cm_cnstrsolve = 0, cm_nerror = 0, cm_dbgline = 0, cm_debug = 0, cm_dbgflag = 0, cm_tlcalopt = 1 ;
static const char *cm_outmode = "w" ;
static const char *cm_outname = 0 ;
static char *cm_probes[CM_MAX] ; static int cm_nprobes = 0 ;
static int cm_stadyn (void) { return cm_waitknd == 2 ? 0 : cm_waitknd == 3 ? 1 : cm_waitknd == 4 ? 2 : -1 ; }
static void cm_define (const char *def)
{
  size_t n = 0 ; char *p ;
  cm_call(5, (void*)def) ;
  while (def[n] && (def[n] == '_' || (def[n] >= '0' && def[n] <= '9') || (def[n] >= 'a' && def[n] <= 'z') || (def[n] >= 'A' && def[n] <= 'Z'))) n++ ;
  p = (char*)malloc(n + 1) ; memcpy(p, def, n) ; p[n] = 0 ;
  if (cm_nprobes < CM_MAX) cm_probes[cm_nprobes++] = p ;
}
static void cm_include (const char *dir) { cm_call(6, (void*)dir) ; }
static void cm_input (const char *given) { printf("INPUT stadyn=%d given=%s\n", cm_stadyn(), given) ; }
static void cm_nil (void) { if (cm_stadyn() >= 0) printf("INPUT stadyn=%d given=__STDIN__\n", cm_stadyn()) ; }
static void cm_run (int i) ;
static void cm_comarg1 (int i, const char *key)
{
  cm_waitknd = 0 ;
  if (!strcmp(key, "-o")) cm_waitknd = 1 ;
  else if (!strcmp(key, "-s")) { cm_ninpfile = 0 ; cm_waitknd = 2 ; }
  else if (!strcmp(key, "-d")) { cm_ninpfile = 0 ; cm_waitknd = 3 ; }
  else if (!strcmp(key, "-dd")) { cm_ninpfile = 0 ; cm_waitknd = 4 ; }
  else if (!strcmp(key, "-cc")) cm_typecheck = 0 ;
  else if (!strcmp(key, "-tc")) cm_typecheck = 1 ;
  else if (!strcmp(key, "-dep")) cm_depgen = 1 ;
  else if (!strcmp(key, "-tag")) cm_taggen = 1 ;
  else if (cm_call(1, (void*)key)) {
    char *def = (char*)cm_call(3, (void*)key) ;
    if (def) cm_define(def) ; else cm_waitknd = 5 ;
  }
  else if (cm_call(2, (void*)key)) {
    char *dir = (char*)cm_call(4, (void*)key) ;
    if (dir) cm_include(dir) ; else cm_waitknd = 6 ;
  }
  else if (!strcmp(key, "-h")) printf("USAGE\n") ;
  else if (!strcmp(key, "-v")) printf("VERSION\n") ;
  else cm_call(7, (void*)key) ;
  cm_run(i + 1) ;
}
static void cm_comarg2 (int i, const char *key)
{
  cm_waitknd = 0 ;
  if (!strcmp(key, "--help")) printf("USAGE\n") ;
  else if (!strcmp(key, "--output")) cm_waitknd = 1 ;
  else if (!strcmp(key, "--output-w")) { cm_outmode = "w" ; cm_waitknd = 1 ; }
  else if (!strcmp(key, "--output-a")) { cm_outmode = "a" ; cm_waitknd = 1 ; }
  else if (!strcmp(key, "--static")) cm_waitknd = 2 ;
  else if (!strcmp(key, "--dynamic")) cm_waitknd = 3 ;
  else if (!strcmp(key, "--dynamics")) cm_waitknd = 4 ;
  else if (!strcmp(key, "--compile")) cm_typecheck = 0 ;
  else if (!strcmp(key, "--typecheck")) cm_typecheck = 1 ;
  else if (!strcmp(key, "--gline")) cm_dbgline = 1 ;
  else if (!strcmp(key, "--debug")) cm_debug = 1 ;
  else if (!strcmp(key, "--debug2")) { cm_debug = 1 ; cm_dbgflag = 1 ; }
  else if (!strcmp(key, "--depgen")) cm_depgen = 1 ;
  else if (!strcmp(key, "--taggen")) cm_taggen = 1 ;
  else if (!strcmp(key, "--atsreloc")) cm_atsreloc = 1 ;
  else if (!strcmp(key, "--codegen-2")) cm_codegen = 2 ;
  else if (!strcmp(key, "--jsonize-2")) cm_jsonize = 2 ;
  else if (!strcmp(key, "--tlcalopt-disable")) cm_tlcalopt = 0 ;
  else if (!strcmp(key, "--constraint-export")) cm_cnstrsolve = 1 ;
  else if (!strcmp(key, "--constraint-ignore")) cm_cnstrsolve = -1 ;
  else if (!strcmp(key, "--version")) printf("VERSION\n") ;
  else cm_call(7, (void*)key) ;
  cm_run(i + 1) ;
}
static int cm_isinpwait (void) { return cm_waitknd >= 2 && cm_waitknd <= 4 ; }
static void cm_run (int i)
{
  int knd ; const char *str ;
  if (i >= cm_n) { if (cm_ninpfile == 0) cm_nil() ; return ; }
  knd = cm_knd[i] ; str = cm_str[i] ;
  if (cm_isinpwait()) {
    if (knd == 1 && cm_ninpfile > 0) { cm_comarg1(i, str) ; return ; }
    if (knd == 2 && cm_ninpfile > 0) { cm_comarg2(i, str) ; return ; }
    if (!strcmp(str, "-")) { cm_ninpfile++ ; cm_nil() ; cm_run(i + 1) ; return ; }
    cm_ninpfile++ ;
    if (cm_stadyn() >= 2) {
      /* -dd: the following arguments that are not options are input files too */
      int j = i ; printf("INPUTS") ;
      while (j < cm_n && cm_knd[j] != 1 && cm_knd[j] != 2) { printf(" %s", cm_str[j]) ; j++ ; }
      printf("\n") ; cm_run(j) ; return ;
    }
    cm_input(str) ; cm_run(i + 1) ; return ;
  }
  if (cm_waitknd == 1) { cm_waitknd = 0 ; cm_outname = str ; printf("OUTPUT %s mode=%s\n", str, cm_outmode) ; cm_run(i + 1) ; return ; }
  if (cm_waitknd == 5) { cm_waitknd = 0 ; cm_define(str) ; cm_run(i + 1) ; return ; }
  if (cm_waitknd == 6) { cm_waitknd = 0 ; cm_include(str) ; cm_run(i + 1) ; return ; }
  if (knd == 1) { cm_comarg1(i, str) ; return ; }
  if (knd == 2) { cm_comarg2(i, str) ; return ; }
  cm_call(7, (void*)str) ; cm_waitknd = 0 ; cm_run(i + 1) ;
}
static void cm_state (void)
{
  printf("STATE waitknd=%d ninpfile=%d typecheck=%d depgen=%d taggen=%d atsreloc=%d codegen=%d jsonize=%d cnstrsolve=%d nerror=%d\n",
    cm_waitknd, cm_ninpfile, cm_typecheck, cm_depgen, cm_taggen, cm_atsreloc, cm_codegen, cm_jsonize, cm_cnstrsolve, cm_nerror) ;
  printf("FLAGS dbgline=%d debug=%d dbgflag=%d tlcalopt=%d outmode=%s outname=%s\n",
    cm_dbgline, cm_debug, cm_dbgflag, cm_tlcalopt, cm_outmode, cm_outname ? cm_outname : "(none)") ;
}
static int cm_nprobes_get (void) { return cm_nprobes ; }
static char *cm_probe_get (int i) { return cm_probes[i] ; }
