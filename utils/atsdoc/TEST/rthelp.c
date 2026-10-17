#include <stdio.h>
#include <string.h>
#include <stdlib.h>
void *rt_readline (void) {
  char *buf = 0; size_t sz = 0; ssize_t n = getline (&buf, &sz, stdin);
  if (n < 0) return 0;
  if (n > 0 && buf[n-1] == '\n') buf[n-1] = 0;
  return buf;
}
static char *rtdecode (const char *s) {
  char *r = (char*)malloc(strlen(s)+1), *q = r;
  while (*s) { if (s[0]=='\\' && s[1]=='n') { *q++ = '\n'; s += 2; } else if (s[0]=='\\' && s[1]=='t') { *q++ = '\t'; s += 2; } else *q++ = *s++; }
  *q = 0; return r;
}
/* the k-th (0-based) space separated field and what follows */
void *rt_fld (void *s0, int k) {
  const char *p = (const char*)s0; int i;
  for (i = 0; i < k; i++) { while (*p && *p != ' ') p++; if (*p) p++; }
  return rtdecode(p);
}
/* only the k-th field */
void *rt_fld1 (void *s0, int k) {
  const char *p = (const char*)s0; int i; char *r; size_t n;
  for (i = 0; i < k; i++) { while (*p && *p != ' ') p++; if (*p) p++; }
  n = 0; while (p[n] && p[n] != ' ') n++;
  r = (char*)malloc(n+1); memcpy(r, p, n); r[n] = 0; return r;
}
