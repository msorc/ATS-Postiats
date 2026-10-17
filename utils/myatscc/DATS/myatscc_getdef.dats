(*
** HX-2017-04-22:
** For locating myatsccdef
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
#staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)

#staload "./../SATS/myatscc.sats"

(* ****** ****** *)

local

(* ****** ****** *)
//
// HX-2026-10:
// [pfx] is a prefix of [str]
//
fun
string_is_prefix
(
  pfx: string, str: string
) : bool = let
//
fun
loop
(
  p1: ptr, p2: ptr
) : bool = let
  val c1 = $UN.ptr0_get<char>(p1)
in
  if
  isneqz(c1)
  then
  (
    if c1 = $UN.ptr0_get<char>(p2)
      then loop(ptr0_succ<char>(p1), ptr0_succ<char>(p2)) else false
    // end of [if]
  )
  else true
end // end of [loop]
//
in
  loop(string2ptr(pfx), string2ptr(str))
end // end of [string_is_prefix]
//
fun
substr
(p0: ptr, i: int, j: int): Strptr1 = let
//
val ln = $UN.cast{size_t}(j - i)
val ln = g1ofg0(ln)
val (pf, pfgc | p1) = malloc_gc(succ(ln))
val _(*p1*) =
  $extfcall(ptr, "memcpy", p1, ptr_add<char>(p0, i), ln)
val () = $UN.ptr0_set<char>(ptr_add<char>(p1, j-i), '\000')
//
in
  $UN.castvwtp0{Strptr1}((pf, pfgc | p1))
end // end of [substr]
//
(* ****** ****** *)
//
// HX: the position right after the first
// occurrence of [key] in [line] (or -1)
//
fun
auxfind_key
(
  line: string, key: string
) : int = let
//
val n = g0u2i(string_length(line))
val k = g0u2i(string_length(key))
val p0 = string2ptr(line)
//
fun
loop(i: int): int =
(
if
(i + k <= n)
then
(
  if
  string_is_prefix
  (key, $UN.cast{string}(ptr_add<char>(p0, i)))
  then (i + k) else loop(i+1)
)
else ~1
) (* end of [loop] *)
//
in
  loop(0)
end // end of [auxfind_key]
//
fun
auxsuffix
(
  line: string, i: int
) : Strptr1 =
  string0_copy($UN.cast{string}(ptr_add<char>(string2ptr(line), i)))
//
(* ****** ****** *)
//
(*
HX:
A definition is continued onto the next line
if it is empty or it ends with a backslash
(which is then removed)
*)
fun
auxcont
(
  inp: FILEref, def: Strptr1
) : Strptr1 = let
//
val def0 = $UN.strptr2string(def)
val n = g0u2i(string_length(def0))
//
val iscont =
(
  if n = 0
    then true
    else ($UN.ptr0_get<char>(ptr_add<char>(string2ptr(def0), n-1)) = '\\')
  // end of [if]
) : bool // end of [val]
//
in
//
if
iscont
then let
//
val def2 =
(
if n > 0
  then
  substr(string2ptr(def0), 0, n-1)
  else string0_copy("")
) : Strptr1 // end of [val]
val () = strptr_free(def)
//
in
//
if
fileref_is_eof(inp)
then def2
else let
  val line =
    fileref_get_line_string(inp)
  val def3 =
    string0_append
    ($UN.strptr2string(def2), $UN.strptr2string(line))
  // end of [val]
  val () = strptr_free(def2)
  val () = strptr_free(line)
in
  auxcont(inp, $UN.castvwtp0{Strptr1}(def3))
end // end of [else]
//
end // end of [then]
else def // end of [else]
//
end // end of [auxcont]
//
(* ****** ****** *)
//
fun
auxfind
(
  inp: FILEref
) : Option_vt(Strptr1) =
(
if
fileref_isnot_eof(inp)
then let
  val line =
    fileref_get_line_string(inp)
  val line0 = $UN.strptr2string(line)
  val i = auxfind_key(line0, MYATSCCDEF_key)
in
  if
  (i >= 0)
  then let
    val def = auxsuffix(line0, i)
    val () = strptr_free(line)
  in
    Some_vt(auxcont(inp, def))
  end // end of [then]
  else let
    val () = strptr_free(line) in auxfind(inp)
  end // end of [else]
end // end of [then]
else None_vt(*void*) // end of [else]
) (* end of [auxfind] *)
//
(* ****** ****** *)
//
fun
arglst_get1
{n:int}
(
  args: !list_vt(Strptr1, n)
) : Option_vt(Strptr1) =
(
case+ args of
| list_vt_nil() => None_vt()
| @list_vt_cons(_, args1) => let
    val res =
    (
    case+ args1 of
    | list_vt_nil() => None_vt()
    | @list_vt_cons(x, _) => let
        val res = Some_vt(strptr1_copy(x))
      in
        fold@(args1); res
      end // end of [list_vt_cons]
    ) : Option_vt(Strptr1)
  in
    fold@(args); res
  end // end of [list_vt_cons]
) (* end of [arglst_get1] *)
//
(* ****** ****** *)

in (* in-of-local *)

(* ****** ****** *)

implement
myatscc_getdef
  (args) = let
//
val opt = arglst_get1(args)
//
in
//
case+ opt of
| ~None_vt() =>
    string0_copy(MYATSCCDEF_def)
  // end of [None_vt]
| ~Some_vt(name) => let
    val opt =
    fileref_open_opt
      ($UN.strptr2string(name), file_mode_r)
    // end of [val]
    val () = strptr_free(name)
  in
    case+ opt of
    | ~None_vt() =>
        string0_copy(MYATSCCDEF_def)
      // end of [None_vt]
    | ~Some_vt(inp) => let
        val res = auxfind(inp)
        val () = fileref_close(inp)
      in
        case+ res of
        | ~Some_vt(def) => def
        | ~None_vt() => string0_copy(MYATSCCDEF_def)
      end // end of [Some_vt]
  end // end of [Some_vt]
//
end // end of [myatscc_getdef]

(* ****** ****** *)

end // end of [local]

(* ****** ****** *)

(* end of [myatscc_getdef.dats] *)
