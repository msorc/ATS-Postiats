(*
** SPDX-FileCopyrightText: 2026 Mikhail Sorochan
** SPDX-License-Identifier: GPL-3.0-or-later
*)

(* ****** ****** *)
//
// patslint: the C part (the settings, the text of a file, the
// configuration file, the output of the findings, [--fix])
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0 // no initialization

(* ****** ****** *)

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

staload "./../SATS/patslint.sats"

(* ****** ****** *)

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <unistd.h>
#include <fnmatch.h>
#include <sys/stat.h>
#include <fcntl.h>

/* the output of --fix (see below) */
static FILE *patslint_fixout = NULL;

/* the functions of the rule table (DATS/patslint_rules.dats) */
extern int patslint_rule_find(void *name);
extern int patslint_sev_find(void *name);
extern void *patslint_rule_name(int id);
extern void *patslint_sev_name(int sev);
extern int patslint_rule_defsev(int id);

#define PATSLINT_NRULE 32 /* at least the NRULE of patslint.sats */

/* ****** ****** */
/* the settings of the current file */

static int patslint_the_sev[PATSLINT_NRULE];
static int patslint_the_maxcol = 80;
static int patslint_the_indent = 2;

int patslint_rule_get_sev(int id)
{
  return (id >= 0 && id < PATSLINT_NRULE) ? patslint_the_sev[id] : -1;
}
void patslint_rule_set_sev(int id, int sev)
{
  if (id >= 0 && id < PATSLINT_NRULE) patslint_the_sev[id] = sev;
}
int patslint_maxcol_get(void) { return patslint_the_maxcol; }
void patslint_maxcol_set(int n) { patslint_the_maxcol = n; }
int patslint_indent_get(void) { return patslint_the_indent; }
void patslint_indent_set(int n) { patslint_the_indent = n; }

/* ****** ****** */
/* the options of the command line, replayed for each file */

static int patslint_cmd_rule[64][2];
static int patslint_cmd_nrule = 0;
static int patslint_cmd_maxcol = -1;
static int patslint_cmd_indent = -1;

void patslint_cmdopt_rule_add(int id, int sev)
{
  if (patslint_cmd_nrule < 64) {
    patslint_cmd_rule[patslint_cmd_nrule][0] = id;
    patslint_cmd_rule[patslint_cmd_nrule][1] = sev;
    patslint_cmd_nrule += 1;
  }
}
void patslint_cmdopt_maxcol_set(int n) { patslint_cmd_maxcol = n; }
void patslint_cmdopt_indent_set(int n) { patslint_cmd_indent = n; }

void patslint_cmdopt_apply(void)
{
  int i;
  for (i = 0; i < patslint_cmd_nrule; i += 1)
    patslint_rule_set_sev(patslint_cmd_rule[i][0], patslint_cmd_rule[i][1]);
  if (patslint_cmd_maxcol > 0) patslint_the_maxcol = patslint_cmd_maxcol;
  if (patslint_cmd_indent > 0) patslint_the_indent = patslint_cmd_indent;
}

/* ****** ****** */
/* --lines=N-M,N,... */

static int (*patslint_lines)[2] = NULL;
static int patslint_nlines = 0;
static int patslint_haslines = 0;

void patslint_lines_clear(void)
{
  free(patslint_lines);
  patslint_lines = NULL; patslint_nlines = 0; patslint_haslines = 0;
}

int patslint_lines_set(void *spec)
{
  const char *s = (const char *)spec;
  patslint_lines_clear();
  patslint_haslines = 1;
  while (*s) {
    char *e;
    long a = strtol(s, &e, 10), b;
    if (e == s || a < 1) return 0;
    b = a; s = e;
    if (*s == '-') {
      s += 1; b = strtol(s, &e, 10);
      if (e == s || b < a) return 0;
      s = e;
    }
    patslint_lines =
      realloc(patslint_lines, (patslint_nlines + 1) * sizeof(*patslint_lines));
    if (!patslint_lines) { perror("patslint"); exit(2); }
    patslint_lines[patslint_nlines][0] = (int)a;
    patslint_lines[patslint_nlines][1] = (int)b;
    patslint_nlines += 1;
    if (*s == ',') s += 1; else if (*s) return 0;
  }
  return 1;
}

int patslint_lines_test(int line)
{
  int i;
  if (!patslint_haslines) return 1;
  for (i = 0; i < patslint_nlines; i += 1)
    if (patslint_lines[i][0] <= line && line <= patslint_lines[i][1]) return 1;
  return 0;
}

