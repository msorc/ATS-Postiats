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
"patsolve_parsing__dynload"
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
#staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
#staload
"libats/SATS/arena.sats"
#staload
_(*anon*) = "libats/DATS/arena.dats"
//
#staload
"./../SATS/patsolve_cnstrnt.sats"
#staload
"./../SATS/patsolve_parsing.sats"
//
(* ****** ****** *)
//
// HX-2026-10:
// json-c is used directly (no GC)
//
%{^
//
#include <stdio.h>
#include <stdlib.h>
#include <json-c/json.h>
//
static
inline
void*
patsolve_json_parse_file(void *filr)
{
  FILE *inp = (FILE*)filr ;
  size_t n = 0, cap = 1 << 16, k ;
  char *buf = malloc(cap) ;
  struct json_tokener *tok ;
  struct json_object *jso ;
  if (!buf) return (void*)0 ;
  while ((k = fread(buf+n, 1, cap-n, inp)) > 0)
  {
    n += k ;
    if (n == cap)
    {
      char *buf2 = realloc(buf, 2*cap) ;
      if (!buf2) { free(buf) ; return (void*)0 ; }
      buf = buf2 ; cap = 2*cap ;
    }
  }
  tok = json_tokener_new_ex(1024/*depth*/) ;
  if (!tok) { free(buf) ; return (void*)0 ; }
  jso = json_tokener_parse_ex(tok, buf, (int)n) ;
  json_tokener_free(tok) ; free(buf) ;
  return jso ;
}
//
static
inline
void
patsolve_json_free(void *jso)
{
  json_object_put((struct json_object*)jso) ; return ;
}
//
static
inline
void*
patsolve_json_get_field(void *jso, char *key)
{
  struct json_object *res = 0 ;
  if (!json_object_is_type((struct json_object*)jso, json_type_object))
    return (void*)0 ;
  if (!json_object_object_get_ex((struct json_object*)jso, key, &res))
    return (void*)0 ;
  return res ;
}
//
static
inline
int
patsolve_json_is_object(void *jso)
{
  return json_object_is_type((struct json_object*)jso, json_type_object) ;
}
//
static
inline
char*
patsolve_json_first_key(void *jso)
{
  struct json_object_iterator it, itEnd ;
  it = json_object_iter_begin((struct json_object*)jso) ;
  itEnd = json_object_iter_end((struct json_object*)jso) ;
  if (json_object_iter_equal(&it, &itEnd)) return (char*)0 ;
  return (char*)json_object_iter_peek_name(&it) ;
}
//
static
inline
void*
patsolve_json_first_value(void *jso)
{
  struct json_object_iterator it, itEnd ;
  it = json_object_iter_begin((struct json_object*)jso) ;
  itEnd = json_object_iter_end((struct json_object*)jso) ;
  if (json_object_iter_equal(&it, &itEnd)) return (void*)0 ;
  return json_object_iter_peek_value(&it) ;
}
//
static
inline
int
patsolve_json_array_length(void *jso)
{
  if (!json_object_is_type((struct json_object*)jso, json_type_array))
    return -1 ;
  return (int)json_object_array_length((struct json_object*)jso) ;
}
//
static
inline
void*
patsolve_json_array_get(void *jso, int i)
{
  return json_object_array_get_idx((struct json_object*)jso, (size_t)i) ;
}
//
static
inline
int
patsolve_json_is_int(void *jso)
{
  return json_object_is_type((struct json_object*)jso, json_type_int) ;
}
static
inline
int
patsolve_json_get_int(void *jso)
{
  return (int)json_object_get_int64((struct json_object*)jso) ;
}
//
static
inline
int
patsolve_json_is_string(void *jso)
{
  return json_object_is_type((struct json_object*)jso, json_type_string) ;
}
static
inline
char*
patsolve_json_get_string(void *jso)
{
  return (char*)json_object_get_string((struct json_object*)jso) ;
}
//
%} // end of [%{^]
//
(* ****** ****** *)
//
assume jsonval_type = ptr
//
extern
fun
json_is_object
  (jsnv: jsonval): bool = "mac#patsolve_json_is_object"
