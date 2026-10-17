(* ****** ****** *)
(*
** Author: Hongwei Xi
** Start Time: May, 2013
** Authoremail: gmhwxiATgmailDOTcom
*)
(* ****** ****** *)
(*
** A quasi ML-style API in ATS for json-c
*)
(* ****** ****** *)
//
#staload
UN =
"prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

#staload "./../SATS/json.sats"
#staload "./../SATS/json_ML.sats"

(* ****** ****** *)

implement
print_jsonval(jsv) =
fprint_jsonval(stdout_ref, jsv)
implement
prerr_jsonval(jsv) =
fprint_jsonval(stderr_ref, jsv)

(* ****** ****** *)

//
// HX-2026-10: no GC (jsonvals are linear)
//
implement
jsonval_free(x0) =
(
case+ x0 of
| ~JSONnul() => ()
| ~JSONint(_) => ()
| ~JSONbool(_) => ()
| ~JSONfloat(_) => ()
| ~JSONstring(str) => strptr_free(str)
| ~JSONarray(xs) => auxlst(xs)
| ~JSONobject(lxs) => auxlablst(lxs)
) where
{
//
fun
auxlst(xs: jsonvalist): void =
(
case+ xs of
| ~list_vt_nil() => ()
| ~list_vt_cons(x, xs) => (jsonval_free(x); auxlst(xs))
)
//
fun
auxlablst(lxs: labjsonvalist): void =
(
case+ lxs of
| ~list_vt_nil() => ()
| ~list_vt_cons(lx, lxs) =>
  let
    val @(l, x) = lx
  in
    strptr_free(l); jsonval_free(x); auxlablst(lxs)
  end // end of [list_vt_cons]
)
//
} (* end of [jsonval_free] *)
//
(* ****** ****** *)
//
implement
jsonval_copy(x0) =
(
case+ x0 of
| JSONnul() => JSONnul()
| JSONint(i) => JSONint(i)
| JSONbool(b) => JSONbool(b)
| JSONfloat(d) => JSONfloat(d)
| JSONstring(str) => JSONstring(strptr1_copy(str))
| JSONarray(xs) => JSONarray(auxlst(xs))
| JSONobject(lxs) => JSONobject(auxlablst(lxs))
) where
{
//
fun
auxlst(xs: !jsonvalist): jsonvalist =
(
case+ xs of
| list_vt_nil() => list_vt_nil()
| list_vt_cons(x, xs1) =>
    list_vt_cons(jsonval_copy(x), auxlst(xs1))
)
//
fun
auxlablst(lxs: !labjsonvalist): labjsonvalist =
(
case+ lxs of
| list_vt_nil() => list_vt_nil()
| list_vt_cons(lx, lxs1) =>
    list_vt_cons
    ( @(strptr1_copy(lx.0), jsonval_copy(lx.1))
    , auxlablst(lxs1) )
)
//
} (* end of [jsonval_copy] *)
//
(* ****** ****** *)

implement
fprint_jsonval
  (out, jsv) =
(
case+ jsv of
| JSONnul() =>
    fprint!(out, "JSONnul(", ")")
| JSONint(lli) =>
    fprint!(out, "JSONint(", lli, ")")
| JSONbool(bool) =>
    fprint!(out, "JSONbool(", bool, ")")
| JSONfloat(dbl) =>
    fprint!(out, "JSONfloat(", dbl, ")")
| JSONstring(str) =>
  {
    val () = fprint(out, "JSONstring(")
    val () = fprint_strptr(out, str)
    val () = fprint(out, ")")
  }
| JSONarray(xs) =>
  {
    val () =
    fprint(out, "JSONarray(")
    val () =
    fprint_jsonvalist(out, xs)
    val ((*closing*)) = fprint(out, ")")
  }
| JSONobject(lxs) =>
  {
    val () =
    fprint(out, "JSONobject(")
    val () =
    fprint_labjsonvalist(out, lxs)
    val ((*closing*)) = fprint(out, ")")
  }
) (* end of [fprint_jsonval] *)

