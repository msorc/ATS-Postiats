/*
** HX-2026-10: libatsopt -- the C API of libatsopt of ATS1 (utils/libatsopt/
** DATS/patsopt_ext.dats) over the compiler of src/. PORTING.md, "Completion
** of the port". The functions (all are plain C, no ATS run-time needed):
**
**   void libatsopt_dynloadall(void)            (defined by pats_main.dats, PATSOPT_MAIN_NONE)
**   void libatsopt_patsopt_main(int argc, char **argv)   (ditto: exits / raises on errors)
**   bool libatsopt_patsopt_main_opt(argc, argv)          (libatsopt_ext.dats: catches the exceptions)
**   comarg libatsopt_comarg_{strlit,strinp,prefil,postfil}(const char*)
**   comarglst libatsopt_comarglst_nil() / libatsopt_comarglst_cons(comarg, comarglst)
**   int libatsopt_patsopt_main_arglst(comarglst)         (number of errors)
**   patsoptres libatsopt_patsoptres_main_arglst(comarglst)
**   int/char* libatsopt_patsoptres_get_{nerr,stdout,stderr}(patsoptres)
**
** A comarglst is a list in the order of the arguments: a `strlit` is an
** argument as it is, a `strinp` is a string that is written to a temporary
** file (preceded by every `prefil` and followed by every `postfil` seen so
** far) whose name replaces it. The ATS1 comarg/list are ATS datatypes; here
** they are opaque pointers (allocated with malloc, never freed: the argument
** lists and results of a few calls live as long as the process).
** Differences to ATS1: `patsoptres_main_arglst` restores the descriptors 1
** and 2 (ATS1 closes them) and flushes the C streams before; the captured
** text is read from the beginning of the temporary files.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

typedef struct { int kind; const char *str; } comarg_t ; /* 0 strlit 1 strinp 2 prefil 3 postfil */
typedef struct comarglst { comarg_t *hd; struct comarglst *tl; } comarglst_t ;
typedef struct { int nerr; char *out; char *err; } patsoptres_t ;

extern int libatsopt_patsopt_main_opt (int argc, char **argv) ;

static comarg_t *
mkcomarg (int kind, const char *s)
{
  comarg_t *x = (comarg_t*)malloc(sizeof(comarg_t)) ;
  x->kind = kind ; x->str = s ; return x ;
}
void *libatsopt_comarg_strlit (const char *s) { return mkcomarg(0, s) ; }
void *libatsopt_comarg_strinp (const char *s) { return mkcomarg(1, s) ; }
void *libatsopt_comarg_prefil (const char *s) { return mkcomarg(2, s) ; }
void *libatsopt_comarg_postfil (const char *s) { return mkcomarg(3, s) ; }

void *libatsopt_comarglst_nil (void) { return (void*)0 ; }
void *
libatsopt_comarglst_cons (void *x, void *xs)
{
  comarglst_t *l = (comarglst_t*)malloc(sizeof(comarglst_t)) ;
  l->hd = (comarg_t*)x ; l->tl = (comarglst_t*)xs ; return l ;
}

/* the strings of the pre/post files in order of appearance */
typedef struct { const char **a ; int n ; } strvec_t ;
static void
strvec_add (strvec_t *v, const char *s)
{
  v->a = (const char**)realloc(v->a, (v->n+1)*sizeof(char*)) ;
  v->a[v->n] = s ; v->n += 1 ;
}

static char *
string2file (const char *content, strvec_t *pre, strvec_t *post, int *nerr)
{
  int i ;
  FILE *out ;
  const char *prfx = "libatsopt_string2file_XXXXXX" ;
  char *tmp = (char*)malloc(strlen(prfx)+1) ;
  int fd ;
  strcpy(tmp, prfx) ;
  fd = mkstemp(tmp) ;
  if (fd < 0) { *nerr += 1 ; return tmp ; }
  out = fdopen(fd, "w") ;
  if (!out) { *nerr += 1 ; close(fd) ; return tmp ; }
  for (i = 0 ; i < pre->n ; i += 1)
    if (fputs(pre->a[i], out) < 0) *nerr += 1 ;
  if (fputs(content, out) < 0) *nerr += 1 ;
  for (i = 0 ; i < post->n ; i += 1)
    if (fputs(post->a[i], out) < 0) *nerr += 1 ;
  if (fflush(out) != 0) *nerr += 1 ;
  if (fclose(out) != 0) *nerr += 1 ;
  return tmp ;
}

