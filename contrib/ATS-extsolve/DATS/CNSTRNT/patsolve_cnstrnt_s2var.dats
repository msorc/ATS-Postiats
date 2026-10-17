(*
** ATS-extsolve:
** For solving ATS-constraints
** with external SMT-solvers
*)

(* ****** ****** *)

(*
** Author: Hongwei Xi
** Authoremail: gmhwxiATgmailDOTcom
*)

(* ****** ****** *)
//
typedef
s2var_struct(l:addr) = @{
  s2var_srt= s2rt(l)
, s2var_name= symbol(l)
, s2var_stamp= stamp
, s2var_payload= ptr
} (* end of [s2var_struct] *)
//
(* ****** ****** *)

local
//
assume
s2var_type(l:addr) = aref(l, s2var_struct(l))
//
in (* in of [local] *)

implement
s2var_make
  {l}(ar, name, srt, stamp) = let
//
var x: s2var_struct(l)
val () = x.s2var_srt := srt
val () = x.s2var_name := name
val () = x.s2var_stamp := stamp
val () = x.s2var_payload := the_null_ptr
//
in
  aref_make<s2var_struct(l)>(ar, x)
end // end of [s2var_make]

(* ****** ****** *)
//
implement
s2var_get_srt
  {l}(ar, s2v) =
  (aref_get<s2var_struct(l)>(ar, s2v)).s2var_srt
implement
s2var_get_name
  {l}(ar, s2v) =
  (aref_get<s2var_struct(l)>(ar, s2v)).s2var_name
implement
s2var_get_stamp
  {l}(ar, s2v) =
  (aref_get<s2var_struct(l)>(ar, s2v)).s2var_stamp
//
implement
s2var_get_payload
  {l}(ar, s2v) =
  (aref_get<s2var_struct(l)>(ar, s2v)).s2var_payload
implement
s2var_set_payload
  {l}(ar, s2v, pl) = let
  var x = aref_get<s2var_struct(l)>(ar, s2v)
  val () = x.s2var_payload := pl
in
  aref_set<s2var_struct(l)>(ar, s2v, x)
end // end of [s2var_set_payload]
//
end // end of [local]

(* ****** ****** *)

implement
s2var_is_impred
  (ar, s2v) = s2rt_is_impred(ar, s2var_get_srt(ar, s2v))

(* ****** ****** *)

implement
fprint_s2var
  (ar, out, s2v) =
  fprint_symbol(ar, out, s2var_get_name(ar, s2v))
// end of [fprint_s2var]

(* ****** ****** *)

implement
fprint_s2varlst
  (ar, out, xs) = fprint_alist_sep(ar, out, xs, ", ", fprint_s2var)

(* ****** ****** *)

(* end of [patsolve_cnstrnt_s2var.dats] *)