/* ****** ****** */
/* the configuration file */

static char *patslint_trim(char *s)
{
  char *e;
  while (*s == ' ' || *s == '\t') s += 1;
  e = s + strlen(s);
  while (e > s && strchr(" \t\n\r", e[-1])) e -= 1;
  *e = '\0';
  return s;
}

/* the configuration files whose errors were reported (once for each) */
static char **patslint_config_seen = NULL;
static int patslint_config_nseen = 0;
static int patslint_config_nerr = 0;

int patslint_config_nerror(void) { return patslint_config_nerr; }

static int patslint_config_first(const char *cfg)
{
  int i;
  for (i = 0; i < patslint_config_nseen; i += 1)
    if (strcmp(patslint_config_seen[i], cfg) == 0) return 0;
  patslint_config_seen =
    realloc(patslint_config_seen, (patslint_config_nseen + 1) * sizeof(char *));
  if (!patslint_config_seen) { perror("patslint"); exit(2); }
  patslint_config_seen[patslint_config_nseen++] = strdup(cfg);
  return 1;
}

void patslint_config_clear(void)
{
  int i;
  for (i = 0; i < patslint_config_nseen; i += 1) free(patslint_config_seen[i]);
  free(patslint_config_seen);
  patslint_config_seen = NULL; patslint_config_nseen = 0;
}

#define PATSLINT_CFGERR(...) \
  do { nerr += 1; if (first) { \
    fprintf(stderr, "%s: %d: error(patslint): ", cfg, nline); \
    fprintf(stderr, __VA_ARGS__); fputc('\n', stderr); } } while (0)

/* [rel]: the path of the file relative to the directory of [cfg] */
static int patslint_config_parse(const char *cfg, const char *rel)
{
  int first = patslint_config_first(cfg);
  FILE *inp = fopen(cfg, "r");
  char *line = NULL; size_t cap = 0;
  int nline = 0, nerr = 0, excluded = 0;
  const char *base = strrchr(rel, '/');
  base = base ? base + 1 : rel;
  if (!inp) return 0;
  while (getline(&line, &cap, inp) >= 0) {
    char *s = patslint_trim(line), *eq, *key, *val;
    nline += 1;
    if (*s == '\0' || *s == '#') continue;
    eq = strchr(s, '=');
    if (!eq) {
      PATSLINT_CFGERR("no [=] in the line");
      continue;
    }
    *eq = '\0'; key = patslint_trim(s); val = patslint_trim(eq + 1);
    if (strcmp(key, "max-col") == 0 || strcmp(key, "indent-width") == 0) {
      int n = atoi(val);
      if (n <= 0) {
        PATSLINT_CFGERR("[%s] needs a positive number", key);
      } else if (key[0] == 'm') patslint_the_maxcol = n;
      else patslint_the_indent = n;
    } else if (strcmp(key, "exclude") == 0) {
      if (fnmatch(val, rel, 0) == 0 ||
          (!strchr(val, '/') && fnmatch(val, base, 0) == 0))
        excluded = 1;
    } else {
      int id = patslint_rule_find(key);
      int sev = (strcmp(val, "on") == 0)
        ? patslint_rule_defsev(id) : patslint_sev_find(val);
      if (id < 0) {
        PATSLINT_CFGERR("unknown rule or key [%s]", key);
      } else if (sev < -1) {
        PATSLINT_CFGERR("unknown severity [%s]", val);
      } else patslint_rule_set_sev(id, sev);
    }
  }
  free(line); fclose(inp);
  if (first) patslint_config_nerr += nerr;
  return excluded ? 2 : (nerr ? -1 : 1);
}

int patslint_config_load(void *path)
{
  char *rp = realpath((const char *)path, NULL), *dir, *cfg;
  int res = 0;
  size_t n;
  if (!rp) return 0;
  dir = strdup(rp);
  cfg = malloc(strlen(rp) + 16);
  if (!dir || !cfg) { perror("patslint"); exit(2); }
  for (;;) {
    char *slash = strrchr(dir, '/');
    if (!slash) break;
    *slash = '\0'; /* [dir] is "" for the root */
    sprintf(cfg, "%s/.patslint", dir);
    if (access(cfg, R_OK) == 0) {
      n = strlen(dir);
      res = patslint_config_parse(cfg, rp + n + 1);
      break;
    }
    if (dir[0] == '\0') break;
  }
  free(cfg); free(dir); free(rp);
  return res;
}