extern
fun
json_first_key
  (jsnv: jsonval): ptr = "mac#patsolve_json_first_key"
extern
fun
json_first_value
  (jsnv: jsonval): jsonval = "mac#patsolve_json_first_value"
extern
fun
json_array_length
  (jsnv: jsonval): int = "mac#patsolve_json_array_length"
extern
fun
json_array_get
  (jsnv: jsonval, i: int): jsonval = "mac#patsolve_json_array_get"
extern
fun
json_is_int
  (jsnv: jsonval): bool = "mac#patsolve_json_is_int"
extern
fun
json_get_int
  (jsnv: jsonval): int = "mac#patsolve_json_get_int"
extern
fun
json_is_string
  (jsnv: jsonval): bool = "mac#patsolve_json_is_string"
extern
fun
json_get_string
  (jsnv: jsonval): string = "mac#patsolve_json_get_string"
//
(* ****** ****** *)
//
extern
fun
parse_error(msg: string): void
//
implement
parse_error
  (msg) =
(
  prerrln! ("patsolve: parsing error: ", msg); exit(1)
) (* end of [parse_error] *)
//
(* ****** ****** *)

implement
jsonval_is_null
  (jsnv) = (jsnv = the_null_ptr)

implement
jsonval_get_field
  (jsnv, key) =
  $extfcall(jsonval, "patsolve_json_get_field", jsnv, key)

(* ****** ****** *)
//
// HX: for a single-entry object {name: value}
//
extern
fun
jsonval_get_name(jsnv: jsonval): string
extern
fun
jsonval_get_value(jsnv: jsonval): jsonval
//
implement
jsonval_get_name
  (jsnv) = let
  val () =
  if ~json_is_object(jsnv)
    then parse_error("an object is expected")
  // end of [val]
  val p = json_first_key(jsnv)
  val () =
  if p = the_null_ptr
    then parse_error("a non-empty object is expected")
  // end of [val]
in
  $UN.cast{string}(p)
end // end of [jsonval_get_name]
//
implement
jsonval_get_value
  (jsnv) = json_first_value(jsnv)
//
(* ****** ****** *)
//
extern
fun
jsonval_get_field_exn
  (jsnv: jsonval, key: string): jsonval
//
implement
jsonval_get_field_exn
  (jsnv, key) = let
  val res = jsonval_get_field(jsnv, key)
  val () =
  if jsonval_is_null(res)
    then parse_error("the field is missing")
  // end of [val]
in
  res
end // end of [jsonval_get_field_exn]
//
(* ****** ****** *)
//
// HX: the i-th element of an array
//
extern
fun
jsonval_array_get
  (jsnv: jsonval, i: int): jsonval
//
implement
jsonval_array_get
  (jsnv, i) = let
  val n = json_array_length(jsnv)
  val () =
  if i >= n
    then parse_error("an array is expected (or too short)")
  // end of [val]
in
  json_array_get(jsnv, i)
end // end of [jsonval_array_get]
//
(* ****** ****** *)
//
implement
ahashtbl$hash<stamp>(x) = hash_stamp(x)
implement
ahashtbl$equal<stamp>(x1, x2) = (x1 = x2)
//
typedef
ptables_struct(l:addr) = @{
  symtbl= symtbl(l)
, s2cstmap= ahashtbl(l, stamp, s2cst(l))
, s2varmap= ahashtbl(l, stamp, s2var(l))
, s2Varmap= ahashtbl(l, stamp, s2Var(l))
, s2rtdatmap= s2rtdatlst(l)
} (* end of [ptables_struct] *)
//
(* ****** ****** *)

local
//
assume
ptables_type(l:addr) = aref(l, ptables_struct(l))
//
in (* in-of-local *)

implement
ptables_make_nil
  {l}(ar) = let
//
var x: ptables_struct(l)
val () = x.symtbl := symtbl_make_nil(ar)
val () =
x.s2cstmap :=
  ahashtbl_make_nil<stamp,s2cst(l)>(ar, i2sz(1024))
val () =
x.s2varmap :=
  ahashtbl_make_nil<stamp,s2var(l)>(ar, i2sz(1024))
