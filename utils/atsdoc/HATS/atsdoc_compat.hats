(* ****** ****** *)
//
// atsdoc_compat.hats: the few ATS1 idioms that the code blocks of the
// .atxt files use and the no-GC ATS2 prelude does not have. It is included
// by the helper files of atsdoc (postiatsatxt.hats, ...), so that the
// templates keep the ATS1 spelling of
//
//   sprintf (fmt, @(x1, ..., xn))   : Strptr1
//   printf (fmt, @(x1, ..., xn)), fprintf (out, fmt, @(...)), prerrf (...)
//   string_of_strptr (x)            : string (the string is never freed)
//   glist_nil/glist_cons/glist_reverse on [atextlst]
//
// (see src/PORTING.md, "atsdoc corpus adaptation"). The format is the one
// of C (a call of a variadic C function); the arguments are strings
// (all the conversions are [%s]: a number is converted by the caller, e.g.
// with [tostrptr_int]), 1 to 16 of them.
//
(* ****** ****** *)

#ifndef ATSDOC_ATSDOC_COMPAT
#define ATSDOC_ATSDOC_COMPAT 1

(* ****** ****** *)

#include "share/atspre_staload.hats"
//
staload UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*anon*) = "libats/DATS/arena.dats"

(* ****** ****** *)

%{^
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
static
char*
atsdoc_vsprintf(const char *fmt, ...)
{
  va_list ap; int n; char *buf;
  va_start(ap, fmt); n = vsnprintf((char*)0, 0, fmt, ap); va_end(ap);
  if (n < 0) { fprintf(stderr, "exit(ATSDOC): sprintf failed\n"); exit(1); }
  buf = (char*)malloc((size_t)n + 1);
  if (!buf) { fprintf(stderr, "exit(ATSDOC): out of memory\n"); exit(1); }
  va_start(ap, fmt); vsnprintf(buf, (size_t)n + 1, fmt, ap); va_end(ap);
  return buf;
}
%}

(* ****** ****** *)
//
// HX: the string is not freed (as in ATS1, where it was GC'ed)
//
fun
string_of_strptr
  (x: Strptr1): string = $UN.castvwtp0{string}(x)
//
(* ****** ****** *)
fun
atsdoc_fprint_strptr
  (out: FILEref, x: Strptr1): void = let
  val () = fprint_string(out, $UN.castvwtp1{string}(x))
in
  strptr_free(x)
end // end of [atsdoc_fprint_strptr]
//
// HX: [sprintf] and the like (atsdoc_compat_gen.py generates the rest)
//
// begin of [generated] (n = 1, ..., 16)
//
fun
sprintf_1 (fmt: string, xs: @(string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0)
fun
sprintf_2 (fmt: string, xs: @(string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1)
fun
sprintf_3 (fmt: string, xs: @(string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2)
fun
sprintf_4 (fmt: string, xs: @(string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3)
fun
sprintf_5 (fmt: string, xs: @(string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4)
fun
sprintf_6 (fmt: string, xs: @(string,string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4, xs.5)
fun
sprintf_7 (fmt: string, xs: @(string,string,string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4, xs.5, xs.6)
fun
sprintf_8 (fmt: string, xs: @(string,string,string,string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4, xs.5, xs.6, xs.7)
fun
sprintf_9 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4, xs.5, xs.6, xs.7, xs.8)
fun
sprintf_10 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4, xs.5, xs.6, xs.7, xs.8, xs.9)
fun
sprintf_11 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4, xs.5, xs.6, xs.7, xs.8, xs.9, xs.10)
fun
sprintf_12 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4, xs.5, xs.6, xs.7, xs.8, xs.9, xs.10, xs.11)
fun
sprintf_13 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4, xs.5, xs.6, xs.7, xs.8, xs.9, xs.10, xs.11, xs.12)
fun
sprintf_14 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4, xs.5, xs.6, xs.7, xs.8, xs.9, xs.10, xs.11, xs.12, xs.13)
fun
sprintf_15 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4, xs.5, xs.6, xs.7, xs.8, xs.9, xs.10, xs.11, xs.12, xs.13, xs.14)
fun
sprintf_16 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)): Strptr1 =
  $extfcall(Strptr1, "atsdoc_vsprintf", fmt, xs.0, xs.1, xs.2, xs.3, xs.4, xs.5, xs.6, xs.7, xs.8, xs.9, xs.10, xs.11, xs.12, xs.13, xs.14, xs.15)