int
libatsopt_patsopt_main_arglst (void *args)
{
  comarglst_t *xs ;
  int argc = 1, nerr = 0, ntmp = 0, i ;
  char **argv ;
  char **tmps ;
  strvec_t pre = { 0, 0 }, post = { 0, 0 } ;
  for (xs = (comarglst_t*)args ; xs ; xs = xs->tl) argc += 1 ;
  argv = (char**)malloc((argc+1)*sizeof(char*)) ;
  tmps = (char**)malloc((argc+1)*sizeof(char*)) ;
  argc = 0 ;
  argv[argc++] = (char*)"patsopt" ;
  for (xs = (comarglst_t*)args ; xs ; xs = xs->tl) {
    comarg_t *x = xs->hd ;
    switch (x->kind) {
    case 0: argv[argc++] = (char*)x->str ; break ;
    case 1: argv[argc++] = tmps[ntmp++] = string2file(x->str, &pre, &post, &nerr) ; break ;
    case 2: strvec_add(&pre, x->str) ; break ;
    default: strvec_add(&post, x->str) ; break ;
    }
  }
  argv[argc] = (char*)0 ;
  if (nerr == 0) {
    if (!libatsopt_patsopt_main_opt(argc, argv)) nerr += 1 ;
  }
  for (i = 0 ; i < ntmp ; i += 1) { unlink(tmps[i]) ; free(tmps[i]) ; }
  free(argv) ; free(tmps) ; free(pre.a) ; free(post.a) ;
  return nerr ;
}

static char *
fd2str (int fd)
{
  size_t cap = 4096, len = 0 ;
  char *buf = (char*)malloc(cap) ;
  if (lseek(fd, 0L, SEEK_SET) < 0) { free(buf) ; return (char*)0 ; }
  for (;;) {
    ssize_t n ;
    if (len + 1 >= cap) { cap *= 2 ; buf = (char*)realloc(buf, cap) ; }
    n = read(fd, buf+len, cap-len-1) ;
    if (n < 0) { free(buf) ; return (char*)0 ; }
    if (n == 0) break ;
    len += (size_t)n ;
  }
  buf[len] = '\0' ;
  return buf ;
}

void *
libatsopt_patsoptres_main_arglst (void *args)
{
  int nerr = 0, nerr2 ;
  char tmpout[] = "libatsopt_stdout_XXXXXX" ;
  char tmperr[] = "libatsopt_stderr_XXXXXX" ;
  int fdout = mkstemp(tmpout), fderr = mkstemp(tmperr) ;
  int save1 = -1, save2 = -1 ;
  char *strout = (char*)0, *strerr = (char*)0 ;
  patsoptres_t *res = (patsoptres_t*)malloc(sizeof(patsoptres_t)) ;
  if (fdout < 0 || fderr < 0) nerr += 1 ;
  if (nerr == 0) {
    fflush(stdout) ; fflush(stderr) ;
    save1 = dup(1) ; save2 = dup(2) ;
    if (save1 < 0 || save2 < 0 || dup2(fdout, 1) < 0 || dup2(fderr, 2) < 0) nerr += 1 ;
  }
  nerr2 = libatsopt_patsopt_main_arglst(args) ;
  fflush(stdout) ; fflush(stderr) ;
  if (save1 >= 0) { dup2(save1, 1) ; close(save1) ; }
  if (save2 >= 0) { dup2(save2, 2) ; close(save2) ; }
  if (fdout >= 0) { strout = fd2str(fdout) ; close(fdout) ; unlink(tmpout) ; }
  if (fderr >= 0) { strerr = fd2str(fderr) ; close(fderr) ; unlink(tmperr) ; }
  nerr2 += nerr ;
  if (!strout) { nerr2 += 1 ; strout = strdup("") ; }
  if (!strerr) { nerr2 += 1 ; strerr = strdup("") ; }
  res->nerr = nerr2 ; res->out = strout ; res->err = strerr ;
  return res ;
}

int libatsopt_patsoptres_get_nerr (void *r) { return ((patsoptres_t*)r)->nerr ; }
char *libatsopt_patsoptres_get_stdout (void *r) { return ((patsoptres_t*)r)->out ; }
char *libatsopt_patsoptres_get_stderr (void *r) { return ((patsoptres_t*)r)->err ; }