/* ****** ****** */
/* the text of a file */

typedef struct {
  char *text; unsigned char *mask; int n;
  /* the lines: [linestart[k]] is the offset of the line k+1 */
  int nline; int *linestart;
  /* the rules disabled on each line (from 1) and in the file */
  int *dis; int filedis;
  /* the tokens: kind, begin, end */
  int ntok, captok; int *tokkind, *tokbeg, *tokend;
  /* the messages of the compiler: offset, rule, text */
  int nerr, caperr; int *erroff, *errrule; char **errmsg;
} patslint_textbuf_t;

static void *patslint_xrealloc(void *p, size_t n)
{
  p = realloc(p, n ? n : 1);
  if (!p) { perror("patslint"); exit(2); }
  return p;
}

void *patslint_textbuf_make(void *path)
{
  FILE *inp = fopen((const char *)path, "rb");
  patslint_textbuf_t *buf;
  size_t cap = 4096, n = 0, k;
  char *text;
  if (!inp) return NULL;
  text = malloc(cap + 1);
  if (!text) { perror("patslint"); exit(2); }
  while ((k = fread(text + n, 1, cap - n, inp)) > 0) {
    n += k;
    if (n == cap) {
      cap *= 2; text = realloc(text, cap + 1);
      if (!text) { perror("patslint"); exit(2); }
    }
  }
  if (ferror(inp) || n > INT_MAX / 2) { fclose(inp); free(text); return NULL; }
  fclose(inp);
  text[n] = '\0';
  buf = calloc(1, sizeof(patslint_textbuf_t));
  if (!buf) { perror("patslint"); exit(2); }
  buf->text = text; buf->n = (int)n;
  buf->mask = calloc(n + 1, 1);
  if (!buf->mask) { perror("patslint"); exit(2); }
  {
    int i, k = 1;
    buf->nline = 1;
    for (i = 0; i < buf->n; i += 1) if (text[i] == '\n') buf->nline += 1;
    buf->linestart = patslint_xrealloc(NULL, (buf->nline + 1) * sizeof(int));
    buf->linestart[0] = 0;
    for (i = 0; i < buf->n; i += 1)
      if (text[i] == '\n') buf->linestart[k++] = i + 1;
  }
  return buf;
}

void patslint_textbuf_free(void *p)
{
  patslint_textbuf_t *buf = p;
  int i;
  for (i = 0; i < buf->nerr; i += 1) free(buf->errmsg[i]);
  free(buf->errmsg); free(buf->erroff); free(buf->errrule);
  free(buf->tokkind); free(buf->tokbeg); free(buf->tokend);
  free(buf->text); free(buf->mask); free(buf->dis); free(buf->linestart);
  free(buf);
}

/* the line (from 1) and the column (from 1, in characters) of an offset */
int patslint_textbuf_line(void *p, int off)
{
  patslint_textbuf_t *buf = p;
  int lo = 0, hi = buf->nline - 1;
  while (lo < hi) {
    int mid = (lo + hi + 1) / 2;
    if (buf->linestart[mid] <= off) lo = mid; else hi = mid - 1;
  }
  return lo + 1;
}

int patslint_textbuf_col(void *p, int off)
{
  patslint_textbuf_t *buf = p;
  int i = buf->linestart[patslint_textbuf_line(p, off) - 1], col = 1;
  for (; i < off && i < buf->n; i += 1)
    if (((unsigned char)buf->text[i] & 0xC0) != 0x80) col += 1;
  return col;
}

int patslint_textbuf_line_start(void *p, int line)
{
  patslint_textbuf_t *buf = p;
  if (line < 1) return 0;
  if (line > buf->nline) return buf->n;
  return buf->linestart[line - 1];
}

int patslint_textbuf_nline(void *p) { return ((patslint_textbuf_t *)p)->nline; }

/* the tokens */
void patslint_textbuf_tok_add(void *p, int kind, int beg, int end)
{
  patslint_textbuf_t *buf = p;
  if (buf->ntok == buf->captok) {
    buf->captok = buf->captok ? 2 * buf->captok : 1024;
    buf->tokkind = patslint_xrealloc(buf->tokkind, buf->captok * sizeof(int));
    buf->tokbeg = patslint_xrealloc(buf->tokbeg, buf->captok * sizeof(int));
    buf->tokend = patslint_xrealloc(buf->tokend, buf->captok * sizeof(int));
  }
  buf->tokkind[buf->ntok] = kind;
  buf->tokbeg[buf->ntok] = beg;
  buf->tokend[buf->ntok] = end;
  buf->ntok += 1;
}
int patslint_textbuf_ntok(void *p) { return ((patslint_textbuf_t *)p)->ntok; }