//
symintr sprintf
overload sprintf with sprintf_1 of 10
overload sprintf with sprintf_2 of 10
overload sprintf with sprintf_3 of 10
overload sprintf with sprintf_4 of 10
overload sprintf with sprintf_5 of 10
overload sprintf with sprintf_6 of 10
overload sprintf with sprintf_7 of 10
overload sprintf with sprintf_8 of 10
overload sprintf with sprintf_9 of 10
overload sprintf with sprintf_10 of 10
overload sprintf with sprintf_11 of 10
overload sprintf with sprintf_12 of 10
overload sprintf with sprintf_13 of 10
overload sprintf with sprintf_14 of 10
overload sprintf with sprintf_15 of 10
overload sprintf with sprintf_16 of 10
fun
fprintf_1 (out: FILEref, fmt: string, xs: @(string)): void =
  atsdoc_fprint_strptr(out, sprintf_1(fmt, xs))
fun
fprintf_2 (out: FILEref, fmt: string, xs: @(string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_2(fmt, xs))
fun
fprintf_3 (out: FILEref, fmt: string, xs: @(string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_3(fmt, xs))
fun
fprintf_4 (out: FILEref, fmt: string, xs: @(string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_4(fmt, xs))
fun
fprintf_5 (out: FILEref, fmt: string, xs: @(string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_5(fmt, xs))
fun
fprintf_6 (out: FILEref, fmt: string, xs: @(string,string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_6(fmt, xs))
fun
fprintf_7 (out: FILEref, fmt: string, xs: @(string,string,string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_7(fmt, xs))
fun
fprintf_8 (out: FILEref, fmt: string, xs: @(string,string,string,string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_8(fmt, xs))
fun
fprintf_9 (out: FILEref, fmt: string, xs: @(string,string,string,string,string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_9(fmt, xs))
fun
fprintf_10 (out: FILEref, fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_10(fmt, xs))
fun
fprintf_11 (out: FILEref, fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_11(fmt, xs))
fun
fprintf_12 (out: FILEref, fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_12(fmt, xs))
fun
fprintf_13 (out: FILEref, fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_13(fmt, xs))
fun
fprintf_14 (out: FILEref, fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_14(fmt, xs))
fun
fprintf_15 (out: FILEref, fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_15(fmt, xs))
fun
fprintf_16 (out: FILEref, fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  atsdoc_fprint_strptr(out, sprintf_16(fmt, xs))
//
symintr fprintf
overload fprintf with fprintf_1 of 10
overload fprintf with fprintf_2 of 10
overload fprintf with fprintf_3 of 10
overload fprintf with fprintf_4 of 10
overload fprintf with fprintf_5 of 10
overload fprintf with fprintf_6 of 10
overload fprintf with fprintf_7 of 10
overload fprintf with fprintf_8 of 10
overload fprintf with fprintf_9 of 10
overload fprintf with fprintf_10 of 10
overload fprintf with fprintf_11 of 10
overload fprintf with fprintf_12 of 10
overload fprintf with fprintf_13 of 10
overload fprintf with fprintf_14 of 10
overload fprintf with fprintf_15 of 10
overload fprintf with fprintf_16 of 10
fun
printf_1 (fmt: string, xs: @(string)): void =
  fprintf_1(stdout_ref, fmt, xs)
fun
printf_2 (fmt: string, xs: @(string,string)): void =
  fprintf_2(stdout_ref, fmt, xs)
fun
printf_3 (fmt: string, xs: @(string,string,string)): void =
  fprintf_3(stdout_ref, fmt, xs)
fun
printf_4 (fmt: string, xs: @(string,string,string,string)): void =
  fprintf_4(stdout_ref, fmt, xs)
fun
printf_5 (fmt: string, xs: @(string,string,string,string,string)): void =
  fprintf_5(stdout_ref, fmt, xs)
fun
printf_6 (fmt: string, xs: @(string,string,string,string,string,string)): void =
  fprintf_6(stdout_ref, fmt, xs)
fun
printf_7 (fmt: string, xs: @(string,string,string,string,string,string,string)): void =
  fprintf_7(stdout_ref, fmt, xs)
fun
printf_8 (fmt: string, xs: @(string,string,string,string,string,string,string,string)): void =
  fprintf_8(stdout_ref, fmt, xs)
fun
printf_9 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string)): void =
  fprintf_9(stdout_ref, fmt, xs)
fun
printf_10 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_10(stdout_ref, fmt, xs)
fun
printf_11 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_11(stdout_ref, fmt, xs)
fun
printf_12 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_12(stdout_ref, fmt, xs)
fun
printf_13 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_13(stdout_ref, fmt, xs)
fun
printf_14 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_14(stdout_ref, fmt, xs)
fun
printf_15 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_15(stdout_ref, fmt, xs)
fun
printf_16 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_16(stdout_ref, fmt, xs)
//
symintr printf
overload printf with printf_1 of 10
overload printf with printf_2 of 10
overload printf with printf_3 of 10
overload printf with printf_4 of 10
overload printf with printf_5 of 10
overload printf with printf_6 of 10
overload printf with printf_7 of 10
overload printf with printf_8 of 10
overload printf with printf_9 of 10
overload printf with printf_10 of 10
overload printf with printf_11 of 10
overload printf with printf_12 of 10
overload printf with printf_13 of 10
overload printf with printf_14 of 10
overload printf with printf_15 of 10
overload printf with printf_16 of 10
fun
prerrf_1 (fmt: string, xs: @(string)): void =
  fprintf_1(stderr_ref, fmt, xs)
fun
prerrf_2 (fmt: string, xs: @(string,string)): void =
  fprintf_2(stderr_ref, fmt, xs)
fun
prerrf_3 (fmt: string, xs: @(string,string,string)): void =
  fprintf_3(stderr_ref, fmt, xs)
fun
prerrf_4 (fmt: string, xs: @(string,string,string,string)): void =
  fprintf_4(stderr_ref, fmt, xs)
fun
prerrf_5 (fmt: string, xs: @(string,string,string,string,string)): void =
  fprintf_5(stderr_ref, fmt, xs)
fun
prerrf_6 (fmt: string, xs: @(string,string,string,string,string,string)): void =
  fprintf_6(stderr_ref, fmt, xs)
fun
prerrf_7 (fmt: string, xs: @(string,string,string,string,string,string,string)): void =
  fprintf_7(stderr_ref, fmt, xs)
fun
prerrf_8 (fmt: string, xs: @(string,string,string,string,string,string,string,string)): void =
  fprintf_8(stderr_ref, fmt, xs)
fun
prerrf_9 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string)): void =
  fprintf_9(stderr_ref, fmt, xs)
fun
prerrf_10 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_10(stderr_ref, fmt, xs)
fun
prerrf_11 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_11(stderr_ref, fmt, xs)
fun
prerrf_12 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_12(stderr_ref, fmt, xs)
fun
prerrf_13 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_13(stderr_ref, fmt, xs)
fun
prerrf_14 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_14(stderr_ref, fmt, xs)
fun
prerrf_15 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_15(stderr_ref, fmt, xs)
fun
prerrf_16 (fmt: string, xs: @(string,string,string,string,string,string,string,string,string,string,string,string,string,string,string,string)): void =
  fprintf_16(stderr_ref, fmt, xs)
//
symintr prerrf
overload prerrf with prerrf_1 of 10
overload prerrf with prerrf_2 of 10
overload prerrf with prerrf_3 of 10
overload prerrf with prerrf_4 of 10
overload prerrf with prerrf_5 of 10
overload prerrf with prerrf_6 of 10
overload prerrf with prerrf_7 of 10
overload prerrf with prerrf_8 of 10
overload prerrf with prerrf_9 of 10
overload prerrf with prerrf_10 of 10
overload prerrf with prerrf_11 of 10
overload prerrf with prerrf_12 of 10
overload prerrf with prerrf_13 of 10
overload prerrf with prerrf_14 of 10
overload prerrf with prerrf_15 of 10
overload prerrf with prerrf_16 of 10
//
// end of [generated]
//
(* ****** ****** *)

#endif // end of [ATSDOC_ATSDOC_COMPAT]

(* ****** ****** *)

(* end of [atsdoc_compat.hats] *)