(* ****** ****** *)

implement
fprint_jsonvalist
  (out, xs) = let
//
fun
loop
(
xs: !jsonvalist, i0: int
) : void =
(
case+ xs of
| list_vt_nil() => ((*void*))
| list_vt_cons(x, xs1) => let
    val () =
    if i0 > 0 then fprint(out, "; ")
    val () = fprint_jsonval(out, x)
  in
    loop(xs1, i0+1)
  end // end of [list_vt_cons]
)
//
in
  loop (xs, 0(*i0*))
end // end of [fprint_jsonvalist]

(* ****** ****** *)

implement
fprint_labjsonvalist
  (out, lxs) = let
//
fun
loop
(
lxs: !labjsonvalist, i0: int
) : void =
(
case+ lxs of
| list_vt_nil() => ((*void*))
| list_vt_cons(lx, lxs1) => let
    val () =
    if i0 > 0 then fprint(out, "; ")
    val () = fprint_strptr(out, lx.0)
    val () = fprint(out, ": ")
    val () = fprint_jsonval(out, lx.1)
  in
    loop(lxs1, i0+1)
  end // end of [list_vt_cons]
)
//
in
  loop(lxs, 0(*i0*))
end // end of [fprint_labjsonvalist]

(* ****** ****** *)

implement
jsonval_ofstring(str) = let
  val jso =
  json_tokener_parse(str) in json_object2val0(jso)
end // end of [jsonval_ofstring]

(* ****** ****** *)

implement
jsonval_tostring
  (jsv) = rep2 where
{
  val jso =
  jsonval_objectify1(jsv)
  val
  (fpf | rep) =
  json_object_to_json_string(jso)
  val rep2 =
  string0_copy($UN.strptr2string(rep))
  prval ((*returned*)) = fpf(rep)
  val freed(*1*) = json_object_put(jso)
} (* end of [jsonval_tostring] *)

(* ****** ****** *)

implement
json_object2val0
  (jso) = let
  val jsv = json_object2val1(jso)
  val _(*int*) = json_object_put(jso) in jsv
end // end of [json_object2val0]

(* ****** ****** *)

implement
json_object2val1
  (jso) = let
//
extern
praxi
__assert_agz
  {l:addr}
(
x0: !json_object(l)
) : [l > null] void
//
val
type =
json_object_get_type(jso)
//
in
//
case+ 0 of
| _ when type =
    json_type_null => JSONnul()
| _ when type =
    json_type_int => let
  prval () = __assert_agz(jso)
    val i = json_object_get_int(jso)
  in
    JSONint($UN.cast2llint(i))
  end // end of [json_type_int]
| _ when type =
    json_type_boolean => let
  prval () = __assert_agz(jso)
    val tf = json_object_get_boolean(jso)
  in
    JSONbool(tf)
  end // end of [json_type_boolean]
| _ when type =
    json_type_double => let
  prval () = __assert_agz (jso)
    val dbl = json_object_get_double(jso)
  in
    JSONfloat(dbl)
  end // end of [json_type_double]
| _ when type =
    json_type_string => let
  prval () = __assert_agz(jso)
    val
    (fpf | str) =
    json_object_get_string(jso)
    val str2 = strptr1_copy(str)
  prval ((*returned*)) = fpf(str)
  in
    JSONstring(str2)
  end // end of [json_type_string]
| _ when type =
    json_type_array => let
//
    vtypedef
    tenv = ptr(* list_vt *)
//
  prval () = __assert_agz(jso)