val () =
x.s2Varmap :=
  ahashtbl_make_nil<stamp,s2Var(l)>(ar, i2sz(1024))
val () = x.s2rtdatmap := alist_nil()
//
in
  aref_make<ptables_struct(l)>(ar, x)
end // end of [ptables_make_nil]

(* ****** ****** *)

implement
ptables_get_symtbl
  {l}(ar, tbls) =
  (aref_get<ptables_struct(l)>(ar, tbls)).symtbl

(* ****** ****** *)
//
implement
the_s2cstmap_insert
  {l}(ar, tbls, s2c) = let
  val tbl =
  (aref_get<ptables_struct(l)>(ar, tbls)).s2cstmap
in
  ahashtbl_insert<stamp,s2cst(l)>
    (ar, tbl, s2cst_get_stamp(ar, s2c), s2c)
  // ahashtbl_insert
end // end of [the_s2cstmap_insert]
//
implement
the_s2cstmap_search
  {l}(ar, tbls, key) = let
  val tbl =
  (aref_get<ptables_struct(l)>(ar, tbls)).s2cstmap
in
  ahashtbl_search<stamp,s2cst(l)>(ar, tbl, key)
end // end of [the_s2cstmap_search]
//
implement
the_s2cstmap_listize
  {l}(ar, tbls) = let
//
typedef kx = @(stamp, s2cst(l))
//
val tbl =
  (aref_get<ptables_struct(l)>(ar, tbls)).s2cstmap
val kxs =
  ahashtbl_listize<stamp,s2cst(l)>(ar, tbl)
//
implement
list_vt_mergesort$cmp<kx>
  (kx1, kx2) = $effmask_all(compare(kx1.0, kx2.0))
//
val kxs = list_vt_mergesort<kx>(kxs)
//
fun
proj
(
  kxs: List0_vt(kx), res: s2cstlst_vt(l)
) : s2cstlst_vt(l) =
(
case+ kxs of
| ~list_vt_nil() => list_vt_reverse(res)
| ~list_vt_cons(kx, kxs) => proj(kxs, list_vt_cons(kx.1, res))
) (* end of [proj] *)
//
in
  proj(kxs, list_vt_nil())
end // end of [the_s2cstmap_listize]
//
(* ****** ****** *)
//
implement
the_s2varmap_insert
  {l}(ar, tbls, s2v) = let
  val tbl =
  (aref_get<ptables_struct(l)>(ar, tbls)).s2varmap
in
  ahashtbl_insert<stamp,s2var(l)>
    (ar, tbl, s2var_get_stamp(ar, s2v), s2v)
  // ahashtbl_insert
end // end of [the_s2varmap_insert]
//
implement
the_s2varmap_search
  {l}(ar, tbls, key) = let
  val tbl =
  (aref_get<ptables_struct(l)>(ar, tbls)).s2varmap
in
  ahashtbl_search<stamp,s2var(l)>(ar, tbl, key)
end // end of [the_s2varmap_search]
//
(* ****** ****** *)
//
implement
the_s2Varmap_insert
  {l}(ar, tbls, s2V) = let
  val tbl =
  (aref_get<ptables_struct(l)>(ar, tbls)).s2Varmap
in
  ahashtbl_insert<stamp,s2Var(l)>
    (ar, tbl, s2Var_get_stamp(ar, s2V), s2V)
  // ahashtbl_insert
end // end of [the_s2Varmap_insert]
//
implement
the_s2Varmap_search
  {l}(ar, tbls, key) = let
  val tbl =
  (aref_get<ptables_struct(l)>(ar, tbls)).s2Varmap
in
  ahashtbl_search<stamp,s2Var(l)>(ar, tbl, key)
end // end of [the_s2Varmap_search]
//
(* ****** ****** *)
//
implement
the_s2rtdatmap_get
  {l}(ar, tbls) =
  (aref_get<ptables_struct(l)>(ar, tbls)).s2rtdatmap
//
implement
the_s2rtdatmap_set
  {l}(ar, tbls, s2tds) = let
  var x = aref_get<ptables_struct(l)>(ar, tbls)
  val () = x.s2rtdatmap := s2tds