/* the index of the first token that starts at [off] or after it */
int patslint_textbuf_tok_index(void *p, int off)
{
  patslint_textbuf_t *buf = p;
  int lo = 0, hi = buf->ntok;
  while (lo < hi) {
    int mid = (lo + hi) / 2;
    if (buf->tokbeg[mid] < off) lo = mid + 1; else hi = mid;
  }
  return lo;
}
int patslint_textbuf_tok_kind(void *p, int i)
{
  patslint_textbuf_t *buf = p;
  return (i >= 0 && i < buf->ntok) ? buf->tokkind[i] : -1;
}
int patslint_textbuf_tok_beg(void *p, int i)
{
  patslint_textbuf_t *buf = p;
  return (i >= 0 && i < buf->ntok) ? buf->tokbeg[i] : buf->n;
}
int patslint_textbuf_tok_end(void *p, int i)
{
  patslint_textbuf_t *buf = p;
  return (i >= 0 && i < buf->ntok) ? buf->tokend[i] : buf->n;
}

/* whether the bytes [beg, end) are the string [s] */
int patslint_textbuf_eq(void *p, int beg, int end, void *s)
{
  patslint_textbuf_t *buf = p;
  size_t n = strlen((const char *)s);
  return beg >= 0 && end <= buf->n && (size_t)(end - beg) == n
    && memcmp(buf->text + beg, s, n) == 0;
}

/* the offset of the string [s] in the bytes [beg, end), or -1 */
int patslint_textbuf_find(void *p, int beg, int end, void *s)
{
  patslint_textbuf_t *buf = p;
  size_t n = strlen((const char *)s);
  int i;
  if (end > buf->n) end = buf->n;
  for (i = beg; i >= 0 && i + (int)n <= end; i += 1)
    if (memcmp(buf->text + i, s, n) == 0) return i;
  return -1;
}

/* a copy of the bytes [beg, end) (it lives until the next call) */
void *patslint_textbuf_substr(void *p, int beg, int end)
{
  static char *str = NULL;
  patslint_textbuf_t *buf = p;
  if (beg < 0) beg = 0;
  if (end > buf->n) end = buf->n;
  if (end < beg) end = beg;
  str = patslint_xrealloc(str, end - beg + 1);
  memcpy(str, buf->text + beg, end - beg);
  str[end - beg] = '\0';
  return str;
}

/* the messages of the compiler */
static void
patslint_textbuf_err_add
  (patslint_textbuf_t *buf, int off, int rule, const char *msg)
{
  if (buf->nerr == buf->caperr) {
    buf->caperr = buf->caperr ? 2 * buf->caperr : 16;
    buf->erroff = patslint_xrealloc(buf->erroff, buf->caperr * sizeof(int));
    buf->errrule = patslint_xrealloc(buf->errrule, buf->caperr * sizeof(int));
    buf->errmsg = patslint_xrealloc(buf->errmsg, buf->caperr * sizeof(char *));
  }
  buf->erroff[buf->nerr] = off;
  buf->errrule[buf->nerr] = rule;
  buf->errmsg[buf->nerr] = strdup(msg);
  buf->nerr += 1;
}
int patslint_textbuf_nerr(void *p) { return ((patslint_textbuf_t *)p)->nerr; }
int patslint_textbuf_err_off(void *p, int i)
{
  return ((patslint_textbuf_t *)p)->erroff[i];
}
int patslint_textbuf_err_rule(void *p, int i)
{
  return ((patslint_textbuf_t *)p)->errrule[i];
}
void *patslint_textbuf_err_msg(void *p, int i)
{
  return ((patslint_textbuf_t *)p)->errmsg[i];
}

/*
** the messages that the compiler prints to a memory stream:
**   FILE: N(line=L, offs=C) -- N2(line=L2, offs=C2): error(KIND): MESSAGE
** where N is the offset plus 1; each one is recorded with [rule]
*/
static char *patslint_memout_buf = NULL;
static size_t patslint_memout_len = 0;

void *patslint_memout_open(void)
{
  FILE *fp = open_memstream(&patslint_memout_buf, &patslint_memout_len);
  if (!fp) { perror("patslint"); exit(2); }
  return fp;
}