//
    local
    implement
    json_object_iforeach$fwork<tenv>
      (i, v, env) =
    {
      val v2 = json_object2val1(v)
      val vs2 =
      $UN.castvwtp0{jsonvalist}(env)
      val () =
      (
        env :=
        $UN.castvwtp0{ptr}
        (list_vt_cons{jsonval}(v2, vs2))
      ) (* end of [val] *)
    }
    in (* in of [local] *)
    //
    var env: tenv = the_null_ptr
    val (_) =
    json_object_iforeach_env<tenv>(jso, env)
    val vs2 = $UN.castvwtp0{jsonvalist}(env)
    //
    end // end of [local]
  in
    JSONarray(list_vt_reverse(vs2))
  end // end of [json_type_array]
| _ when type =
    json_type_object => let
//
    typedef tenv = ptr
//
  prval () = __assert_agz (jso)
//
    local
    implement
    json_object_kforeach$fwork<tenv>
      (k, v, env) =
    {
      val k2 = strptr1_copy(k)
      val v2 = json_object2val1 (v)
      val kvs = $UN.castvwtp0{labjsonvalist}(env)
      val kvs = list_vt_cons{labjsonval}(@(k2, v2), kvs)
      val ((*void*)) = env := $UN.castvwtp0{ptr}(kvs)
    }
    in (* in of [local] *)
    //
    var env: tenv = the_null_ptr
    val (_) =
    json_object_kforeach_env<tenv>(jso, env)
    //
    end // end of [local]
//
    val kvs =
    $UN.castvwtp0{labjsonvalist}(env)
//
  in
    JSONobject(list_vt_reverse<labjsonval>(kvs))
  end // end of [json_type_object]
| _ (*deadcode*) =>
    let val () = assertloc (false) in JSONnul() end
//
end // end of [json_object2val1]

(* ****** ****** *)

implement
jsonval_objectify(jsv) = let
  val jso = jsonval_objectify1(jsv) in jsonval_free(jsv); jso
end // end of [jsonval_objectify]

(* ****** ****** *)

implement
jsonval_objectify1
  (jsv0) = let
//
fun
auxarr
(
  jarr:
 !json_object1
, jsvs: !jsonvalist
) : void =
(
  case+ jsvs of
  | list_vt_nil() => ((*void*))
  | list_vt_cons(jsv, jsvs1) => let
      val jso =
      jsonval_objectify1(jsv)
      val err =
      json_object_array_add(jarr, jso)
    in
      auxarr(jarr, jsvs1)
    end // end of [list_vt_cons]
)
//
fun
auxobj
(
  jobj:
 !json_object1
, ljsvs: !labjsonvalist
) : void =
(
  case+ ljsvs of
  | list_vt_nil() => ((*void*))
  | list_vt_cons(ljsv, ljsvs1) => let
      val jso =
      jsonval_objectify1(ljsv.1)
      val ((*void*)) =
      json_object_object_add(jobj, $UN.strptr2string(ljsv.0), jso)
    in
      auxobj(jobj, ljsvs1)
    end // end of [list_vt_cons]
)
//
in
//
case+ jsv0 of
| JSONnul() =>
    $UN.castvwtp0{json_object0}(the_null_ptr)
| JSONint(lli) =>
    json_object_new_int64($UN.cast{int64}(lli))
| JSONbool(tf) => json_object_new_boolean(tf)
| JSONfloat(dbl) => json_object_new_double(dbl)
| JSONstring(str) =>
    json_object_new_string($UN.strptr2string(str))
| JSONarray(jsvs) => let
    val jarr =
    json_object_new_array()
    val isnot =
    json_object_isnot_null(jarr)
    val ((*void*)) =
    if isnot then auxarr(jarr, jsvs)
  in
    jarr
  end // end of [JSONarray]
| JSONobject(ljsvs) => let
    val jobj =
    json_object_new_object()
    val isnot =
    json_object_isnot_null(jobj)
    val ((*void*)) =
    if isnot then auxobj(jobj, ljsvs)
  in
    jobj
  end // end of [JSONobject]
//
end // end of [jsonval_objectify1]

(* ****** ****** *)

(* end of [json_ML.dats] *)
