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
s2cst_struct(l:addr) = @{
  s2cst_srt= s2rt(l)
, s2cst_name= symbol(l)
, s2cst_stamp= stamp
, s2cst_extdef= ptr // null or astring
, s2cst_nused= int
, s2cst_payload= ptr
} (* end of [s2cst_struct] *)
//
(* ****** ****** *)

local
//
assume
s2cst_type(l:addr) = aref(l, s2cst_struct(l))
//
in (* in of [local] *)

implement
s2cst_make
  {l}(ar, name, srt, stamp, extdef) = let
//
var x: s2cst_struct(l)
val () = x.s2cst_srt := srt
val () = x.s2cst_name := name
val () = x.s2cst_stamp := stamp
val () = x.s2cst_extdef := extdef
val () = x.s2cst_nused := (0)
val () = x.s2cst_payload := the_null_ptr
//
in
  aref_make<s2cst_struct(l)>(ar, x)
end // end of [s2cst_make]

(* ****** ****** *)
//
implement
s2cst_get_srt
  {l}(ar, s2c) =
  (aref_get<s2cst_struct(l)>(ar, s2c)).s2cst_srt
implement
s2cst_get_name
  {l}(ar, s2c) =
  (aref_get<s2cst_struct(l)>(ar, s2c)).s2cst_name
implement
s2cst_get_stamp
  {l}(ar, s2c) =
  (aref_get<s2cst_struct(l)>(ar, s2c)).s2cst_stamp
//
implement
s2cst_get_extdef
  {l}(ar, s2c) = let
  val p =
  (aref_get<s2cst_struct(l)>(ar, s2c)).s2cst_extdef
in
  if p > the_null_ptr
    then Some_vt($UN.cast{astring(l)}(p)) else None_vt()
  // end of [if]
end // end of [s2cst_get_extdef]
//
(* ****** ****** *)
//
implement
s2cst_get_nused
  {l}(ar, s2c) =
  (aref_get<s2cst_struct(l)>(ar, s2c)).s2cst_nused
implement
s2cst_incby1_nused
  {l}(ar, s2c) = let
  var x = aref_get<s2cst_struct(l)>(ar, s2c)
  val () = x.s2cst_nused := x.s2cst_nused + 1
in
  aref_set<s2cst_struct(l)>(ar, s2c, x)
end // end of [s2cst_incby1_nused]
//
(* ****** ****** *)
//
implement
s2cst_get_payload
  {l}(ar, s2c) =
  (aref_get<s2cst_struct(l)>(ar, s2c)).s2cst_payload
implement
s2cst_set_payload
  {l}(ar, s2c, pl) = let
  var x = aref_get<s2cst_struct(l)>(ar, s2c)
  val () = x.s2cst_payload := pl
in
  aref_set<s2cst_struct(l)>(ar, s2c, x)
end // end of [s2cst_set_payload]
//
end // end of [local]

(* ****** ****** *)

implement
fprint_s2cst
  (ar, out, s2c) =
  fprint_symbol(ar, out, s2cst_get_name(ar, s2c))
// end of [fprint_s2cst]

(* ****** ****** *)

implement
fprint_s2cstlst
  (ar, out, xs) = fprint_alist_sep(ar, out, xs, ", ", fprint_s2cst)

(* ****** ****** *)

(* end of [patsolve_cnstrnt_s2cst.dats] *)