/* the messages are dropped if [rule] is negative */
void patslint_memout_close(void *p, void *fp, int rule)
{
  patslint_textbuf_t *buf = p;
  char *s, *nl;
  fclose((FILE *)fp);
  for (s = patslint_memout_buf; s && *s; s = nl ? nl + 1 : s + strlen(s)) {
    char *lp, *e, *m, *d;
    long off;
    nl = strchr(s, '\n');
    if (nl) *nl = '\0';
    lp = strstr(s, "(line=");
    if (!lp) continue;
    for (d = lp; d > s && d[-1] >= '0' && d[-1] <= '9'; d -= 1) ;
    off = strtol(d, NULL, 10) - 1;
    e = strstr(lp, "): error(");
    if (!e) e = strstr(lp, "): warning(");
    if (!e) continue;
    m = strstr(e, "): ");
    m = m ? strstr(m + 3, "): ") : NULL;
    m = m ? m + 3 : e + 3;
    {
      size_t k = strlen(m);
      while (k > 0 && (m[k - 1] == '.' || m[k - 1] == ' ')) m[--k] = '\0';
    }
    if (off < 0) off = 0;
    if (off > buf->n) off = buf->n;
    {
      /* the bytes that are not printable ASCII are written as \xNN */
      char esc[1024];
      size_t k = 0;
      for (; *m && k + 5 < sizeof(esc); m += 1) {
        unsigned char c = (unsigned char)*m;
        if (c >= 32 && c < 127) esc[k++] = (char)c;
        else k += snprintf(esc + k, sizeof(esc) - k, "\\x%02x", c);
      }
      esc[k] = '\0';
      if (rule >= 0) patslint_textbuf_err_add(buf, (int)off, rule, esc);
    }
  }
  free(patslint_memout_buf);
  patslint_memout_buf = NULL; patslint_memout_len = 0;
}

int patslint_textbuf_size(void *p) { return ((patslint_textbuf_t *)p)->n; }

int patslint_textbuf_char(void *p, int i)
{
  patslint_textbuf_t *buf = p;
  return (i >= 0 && i < buf->n) ? (unsigned char)buf->text[i] : -1;
}

int patslint_textbuf_mask(void *p, int i)
{
  patslint_textbuf_t *buf = p;
  return (i >= 0 && i < buf->n) ? buf->mask[i] : 0;
}

void patslint_textbuf_set_mask(void *p, int i, int k)
{
  patslint_textbuf_t *buf = p;
  if (i >= 0 && i < buf->n) buf->mask[i] = (unsigned char)k;
}

/* the rules named at [s] (a list separated by commas): a bit set */
static int patslint_rulelist(const char *s, const char *end)
{
  int bits = 0;
  char name[64];
  while (s < end) {
    size_t k = 0;
    while (s < end && (*s == ' ' || *s == ',')) s += 1;
    while (s < end && ((*s >= 'a' && *s <= 'z') || *s == '-' || *s == '_')
           && k < sizeof(name) - 1)
      name[k++] = *s++;
    name[k] = '\0';
    if (k == 0) break;
    if (strcmp(name, "all") == 0) bits = -1;
    else {
      int id = patslint_rule_find(name);
      if (id >= 0) bits |= 1 << id;
    }
    while (s < end && *s == ' ') s += 1;
    if (s >= end || *s != ',') break;
  }
  return bits;
}

void patslint_textbuf_directives(void *p)
{
  patslint_textbuf_t *buf = p;
  int i, line = 1;
  free(buf->dis);
  buf->filedis = 0;
  buf->dis = calloc(buf->nline + 2, sizeof(int));
  if (!buf->dis) { perror("patslint"); exit(2); }
  for (i = 0; i < buf->n; i += 1) {
    const char *s = buf->text + i, *end;
    if (*s == '\n') { line += 1; continue; }
    if (buf->mask[i] != 1 || strncmp(s, "lint:", 5) != 0) continue;
    s += 5;
    while (*s == ' ') s += 1;
    end = s;
    while (*end && *end != '\n' && buf->mask[end - buf->text] == 1
           && !(end[0] == '*' && end[1] == ')'))
      end += 1;
    if (strncmp(s, "disable-file=", 13) == 0)
      buf->filedis |= patslint_rulelist(s + 13, end);
    else if (strncmp(s, "disable=", 8) == 0)
      buf->dis[line] |= patslint_rulelist(s + 8, end);
  }
}