in
  aref_set<ptables_struct(l)>(ar, tbls, x)
end // end of [the_s2rtdatmap_set]
//
end // end of [local]

(* ****** ****** *)

implement
parse_int
  (jsnv0) = let
  val () =
  if ~json_is_int(jsnv0)
    then parse_error("an integer is expected")
  // end of [val]
in
  json_get_int(jsnv0)
end // end of [parse_int]

implement
parse_string
  (jsnv0) = let
  val () =
  if ~json_is_string(jsnv0)
    then parse_error("a string is expected")
  // end of [val]
in
  json_get_string(jsnv0)
end // end of [parse_string]

implement
parse_stamp
  (jsnv0) = stamp_make(parse_int(jsnv0))

(* ****** ****** *)

implement
parse_symbol
  (ar, tbls, jsnv0) =
symbol_make_name
(
  ar, ptables_get_symtbl(ar, tbls), parse_string(jsnv0)
) (* end of [parse_symbol] *)

implement
parse_location
  (ar, tbls, jsnv0) = location_make(ar, parse_string(jsnv0))

(* ****** ****** *)

implement
parse_tyreckind
  (ar, tbls, jsnv0) = let
//
val name = jsonval_get_name(jsnv0)
val jsnv2 = jsonval_get_value(jsnv0)
//
in
//
case+ name of
| "TYRECKINDbox" => tyreckind_TYRECKINDbox(ar)
| "TYRECKINDbox_lin" => tyreckind_TYRECKINDbox_lin(ar)
| "TYRECKINDflt0" => tyreckind_TYRECKINDflt0(ar)
| "TYRECKINDflt1" =>
    tyreckind_TYRECKINDflt1(ar, parse_stamp(jsnv2))
| "TYRECKINDflt_ext" =>
    tyreckind_TYRECKINDflt_ext
      (ar, astring_make(ar, parse_string(jsnv2)))
| _(*unrecognized*) => let
    val () =
      prerrln! ("parse_tyreckind: name = ", name)
    // end of [val]
  in
    exit(1)
  end // end of [_(*unrecognized*)]
//
end // end of [parse_tyreckind]

(* ****** ****** *)

implement
{a}(*tmp*)
parse_list
  {l}(ar, tbls, jsnv0, f) = let
//
val n = json_array_length(jsnv0)
val () =
if n < 0
  then parse_error("an array is expected")
// end of [val]
//
fun
loop
(
  ar: !arena(l), i: int, res: alist(l, a)
) : alist(l, a) =
(
if
i > 0
then let
  val x =
  f(ar, tbls, json_array_get(jsnv0, i-1))
in
  loop(ar, i-1, alist_cons<a>(ar, x, res))
end // end of [then]
else res // end of [else]
) (* end of [loop] *)
//
in
  loop(ar, n, alist_nil())
end // end of [parse_list]

(* ****** ****** *)
//
implement
parse_s2rtlst{l}(ar, tbls, xs) =
  parse_list<s2rt(l)>(ar, tbls, xs, parse_s2rt)
implement
parse_s2rtdatlst{l}(ar, tbls, xs) =
  parse_list<s2rtdat(l)>(ar, tbls, xs, parse_s2rtdat)
//
implement
parse_s2cstlst{l}(ar, tbls, xs) =
  parse_list<s2cst(l)>(ar, tbls, xs, parse_s2cst)
implement
parse_s2varlst{l}(ar, tbls, xs) =
  parse_list<s2var(l)>(ar, tbls, xs, parse_s2var)
//
implement
parse_s2explst{l}(ar, tbls, xs) =
  parse_list<s2exp(l)>(ar, tbls, xs, parse_s2exp)
implement
parse_labs2explst{l}(ar, tbls, xs) =
  parse_list<labs2exp(l)>(ar, tbls, xs, parse_labs2exp)
//
implement
parse_s3itmlst{l}(ar, tbls, xs) =
  parse_list<s3itm(l)>(ar, tbls, xs, parse_s3itm)
implement
parse_s3itmlstlst{l}(ar, tbls, xs) =
  parse_list<s3itmlst(l)>(ar, tbls, xs, parse_s3itmlst)
