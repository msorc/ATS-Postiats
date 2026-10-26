/*
** SPDX-FileCopyrightText: 2026 Mikhail Sorochan
** SPDX-License-Identifier: GPL-3.0-or-later
*/

/* ****** ****** */
/*
** patslint: the declarations of the C part (the settings, the text
** of a file, the configuration file, the output); the definitions
** are in DATS/patslint_util.dats
*/
/* ****** ****** */

#ifndef PATSLINT_CATS
#define PATSLINT_CATS

/* ****** ****** */

extern int patslint_rule_get_sev(int id);
extern void patslint_rule_set_sev(int id, int sev);
extern int patslint_maxcol_get(void);
extern void patslint_maxcol_set(int n);
extern int patslint_indent_get(void);
extern void patslint_indent_set(int n);

extern void patslint_cmdopt_rule_add(int id, int sev);
extern void patslint_cmdopt_maxcol_set(int n);
extern void patslint_cmdopt_indent_set(int n);
extern void patslint_cmdopt_apply(void);

extern int patslint_lines_set(void *spec);
extern void patslint_lines_clear(void);
extern int patslint_lines_test(int line);

extern int patslint_config_load(void *path);
extern int patslint_config_nerror(void);
extern void patslint_config_clear(void);

/* ****** ****** */

extern void *patslint_textbuf_make(void *path);
extern void patslint_textbuf_free(void *buf);
extern int patslint_textbuf_size(void *buf);
extern int patslint_textbuf_char(void *buf, int i);
extern int patslint_textbuf_mask(void *buf, int i);
extern void patslint_textbuf_set_mask(void *buf, int i, int k);
extern void patslint_textbuf_directives(void *buf);
extern int patslint_textbuf_disabled(void *buf, int line, int rule);
extern int patslint_textbuf_line(void *buf, int off);
extern int patslint_textbuf_col(void *buf, int off);
extern int patslint_textbuf_line_start(void *buf, int line);
extern int patslint_textbuf_nline(void *buf);
extern void patslint_textbuf_tok_add(void *buf, int kind, int beg, int end);
extern int patslint_textbuf_ntok(void *buf);
extern int patslint_textbuf_tok_kind(void *buf, int i);
extern int patslint_textbuf_tok_beg(void *buf, int i);
extern int patslint_textbuf_tok_end(void *buf, int i);
extern int patslint_textbuf_eq(void *buf, int beg, int end, void *s);
extern int patslint_textbuf_find(void *buf, int beg, int end, void *s);
extern void *patslint_textbuf_substr(void *buf, int beg, int end);
extern int patslint_textbuf_nerr(void *buf);
extern int patslint_textbuf_err_off(void *buf, int i);
extern int patslint_textbuf_err_rule(void *buf, int i);
extern void *patslint_textbuf_err_msg(void *buf, int i);
extern void *patslint_memout_open(void);
extern void patslint_memout_close(void *buf, void *fp, int rule);

/* ****** ****** */

extern int patslint_format_get(void);
extern void patslint_format_set(int fmt);
extern int patslint_failon_get(void);
extern void patslint_failon_set(int sev);
extern int patslint_nfail_get(void);
extern int patslint_nfound_get(void);

extern void *patslint_msg_format2(void *fmt, int a, int b);
extern void *patslint_msg_format2s(void *fmt, void *a, void *b);
extern void *patslint_basename(void *path);
extern int patslint_textbuf_tok_index(void *buf, int off);

extern void
patslint_finding_report
  (void *path, int line, int col, int rule, void *msg);
extern int patslint_findings_flush(void *path, void *buf);
extern void patslint_source_set(int k);

extern int patslint_strcmp_at(void *s, int i, void *t);
extern int patslint_strchr_test(void *s, int c);
extern int patslint_name_ignored(void *s);
extern void *patslint_memstr_open(void);
extern void *patslint_memstr_close(void *fp);
extern void patslint_stderr_off(void);
extern void patslint_stderr_on(void);
extern int patslint_semantic_get(void);
extern int patslint_sema_fork(void);
extern void patslint_sema_child_exit(int ok);
extern int patslint_sema_collect(void *path);
extern void patslint_semantic_set(int b);
extern int patslint_fix_get(void);
extern void patslint_fix_set(int b);
extern int patslint_fixout_open(void *path);
extern void patslint_fixout_putc(int c);
extern int patslint_fixout_close(void *path, int commit);

/* ****** ****** */

#endif /* PATSLINT_CATS */

/* end of [patslint.cats] */