int patslint_textbuf_disabled(void *p, int line, int rule)
{
  patslint_textbuf_t *buf = p;
  int bits = buf->filedis;
  if (buf->dis && line >= 1 && line <= buf->nline)
    bits |= buf->dis[line] | buf->dis[line - 1];
  return (bits >> rule) & 1;
}

/* ****** ****** */
/* the output of the findings */

static int patslint_the_format = 0;
static int patslint_the_failon = 1;
static int patslint_the_nfail = 0;
static int patslint_the_nfound = 0;

int patslint_format_get(void) { return patslint_the_format; }
void patslint_format_set(int fmt) { patslint_the_format = fmt; }
int patslint_failon_get(void) { return patslint_the_failon; }
void patslint_failon_set(int sev) { patslint_the_failon = sev; }
int patslint_nfail_get(void) { return patslint_the_nfail; }
int patslint_nfound_get(void) { return patslint_the_nfound; }

static void patslint_json_string(const char *s)
{
  putchar('"');
  for (; *s; s += 1) {
    unsigned char c = (unsigned char)*s;
    if (c == '"' || c == '\\') { putchar('\\'); putchar(c); }
    else if (c < 0x20) printf("\\u%04x", c);
    else putchar(c);
  }
  putchar('"');
}

void *patslint_msg_format2(void *fmt, int a, int b)
{
  static char msg[256];
  snprintf(msg, sizeof(msg), (const char *)fmt, a, b);
  return msg;
}

/* the findings of a file are kept, then sorted (by line, column, and the
   order in which they are found) and printed */
typedef struct { int line, col, rule, seq; char *msg; } patslint_finding_t;
static patslint_finding_t *patslint_findings = NULL;
static int patslint_nfinding = 0, patslint_capfinding = 0;

void *patslint_msg_format2s(void *fmt, void *a, void *b)
{
  static char msg[512];
  snprintf(msg, sizeof(msg), (const char *)fmt,
    (const char *)a, (const char *)b);
  return msg;
}

void *patslint_basename(void *path)
{
  const char *s = strrchr((const char *)path, '/');
  return (void *)(s ? s + 1 : (const char *)path);
}

/* in the child of --semantic, the findings go to the pipe */
static int patslint_child_fd = -1;

void patslint_finding_report(void *path, int line, int col, int rule, void *msg)
{
  patslint_finding_t *f;
  (void)path;
  if (patslint_child_fd >= 0) {
    char buf[1024];
    int n = snprintf(buf, sizeof(buf), "%d\t%d\t%d\t", line, col, rule);
    const char *m = (const char *)msg;
    for (; *m && n < (int)sizeof(buf) - 2; m += 1)
      buf[n++] = (*m == '\t' || *m == '\n') ? ' ' : *m;
    buf[n++] = '\n';
    if (write(patslint_child_fd, buf, n) < 0) _exit(4);
    return;
  }
  if (patslint_nfinding == patslint_capfinding) {
    patslint_capfinding = patslint_capfinding ? 2 * patslint_capfinding : 64;
    patslint_findings = patslint_xrealloc(patslint_findings,
      patslint_capfinding * sizeof(patslint_finding_t));
  }
  f = &patslint_findings[patslint_nfinding];
  f->line = line; f->col = col; f->rule = rule; f->seq = patslint_nfinding;
  f->msg = strdup((const char *)msg);
  patslint_nfinding += 1;
}

static int patslint_finding_cmp(const void *x, const void *y)
{
  const patslint_finding_t *a = x, *b = y;
  if (a->line != b->line) return a->line < b->line ? -1 : 1;
  if (a->col != b->col) return a->col < b->col ? -1 : 1;
  return a->seq < b->seq ? -1 : (a->seq > b->seq);
}

/* --source: -1 if the output is a terminal (the default), 1 always, 0 never */
static int patslint_the_source = -1;
void patslint_source_set(int k) { patslint_the_source = k; }

/*
** the line of a finding, then a caret under its column:
**     12 | val\tx = 1
**        |    ^
** (the bytes before the column are copied as spaces, or as tabs where
** the line has tabs, so that the caret is under the column in a
** terminal; a character of several bytes counts as one column)
*/
static void patslint_print_source(patslint_textbuf_t *buf, int line, int col)
{
  int beg, end, i, k;
  char gutter[32];
  if (line < 1 || line > buf->nline) return;
  beg = buf->linestart[line - 1];
  end = beg;
  while (end < buf->n && buf->text[end] != '\n') end += 1;
  if (end > beg && buf->text[end - 1] == '\r') end -= 1;
  k = snprintf(gutter, sizeof(gutter), "%5d", line);
  printf("%s | ", gutter);
  fwrite(buf->text + beg, 1, end - beg, stdout);
  printf("\n%*s | ", k, "");
  for (i = beg, k = 1; i < end && k < col; i += 1) {
    unsigned char c = (unsigned char)buf->text[i];
    if ((c & 0xC0) == 0x80) continue;
    putchar(c == '\t' ? '\t' : ' ');
    k += 1;
  }
  for (; k < col; k += 1) putchar(' ');
  printf("^\n");
}