//
(* ****** ****** *)

implement
parse_c3nstropt
  (ar, tbls, jsnv0) = let
  val n = json_array_length(jsnv0)
  val () =
  if n < 0
    then parse_error("an array is expected")
  // end of [val]
in
  if n = 0
    then c3nstropt_C3NSTRnone(ar)
    else c3nstropt_C3NSTRsome
      (ar, parse_c3nstr(ar, tbls, json_array_get(jsnv0, 0)))
    // end of [else]
  // end of [if]
end // end of [parse_c3nstropt]

(* ****** ****** *)

local
//
fun
aux_s2cstmap
  {l:addr}
(
  ar: !arena(l)
, tbls: ptables(l), jsnv: jsonval
) : void =
(
if
~jsonval_is_null(jsnv)
then let
//
val n = json_array_length(jsnv)
//
fun
loop
(
  ar: !arena(l), i: int
) : void =
  if i < n then
  (
    ignoret(parse_s2cst(ar, tbls, json_array_get(jsnv, i)));
    loop(ar, i+1)
  ) (* end of [if] *)
//
in
  loop(ar, 0)
end // end of [then]
) (* end of [aux_s2cstmap] *)
//
fun
aux_s2varmap
  {l:addr}
(
  ar: !arena(l)
, tbls: ptables(l), jsnv: jsonval
) : void =
(
if
~jsonval_is_null(jsnv)
then let
//
val n = json_array_length(jsnv)
//
fun
loop
(
  ar: !arena(l), i: int
) : void =
  if i < n then
  (
    ignoret(parse_s2var(ar, tbls, json_array_get(jsnv, i)));
    loop(ar, i+1)
  ) (* end of [if] *)
//
in
  loop(ar, 0)
end // end of [then]
) (* end of [aux_s2varmap] *)
//
fun
aux_s2rtdatmap
  {l:addr}
(
  ar: !arena(l)
, tbls: ptables(l), jsnv: jsonval
) : void =
(
if
~jsonval_is_null(jsnv)
then
the_s2rtdatmap_set
  (ar, tbls, parse_s2rtdatlst(ar, tbls, jsnv))
// end of [then]
) (* end of [aux_s2rtdatmap] *)
//
in (* in-of-local *)

implement
parse_constraints
  (ar, tbls, jsnv0) = let
//
val () =
aux_s2cstmap
  (ar, tbls, jsonval_get_field(jsnv0, "s2cstmap"))
val () =
aux_s2varmap
  (ar, tbls, jsonval_get_field(jsnv0, "s2varmap"))
val () =
aux_s2rtdatmap
  (ar, tbls, jsonval_get_field(jsnv0, "s2rtdatmap"))
//
in
  parse_c3nstr
    (ar, tbls, jsonval_get_field_exn(jsnv0, "c3nstrbody"))
  // parse_c3nstr
end // end of [parse_constraints]

end // end of [local]

(* ****** ****** *)

implement
parse_fileref_constraints
  (ar, tbls, inp) = let
//
val jso =
$extfcall
( jsonval
, "patsolve_json_parse_file", $UN.cast{ptr}(inp)
) (* $extfcall *)
//
val () =
if jsonval_is_null(jso)
  then parse_error("the input is not valid JSON")
//
val c3t0 = parse_constraints(ar, tbls, jso)
//
in
  $extfcall(void, "patsolve_json_free", jso); c3t0
end // end of [parse_fileref_constraints]

(* ****** ****** *)
//
local
#include
"./PARSING/patsolve_parsing_label.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./PARSING/patsolve_parsing_s2rt.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./PARSING/patsolve_parsing_s2cst.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./PARSING/patsolve_parsing_s2var.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./PARSING/patsolve_parsing_s2vvar.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./PARSING/patsolve_parsing_s2exp.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./PARSING/patsolve_parsing_s3itm.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./PARSING/patsolve_parsing_h3ypo.dats" in (*nothing*)
end // end of [local]
//
local
#include
"./PARSING/patsolve_parsing_c3nstr.dats" in (*nothing*)
end // end of [local]
//
(* ****** ****** *)

(* end of [patsolve_parsing.dats] *)
