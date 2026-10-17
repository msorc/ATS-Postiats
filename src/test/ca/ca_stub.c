/* C parts of the emit test (shared by the ATS1 and the ATS2 drivers): strings and doubles that the common subset cannot write, CAEXIT */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char ca_chr (int i) { return (char)i ; }

/* the strings of the cases: k = 0: every byte 1..255 */
static char ca_all[256] ;
char *ca_str (int k) {
  int i ;
  switch (k) {
  case 0: for (i = 1; i < 256; i++) ca_all[i-1] = (char)i ; ca_all[255] = 0 ; return ca_all ;
  case 1: return "hello" ;
  case 2: return "q\"uote\\back'tick\nnl\ttab" ;
  case 3: return "" ;
  case 4: return "foo_bar" ;
  case 5: return "a$b" ;
  case 6: return "x-y.z/w+*" ;
  case 7: return "\200\377\351" ;
  case 8: return "digits123" ;
  case 9: return " sp ace" ;
  case 10: return "Z\001\037\177" ;
  case 11: return "\303\274n\303\257" ;
  case 12: return "'" ;
  case 13: return "\"" ;
  case 14: return "\\" ;
  case 15: return "int" ;
  case 16: return "~!@#%^&()=[]{};:,<>?|`" ;
  case 17: return "a\rb\fc\vd\be\a" ;
  case 18: return "tab\there\n" ;
  case 19: return "name with space and ($) and 'q'" ;
  /* the full names of the files of the cases */
  case 20: return "/home/user/src/foo.dats" ;
  case 21: return "foo-bar.sats" ;
  case 22: return "./rel/path.hats" ;
  case 23: return "a b/c$d.dats" ;
  case 24: return "x.dats" ;
  case 25: return "/tmp/\303\251t\303\251/y_z.sats" ;
  case 26: return "../up/Z9.dats" ;
  case 27: return "" ;
  default: return "other" ;
  }
}

double ca_dbl (int k) {
  switch (k) {
  case 0: return 0.0 ;
  case 1: return 1.5 ;
  case 2: return -2.25 ;
  case 3: return 0.1 ;
  case 4: return 1e300 ;
  case 5: return 1e-300 ;
  case 6: return 123456789.123456789 ;
  case 7: return 0.0 / 0.0 ;
  case 8: return 1.0 / 0.0 ;
  case 9: return -1.0 / 0.0 ;
  case 10: return -0.0 ;
  case 11: return 3.141592653589793 ;
  case 12: return 1e18 ;
  case 13: return 5e-324 ;
  case 14: return 100.0 ;
  default: return 0.5 ;
  }
}

/* CAEXIT=k: run the case k of ca_exit.hats (the process ends) instead of the scenarios */
int ca_getexit (void) { char *s = getenv ("CAEXIT") ; return s ? atoi (s) : 0 ; }