int patslint_findings_flush(void *path, void *pbuf)
{
  int i, n = patslint_nfinding;
  int source = patslint_the_format == 0 && pbuf != NULL &&
    (patslint_the_source > 0 || (patslint_the_source < 0 && isatty(1)));
  qsort(patslint_findings, n, sizeof(patslint_finding_t), patslint_finding_cmp);
  for (i = 0; i < n; i += 1) {
    patslint_finding_t *f = &patslint_findings[i];
    int sev = patslint_rule_get_sev(f->rule);
    const char *rname = patslint_rule_name(f->rule);
    const char *sname = patslint_sev_name(sev);
    patslint_the_nfound += 1;
    if (sev >= patslint_the_failon) patslint_the_nfail += 1;
    if (patslint_the_format == 1) {
      printf("{\"file\": "); patslint_json_string(path);
      printf(", \"line\": %d, \"col\": %d", f->line, f->col);
      printf(", \"severity\": \"%s\", \"rule\": \"%s\"", sname, rname);
      printf(", \"message\": ");
      patslint_json_string(f->msg);
      printf("}\n");
    } else
    {
      printf("%s: %d(%d): %s(lint:%s): %s\n",
        (const char *)path, f->line, f->col, sname, rname, f->msg);
      if (source) patslint_print_source(pbuf, f->line, f->col);
    }
    free(f->msg);
  }
  free(patslint_findings);
  patslint_findings = NULL; patslint_nfinding = 0; patslint_capfinding = 0;
  return n;
}

/* a name that is not reported: empty, from [_] on, or with a [$] */
int patslint_name_ignored(void *s)
{
  const char *t = (const char *)s;
  return t[0] == '\0' || t[0] == '_' || strchr(t, '$') != NULL;
}

/* [s] has the char [c] (1) or not (0) */
int patslint_strchr_test(void *s, int c)
{
  return strchr((const char *)s, c) != NULL;
}

/* [t] is the end of [s] from the index [i] on */
int patslint_strcmp_at(void *s, int i, void *t)
{
  return strcmp((const char *)s + i, (const char *)t);
}

/* a memory stream whose text is returned by [patslint_memstr_close]
   (it lives until the next call) */
static char *patslint_memstr_buf = NULL;
static size_t patslint_memstr_len = 0;
static char *patslint_memstr_text = NULL;

void *patslint_memstr_open(void)
{
  FILE *fp = open_memstream(&patslint_memstr_buf, &patslint_memstr_len);
  if (!fp) { perror("patslint"); exit(2); }
  return fp;
}

void *patslint_memstr_close(void *fp)
{
  fclose((FILE *)fp);
  free(patslint_memstr_text);
  patslint_memstr_text = patslint_memstr_buf ? patslint_memstr_buf : strdup("");
  patslint_memstr_buf = NULL; patslint_memstr_len = 0;
  {
    /* one line: the newlines become spaces */
    char *s;
    for (s = patslint_memstr_text; *s; s += 1) if (*s == '\n') *s = ' ';
  }
  return patslint_memstr_text;
}

/* what the compiler prints (its messages on stderr, the #print of the
   translated code on stdout) is dropped while [off] */
static int patslint_stderr_saved = -1;
static int patslint_stdout_saved = -1;

void patslint_stderr_off(void)
{
  int fd;
  fflush(stdout); fflush(stderr);
  if (patslint_stderr_saved >= 0) return;
  patslint_stdout_saved = dup(1);
  patslint_stderr_saved = dup(2);
  fd = open("/dev/null", O_WRONLY);
  if (fd >= 0) { dup2(fd, 1); dup2(fd, 2); close(fd); }
}

void patslint_stderr_on(void)
{
  fflush(stdout); fflush(stderr);
  if (patslint_stderr_saved < 0) return;
  dup2(patslint_stdout_saved, 1);
  dup2(patslint_stderr_saved, 2);
  close(patslint_stdout_saved);
  close(patslint_stderr_saved);
  patslint_stdout_saved = -1;
  patslint_stderr_saved = -1;
}

