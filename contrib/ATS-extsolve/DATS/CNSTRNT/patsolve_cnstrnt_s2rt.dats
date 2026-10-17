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

implement s2rt_int(ar) = s2rt_S2RTint(ar)
implement s2rt_addr(ar) = s2rt_S2RTaddr(ar)
implement s2rt_bool(ar) = s2rt_S2RTbool(ar)
implement s2rt_real(ar) = s2rt_S2RTreal(ar)
implement s2rt_float(ar) = s2rt_S2RTfloat(ar)
implement s2rt_string(ar) = s2rt_S2RTstring(ar)

(* ****** ****** *)

implement
s2rt_is_impred
  (ar, s2t0) = (
case+
s2rt_view(ar, s2t0)
of // case+
| ~S2RTtype() => true
| ~S2RTvtype() => true 
| ~S2RTt0ype() => true
| ~S2RTvt0ype() => true
| ~S2RTprop() => true
| ~S2RTview() => true
| ~S2RTfun(_, s2t_res) => s2rt_is_impred(ar, s2t_res)
| v0(*rest-of-S2RT*) => (s2rt_view_free(v0); false)
) (* end of [s2rt_is_impred] *)

(* ****** ****** *)

implement
fprint_s2rt
  (ar, out, s2t) =
(
case+
s2rt_view(ar, s2t)
of // case+
| ~S2RTint() => fprint! (out, "S2RTint()")
| ~S2RTaddr() => fprint! (out, "S2RTaddr()")
| ~S2RTbool() => fprint! (out, "S2RTbool()")
| ~S2RTreal() => fprint! (out, "S2RTreal()")
| ~S2RTfloat() => fprint! (out, "S2RTfloat()")
| ~S2RTstring() => fprint! (out, "S2RTstring()")
| ~S2RTcls() => fprint! (out, "S2RTcls()")
| ~S2RTeff() => fprint! (out, "S2RTeff()")
| ~S2RTtup() => fprint! (out, "S2RTtup()")
| ~S2RTtype() => fprint! (out, "S2RTtype()")
| ~S2RTt0ype() => fprint! (out, "S2RTt0ype()")
| ~S2RTvtype() => fprint! (out, "S2RTvtype()")
| ~S2RTvt0ype() => fprint! (out, "S2RTvt0ype()")
| ~S2RTprop() => fprint! (out, "S2RTprop()")
| ~S2RTview() => fprint! (out, "S2RTview()")
| ~S2RTtkind() => fprint! (out, "S2RTtkind()")
| ~S2RTfun
    (s2ts_arg, s2t_res) =>
  (
    fprint(out, "S2RTfun(");
    fprint_s2rtlst(ar, out, s2ts_arg);
    fprint(out, "; ");
    fprint_s2rt(ar, out, s2t_res); fprint(out, ")")
  ) (* end of [S2RTfun] *)
| ~S2RTnamed
    (sym) =>
  (
    fprint(out, "S2RTnamed(");
    fprint_symbol(ar, out, sym); fprint(out, ")")
  ) (* end of [S2RTnamed] *)
| ~S2RTerror
    ((*void*)) => fprint! (out, "S2RTerror()")
) (* end of [fprint_s2rt] *)

(* ****** ****** *)

implement
fprint_s2rtlst
  (ar, out, xs) = fprint_alist_sep(ar, out, xs, ", ", fprint_s2rt)

(* ****** ****** *)
//
typedef
s2rtdat_struct(l:addr) = @{
  s2rtdat_name= symbol(l)
, s2rtdat_stamp= stamp
, s2rtdat_sconlst= s2cstlst(l)
} (* end of [s2rtdat_struct] *)
//
(* ****** ****** *)

local
//
assume
s2rtdat_type(l:addr) = aref(l, s2rtdat_struct(l))
//
in (* in of [local] *)

implement
s2rtdat_make
  {l}(ar, name, stamp, s2cs) = let
//
var x: s2rtdat_struct(l)
val () = x.s2rtdat_name := name
val () = x.s2rtdat_stamp := stamp
val () = x.s2rtdat_sconlst := s2cs
//
in
  aref_make<s2rtdat_struct(l)>(ar, x)
end // end of [s2rtdat_make]

implement
s2rtdat_get_name
  {l}(ar, s2td) =
  (aref_get<s2rtdat_struct(l)>(ar, s2td)).s2rtdat_name
implement
s2rtdat_get_stamp
  {l}(ar, s2td) =
  (aref_get<s2rtdat_struct(l)>(ar, s2td)).s2rtdat_stamp
implement
s2rtdat_get_sconlst
  {l}(ar, s2td) =
  (aref_get<s2rtdat_struct(l)>(ar, s2td)).s2rtdat_sconlst

end // end of [local]

(* ****** ****** *)

implement
fprint_s2rtdat
  (ar, out, s2td) = let
  val name = s2rtdat_get_name(ar, s2td)
  val s2cs = s2rtdat_get_sconlst(ar, s2td)
in
  fprint_symbol(ar, out, name);
  fprint(out, "("); fprint_s2cstlst(ar, out, s2cs); fprint(out, ")")
end // end of [fprint_s2rtdat]

(* ****** ****** *)

(* end of [patsolve_cnstrnt_s2rt.dats] *)
