/* shared by pardump1.dats (ATS1) and pardump.dats (ATS2): the fragments of a
   file, one "KIND<TAB>text" per line */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static char *pardump_buf = 0 ;
static char *pardump_cur = 0 ;
static void pardump_load (const char *path)
{
  FILE *fp = fopen(path, "r") ; size_t n = 0, cap = 1024 ; int c ;
  if (!fp) { perror(path) ; exit(1) ; }
  pardump_buf = (char*)malloc(cap) ;
  while ((c = fgetc(fp)) != EOF) {
    if (n+2 > cap) { cap *= 2 ; pardump_buf = (char*)realloc(pardump_buf, cap) ; }
    pardump_buf[n++] = (char)c ;
  }
  pardump_buf[n] = 0 ; fclose(fp) ; pardump_cur = pardump_buf ;
}
/* the next line (without its newline), or null */
static void *pardump_nextline (void)
{
  char *p, *q ;
  if (!pardump_cur || !*pardump_cur) return 0 ;
  p = pardump_cur ; q = strchr(p, '\n') ;
  if (q) { *q = 0 ; pardump_cur = q+1 ; } else pardump_cur = p + strlen(p) ;
  return p ;
}
/* cuts "KIND<TAB>text" at the tab: returns text, [line] is KIND */
static char *pardump_split (char *line)
{
  char *q = strchr(line, '\t'), *p ;
  if (!q) return line + strlen(line) ;
  *q = 0 ;
  for (p = q+1 ; *p ; p++) if (*p == '\1') *p = '\n' ; /* \1 stands for a newline in a text */
  return q+1 ;
}
/* the whole contents of a file ("" if it cannot be read) */
static char *pardump_rfbuf = 0 ; /* freed by the next call */
static char *pardump_readfile (const char *path)
{
  FILE *fp = fopen(path, "r") ; size_t n = 0, cap = 4096 ; int c ; char *b ;
  if (pardump_rfbuf) free(pardump_rfbuf) ;
  pardump_rfbuf = b = (char*)malloc(cap) ;
  if (!fp) { b[0] = 0 ; return b ; }
  while ((c = fgetc(fp)) != EOF) {
    if (n+2 > cap) { cap *= 2 ; pardump_rfbuf = b = (char*)realloc(b, cap) ; }
    b[n++] = (char)c ;
  }
  b[n] = 0 ; fclose(fp) ; return b ;
}
/* the i-th space-separated word of s (a fresh copy), or null */
static char *pardump_word (const char *s, int i)
{
  const char *p = s, *q ; char *r ;
  while (1) {
    while (*p == ' ') p++ ;
    if (!*p) return 0 ;
    q = p ; while (*q && *q != ' ') q++ ;
    if (i == 0) { r = (char*)malloc((size_t)(q-p)+1) ; memcpy(r, p, (size_t)(q-p)) ; r[q-p] = 0 ; return r ; }
    i-- ; p = q ;
  }
}
