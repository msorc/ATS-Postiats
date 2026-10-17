(*
** ATS-extsolve:
** For solving ATS-constraints
** with external SMT-solvers
*)

(* ****** ****** *)

(*
** Author: Hongwei Xi
** Authoremail: gmhwxiATgmailDOTcom
** Start time: May, 2015
*)

(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
//
#define
ATS_DYNLOADNAME
"patsolve_cnstrnt__dynload"
//
(* ****** ****** *)
//
#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

#staload UN = $UNSAFE

(* ****** ****** *)
//
#staload
"libats/SATS/arena.sats"
#staload
_(*anon*) = "libats/DATS/arena.dats"
//
#staload
"./../SATS/patsolve_cnstrnt.sats"
//
(* ****** ****** *)
//
implement
print_stamp(x) = fprint_stamp(stdout_ref, x)
implement
prerr_stamp(x) = fprint_stamp(stderr_ref, x)
//
(* ****** ****** *)
//
// HX: printing an arena list (with a separator)
//
extern
fun{a:t@ype}
fprint_alist_sep{l:addr}
(
  ar: !arena(l), out: FILEref
, xs: alist(l, a), sep: string, pr: (!arena(l), FILEref, a) -> void
) : void // end-of-function
//
implement
{a}(*tmp*)
fprint_alist_sep
  {l}(ar, out, xs, sep, pr) = let
//
fun
loop
(
  ar: !arena(l), xs: alist(l, a), i: int
) : void =
(
if
alist_is_cons(xs)
then let
  val () =
  if i > 0 then fprint_string(out, sep)
  val () = pr(ar, out, alist_head<a>(ar, xs))
in
  loop(ar, alist_tail<a>(ar, xs), i+1)
end // end of [then]
) (* end of [loop] *)
//
in
  loop(ar, xs, 0)
end // end of [fprint_alist_sep]
//
(* ****** ****** *)
//
#include "./CNSTRNT/patsolve_cnstrnt_gen.hats"
//
(* ****** ****** *)
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_stamp.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_label.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_symbol.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_location.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_s2rt.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_s2cst.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_s2var.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_s2vvar.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_s2exp.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_s3itm.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_h3ypo.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./CNSTRNT/patsolve_cnstrnt_c3nstr.dats" in (*nothing*)
end // end of [local]
//
(* ****** ****** *)

(* end of [patsolve_cnstrnt.dats] *)
