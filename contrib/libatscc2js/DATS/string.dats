(* ****** ****** *)
(*
** For writing ATS code
** that translates into Javascript
*)
(* ****** ****** *)

#define ATS_DYNLOADFLAG 0

(* ****** ****** *)
//
// HX-2014-08:
// prefix for external names
//
#define
ATS_EXTERN_PREFIX "ats2jspre_"
#define
ATS_STATIC_PREFIX "_ats2jspre_string_"
//
(* ****** ****** *)
//
#staload
UN =
"prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
#staload "./../basics_js.sats"
//
(* ****** ****** *)
//
#staload "./../SATS/integer.sats"
//
(* ****** ****** *)
//
#staload "./../SATS/string.sats"
#staload "./../SATS/JSarray.sats"
//
(* ****** ****** *)
//
#staload "./../SATS/stream_vt.sats"
//
#staload _(*STREAM_VT*) = "./stream_vt.dats"
//
(* ****** ****** *)

implement
strchr_code(c) = string_charCodeAt(c, 0)

(* ****** ****** *)

implement
string_fset_at
  {n}{i}
(
  str0, i0, c0
) = let
//
val n0 = string_length(str0)
val f0 = string_substring_beg_end(str0, 0, i0)
val r0 = string_substring_beg_end(str0, i0+1, n0)
//
in
  $UN.cast{string(n)}(string_concat_3(f0, c0, r0))
end // end of [string_fset_at]

(* ****** ****** *)
//
implement
string_exists_cloptr
  (str0, pred) = let
//
val
[n:int]
str = g1ofg0(str0)
val
len = string_length(str)
//
fun
loop
{i:nat|i <= n}
(
  i: int(i), pred: !cfun(strchr, bool)
) : bool =
(
if i < len
  then (if pred(str[i]) then true else loop(i+1, pred))
  else false
)
//
val ans = loop(0, pred)
//
in
  cfun_free(pred); ans
end (* end of [string_exists_cloptr] *)
//
//
(* ****** ****** *)
//
implement
string_forall_cloptr
  (str0, pred) = let
//
val
[n:int]
str = g1ofg0(str0)
val
len = string_length(str)
//
fun
loop
{i:nat|i <= n}
(
  i: int(i), pred: !cfun(strchr, bool)
) : bool =
(
if i < len
  then (if pred(str[i]) then loop(i+1, pred) else false)
  else true
)
//
val ans = loop(0, pred)
//
in
  cfun_free(pred); ans
end (* end of [string_forall_cloptr] *)
//
//
(* ****** ****** *)
//
implement
string_foreach_cloptr
  (str0, fwork) = let
//
val
[n:int]
str = g1ofg0(str0)
val
len = string_length(str)
//
fun
loop
{i:nat|i <= n}
(
  i: int(i), fwork: !cfun(strchr, void)
) : void =
(
if i < len
  then (fwork(str[i]); loop(i+1, fwork)) else ()
)
//
val () = loop(0, fwork)
//
in
  cfun_free(fwork)
end (* end of [string_foreach_cloptr] *)
//
//
(* ****** ****** *)
//
implement
string_tabulate_cloptr
  {n}
(
  len, fopr
) = // string_tabulate_cloptr
$UN.cast{string(n)}
(
  JSarray_join_sep(JSarray_tabulate_cloptr(len, fopr), "")
) (* end of [string_tabulate_cloptr] *)
//
(* ****** ****** *)

implement
streamize_string_code
  (str0) =
  auxmain(0) where
{
//
val
[n:int] str0 = g1ofg0(str0)
//
val len = string_length(str0)
//
fun
auxmain
{i:nat | i <= n}
(
  i: int(i)
) : stream_vt(int) = $ldelay
(
//
if i < len
  then
  stream_vt_cons
    (str0.charCodeAt(i), auxmain(i+1))
  // stream_vt_cons
  else stream_vt_nil((*void*))
//
) (* end of [auxmain] *)
//
} (* end of [streamize_string_code] *)

(* ****** ****** *)

implement
streamize_string_line
  (inp) = let
//
#define ENDL 10
//
val
[n:int]
inp = g1ofg0(inp)
//
val n = length(inp)
//
fun
auxmain
{i,j:nat
|i <= j; j <= n}
(
 i: int(i), j: int(j)
) : stream_vt(string) = $ldelay
(
if
(j < n)
then let
  val c0 = inp.charCodeAt(j)
in
  if
  (c0 != ENDL)
  then !(auxmain(i, j+1))
  else let
    val j1 = j + 1
    val line =
    string_substring_beg_end(inp, i, j)
  in
    stream_vt_cons(line, auxmain(j1, j1))
  end
end // end of [then]
else
(
//
  if
  (i = j)
  then
  stream_vt_nil((*void*))
  else
  stream_vt_sing(string_substring_beg_end(inp, i, j))
//
) (* end of [else] *)
) (* end of [auxmain] *)
//
in
  auxmain(0(*i*), 0(*j*))
end // end of [streamize_string_line]

(* ****** ****** *)

(* end of [string.dats] *)