/* ****** ****** */
/*
** --semantic runs the translation of each file in a child process: the
** compiler may exit (a failed #assert, ...) or leave its state broken
** after an error. [patslint_sema_fork] returns 0 in the child (whose
** findings are written to the pipe, and whose stdout and stderr are
** /dev/null) and 1 in the parent; [patslint_sema_child_exit] ends the
** child; [patslint_sema_collect] reads the findings in the parent and
** returns 0 if the child did not complete.
*/
#include <sys/wait.h>

static int patslint_sema_pipe = -1;
static pid_t patslint_sema_pid = -1;

int patslint_sema_fork(void)
{
  int fds[2];
  fflush(stdout); fflush(stderr);
  if (patslint_fixout) fflush(patslint_fixout);
  if (pipe(fds) != 0) { perror("patslint"); exit(2); }
  patslint_sema_pid = fork();
  if (patslint_sema_pid < 0) { perror("patslint"); exit(2); }
  if (patslint_sema_pid == 0) {
    int fd = open("/dev/null", O_WRONLY);
    close(fds[0]);
    patslint_child_fd = fds[1];
    if (fd >= 0) { dup2(fd, 1); dup2(fd, 2); close(fd); }
    return 0;
  }
  close(fds[1]);
  patslint_sema_pipe = fds[0];
  return 1;
}

void patslint_sema_child_exit(int ok)
{
  _exit(ok ? 0 : 3);
}

int patslint_sema_collect(void *path)
{
  FILE *inp = fdopen(patslint_sema_pipe, "r");
  char *line = NULL; size_t cap = 0;
  int status = 0;
  if (!inp) { perror("patslint"); exit(2); }
  while (getline(&line, &cap, inp) >= 0) {
    int l, c, r, k = 0;
    if (sscanf(line, "%d\t%d\t%d\t%n", &l, &c, &r, &k) == 3 && k > 0) {
      size_t n = strlen(line + k);
      if (n > 0 && line[k + n - 1] == '\n') line[k + n - 1] = '\0';
      patslint_finding_report(path, l, c, r, line + k);
    }
  }
  free(line); fclose(inp);
  patslint_sema_pipe = -1;
  if (waitpid(patslint_sema_pid, &status, 0) < 0) return 0;
  return WIFEXITED(status) && WEXITSTATUS(status) == 0;
}

/* ****** ****** */
/* --semantic */

static int patslint_the_semantic = 0;
int patslint_semantic_get(void) { return patslint_the_semantic; }
void patslint_semantic_set(int b) { patslint_the_semantic = b; }

/* ****** ****** */
/* --fix */

static int patslint_the_fix = 0;

int patslint_fix_get(void) { return patslint_the_fix; }
void patslint_fix_set(int b) { patslint_the_fix = b; }

static char *patslint_fixname(const char *path)
{
  char *name = malloc(strlen(path) + 16);
  if (!name) { perror("patslint"); exit(2); }
  sprintf(name, "%s.patslint-fix", path);
  return name;
}

int patslint_fixout_open(void *path)
{
  char *name = patslint_fixname(path);
  patslint_fixout = fopen(name, "wb");
  if (!patslint_fixout) perror(name);
  free(name);
  return patslint_fixout != NULL;
}

void patslint_fixout_putc(int c)
{
  if (patslint_fixout) fputc(c, patslint_fixout);
}

int patslint_fixout_close(void *path, int commit)
{
  char *name = patslint_fixname(path);
  int ok = 1;
  struct stat st;
  if (!patslint_fixout) { free(name); return 0; }
  if (fclose(patslint_fixout) != 0) ok = 0;
  patslint_fixout = NULL;
  if (ok && commit) {
    if (stat((const char *)path, &st) == 0) chmod(name, st.st_mode & 07777);
    if (rename(name, (const char *)path) != 0) { perror(name); ok = 0; }
  }
  if (!ok || !commit) remove(name);
  free(name);
  return ok;
}
%}

(* ****** ****** *)

implement
textbuf_make_file
  (path) = let
//
extern
fun
textbuf_make (path: string): ptr = "mac#patslint_textbuf_make"
//
val p = textbuf_make (path)
//
in
  if isneqz(p)
    then Some_vt ($UN.castvwtp0{textbuf}(p)) else None_vt ()
  // end of [if]
end // end of [textbuf_make_file]

(* ****** ****** *)

(* end of [patslint_util.dats] *)
