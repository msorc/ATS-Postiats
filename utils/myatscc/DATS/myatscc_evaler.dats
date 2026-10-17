(* ****** ****** *)
(*
** HX-2017-04-22:
** For evaluating MYATSCCDEF
*)
(* ****** ****** *)
//
// HX-2026-10: no GC
// The definition is expanded directly: each
// $-construct is parsed into a (linear) [mexp],
// which is evaluated into a (linear) [gval]
// and then freed.
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
#staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
#staload "./../SATS/myatscc.sats"
//
(* ****** ****** *)
//
datavtype
mexp =
//
| MEstr of Strptr1 // an identifier
| MEint of int // an integer
| MEchr of char // any other character
//
| MEarg of int // $N
| MEname of Strptr1 // $name
| MEcall of (Strptr1, mexplst) // $name(...)
//
where mexplst = List0_vt(mexp)
//
datavtype
gval =
| GVnil of ()
| GVint of int
| GVchr of char
| GVstr of Strptr1
//
vtypedef gvals = List0_vt(gval)
vtypedef chars = List0_vt(char)
//
(* ****** ****** *)
//
fun
mexp_free(e: mexp): void =
(
case+ e of
| ~MEstr(s) => strptr_free(s)
| ~MEint _ => ()
| ~MEchr _ => ()
| ~MEarg _ => ()
| ~MEname(s) => strptr_free(s)
| ~MEcall(s, es) => (strptr_free(s); mexplst_free(es))
) (* end of [mexp_free] *)
//
and
mexplst_free(es: mexplst): void =
(
case+ es of
| ~list_vt_nil() => ()
| ~list_vt_cons(e, es) => (mexp_free(e); mexplst_free(es))
) (* end of [mexplst_free] *)
//
fun
gval_free(gv: gval): void =
(
case+ gv of
| ~GVnil() => ()
| ~GVint _ => ()
| ~GVchr _ => ()
| ~GVstr(s) => strptr_free(s)
) (* end of [gval_free] *)
//
fun
gvals_free(gvs: gvals): void =
(
case+ gvs of
| ~list_vt_nil() => ()
| ~list_vt_cons(gv, gvs) => (gval_free(gv); gvals_free(gvs))
) (* end of [gvals_free] *)
//
(* ****** ****** *)
//
fun
chr_at
(p0: ptr, i: int): char =
  $UN.ptr0_get<char>(ptr_add<char>(p0, i))
//
fun
idfst_test(c: char): bool =
  isalpha(c) orelse (c = '_')
fun
idrst_test(c: char): bool =
  isalnum(c) orelse (c = '_')
//
fun
scan_ident
(p0: ptr, i: int, n: int): int =
(
if
(i < n)
then
(
if idrst_test(chr_at(p0, i))
  then scan_ident(p0, i+1, n) else i
// end of [if]
)
else (i)
) (* end of [scan_ident] *)
//
fun
scan_int
(p0: ptr, i: int, n: int): int =
(
if
(i < n)
then
(
if isdigit(chr_at(p0, i))
  then scan_int(p0, i+1, n) else i
// end of [if]
)
else (i)
) (* end of [scan_int] *)
//
fun
read_int
(p0: ptr, i: int, j: int, res: int): int =
(
if
(i < j)
then
read_int
(p0, i+1, j, 10*res + (chr_at(p0, i) - '0'))
else (res)
) (* end of [read_int] *)
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
fun
skip_space
(p0: ptr, i: int, n: int): int =
(
if
(i < n)
then let
  val c = chr_at(p0, i)
in
  if (c = ' ' orelse c = '\t')
    then skip_space(p0, i+1, n) else i
  // end of [if]
end // end of [then]
else (i)
) (* end of [skip_space] *)
//
(* ****** ****** *)
//
vtypedef
mexp_res = Option_vt(@(mexp, int))
vtypedef
mexplst_res = Option_vt(@(mexplst, int))
//
(* ****** ****** *)
//
fun
parse_exp
(
  p0: ptr, i: int, n: int
) : mexp_res = let
//
val c = chr_at(p0, i)
//
in
//
ifcase
//
| (i >= n) => None_vt()
//
| (c = '$') => let
    val i1 = i+1
    val c1 =
      (if i1 < n then chr_at(p0, i1) else '\000'): char
    // end of [val]
  in
    ifcase
    | isdigit(c1) => let
        val j = scan_int(p0, i1, n)
      in
        Some_vt(@(MEarg(read_int(p0, i1, j, 0)), j))
      end // end of [isdigit]
    | idfst_test(c1) => let
        val j = scan_ident(p0, i1, n)
        val name = substr(p0, i1, j)
      in
        if
        (j < n)
        then
        (
          if
          (chr_at(p0, j) = '\(')
          then let
            val opt =
              parse_args(p0, j+1, n)
            // end of [val]
          in
            case+ opt of
            | ~Some_vt(esk) =>
                Some_vt(@(MEcall(name, esk.0), esk.1))
              // end of [Some_vt]
            | ~None_vt((*void*)) => Some_vt(@(MEname(name), j))
          end // end of [then]
          else Some_vt(@(MEname(name), j))
        )
        else Some_vt(@(MEname(name), j))
      end // end of [idfst_test]
    | _(*else*) => Some_vt(@(MEchr(c), i1))
  end // end of [c = '$']
//
| (c = '\\') => let
    val i1 = i+1
  in
    if
    (i1 < n)
    then let
      val c1 = chr_at(p0, i1)
    in
      if idrst_test(c1)
        then Some_vt(@(MEchr(c), i1))
        else Some_vt(@(MEchr(c1), i1+1))
      // end of [if]
    end // end of [then]
    else Some_vt(@(MEchr(c), i1))
  end // end of [c = '\\']
//
| idfst_test(c) => let
    val j = scan_ident(p0, i, n)
  in
    Some_vt(@(MEstr(substr(p0, i, j)), j))
  end // end of [idfst_test]
//
| isdigit(c) => let
    val j = scan_int(p0, i, n)
  in
    Some_vt(@(MEint(read_int(p0, i, j, 0)), j))
  end // end of [isdigit]
//
| _(*else*) => Some_vt(@(MEchr(c), i+1))
//
end // end of [parse_exp]
//
(*
HX: [i] is right after the left parenthesis;
the arguments are separated by commas and possibly
surrounded with spaces; the argument list cannot
be empty (as in the original implementation)
*)
and
parse_args
(
  p0: ptr, i: int, n: int
) : mexplst_res = let
//
fun
loop
(
  i: int, res: mexplst
) : mexplst_res = let
  val i = skip_space(p0, i, n)
  val opt = parse_exp(p0, i, n)
in
//
case+ opt of
| ~None_vt() =>
    (mexplst_free(res); None_vt())
  // end of [None_vt]
| ~Some_vt(ej) => let
    val res = list_vt_cons(ej.0, res)
    val j = skip_space(p0, ej.1, n)
  in
    if
    (j < n)
    then let
      val c = chr_at(p0, j)
    in
      ifcase
      | (c = ',') => loop(j+1, res)
      | (c = ')') =>
          Some_vt(@(list_vt_reverse(res), j+1))
        // end of [')']
      | _(*else*) =>
          (mexplst_free(res); None_vt())
        // end of [else]
    end // end of [then]
    else (mexplst_free(res); None_vt())
  end // end of [Some_vt]
//
end // end of [loop]
//
in
  loop(i, list_vt_nil())
end // end of [parse_args]
//
(* ****** ****** *)
//
fun
undefined
(name: string): void =
  prerrln!("**ERROR**:", "UNDEFINED($", name, ")")
//
fun
arglst_get
{n:int}
(
  args: !list_vt(Strptr1, n), k: int
) : Option_vt(Strptr1) =
(
case+ args of
| list_vt_nil() => None_vt()
| @list_vt_cons(x, args1) => let
    val res =
    (
      if k > 0
        then arglst_get(args1, k-1)
        else Some_vt(strptr1_copy(x))
      // end of [if]
    ) : Option_vt(Strptr1)
  in
    fold@(args); res
  end // end of [list_vt_cons]
) (* end of [arglst_get] *)
//
(* ****** ****** *)
//
fun
gvals_get_str
{n:int}
(
  gvs: !list_vt(gval, n), k: int
) : Option_vt(Strptr1) =
(
case+ gvs of
| list_vt_nil() => None_vt()
| @list_vt_cons(gv, gvs1) => let
    val res =
    (
    if
    (k > 0)
    then gvals_get_str(gvs1, k-1)
    else
    (
      case+ gv of
      | GVstr(s) =>
          Some_vt(string0_copy($UN.strptr2string(s)))
        // end of [GVstr]
      | _(*non-GVstr*) => None_vt()
    )
    ) : Option_vt(Strptr1)
  in
    fold@(gvs); res
  end // end of [list_vt_cons]
) (* end of [gvals_get_str] *)
//
fun
gvals_get_int
{n:int}
(
  gvs: !list_vt(gval, n), k: int
) : Option_vt(int) =
(
case+ gvs of
| list_vt_nil() => None_vt()
| @list_vt_cons(gv, gvs1) => let
    val res =
    (
    if
    (k > 0)
    then gvals_get_int(gvs1, k-1)
    else
    (
      case+ gv of
      | GVint(i) => Some_vt(i) | _(*non-GVint*) => None_vt()
    )
    ) : Option_vt(int)
  in
    fold@(gvs); res
  end // end of [list_vt_cons]
) (* end of [gvals_get_int] *)
//
(* ****** ****** *)
//
// $fname(path): the path without its extension
// $fname_ext(path): the extension of the path
//
fun
fname
{n:int}
(
  gvs: !list_vt(gval, n)
) : gval =
(
case+
gvals_get_str(gvs, 0)
of // case+
| ~None_vt() => GVnil()
| ~Some_vt(fnm) => let
    val fnm0 = $UN.strptr2string(fnm)
    val fnm0 = g1ofg0(fnm0)
    val pos = $UN.cast{int}(strrchr(fnm0, '.'))
  in
    if
    (pos < 0)
    then GVstr(fnm)
    else let
      val res =
        substr(string2ptr(fnm0), 0, pos)
      // end of [val]
      val () = strptr_free(fnm)
    in
      GVstr(res)
    end // end of [else]
  end // end of [Some_vt]
) (* end of [fname] *)
//
fun
fname_ext
{n:int}
(
  gvs: !list_vt(gval, n)
) : gval =
(
case+
gvals_get_str(gvs, 0)
of // case+
| ~None_vt() => GVnil()
| ~Some_vt(fnm) => let
    val fnm0 = $UN.strptr2string(fnm)
    val fnm0 = g1ofg0(fnm0)
    val len = g0u2i(strlen(fnm0))
    val pos = $UN.cast{int}(strrchr(fnm0, '.'))
    val res =
    (
    if
    (pos < 0)
    then string0_copy("")
    else
    (
      if
      (pos < len)
      then substr(string2ptr(fnm0), pos+1, len)
      else string0_copy("")
    )
    ) : Strptr1 // end of [val]
    val () = strptr_free(fnm)
  in
    GVstr(res)
  end // end of [Some_vt]
) (* end of [fname_ext] *)
//
(*
HX:
$arglst(i): the arguments from $i on
$arglst(i, j): the arguments from $i to $(j-1)
They are separated by spaces.
*)
fun
arglst_concat
{n:int}
(
  args: !list_vt(Strptr1, n)
, i1: int, i2: int // HX: i2 < 0: no upper bound
) : gval = let
//
fun
loop
{n:int}
(
  args: !list_vt(Strptr1, n)
, k: int, res: chars, first: bool
) : chars =
(
case+ args of
| list_vt_nil() => res
| @list_vt_cons(x, args1) => let
    val res =
    (
    if
    (k < i1)
    then loop(args1, k+1, res, first)
    else
    (
    if
    (i2 >= 0 && k >= i2)
    then res
    else let
      val res =
      (
        if first then res else list_vt_cons(' ', res)
      ) : chars
      val res = chars_push(res, $UN.strptr2string(x))
    in
      loop(args1, k+1, res, false)
    end // end of [else]
    )
    ) : chars
  in
    fold@(args); res
  end // end of [list_vt_cons]
) (* end of [loop] *)
//
and
chars_push
(
  res: chars, s: string
) : chars = let
  val n = g0u2i(string_length(s))
  fun
  aux
  (
    res: chars, i: int
  ) : chars =
  (
    if i < n
      then aux(list_vt_cons(chr_at(string2ptr(s), i), res), i+1)
      else res
  ) (* end of [aux] *)
in
  aux(res, 0)
end // end of [chars_push]
//
val cs = loop(args, 0, list_vt_nil(), true)
//
in
  GVstr
  (
  $UN.castvwtp0{Strptr1}
  (
    string_make_rlist_vt
      ($UN.castvwtp0{List0_vt(charNZ)}(cs))
  )
  )
end // end of [arglst_concat]
//
fun
arglst
{n,m:int}
(
  gvs: !list_vt(gval, n)
, args: !list_vt(Strptr1, m)
) : gval = let
//
val opt1 = gvals_get_int(gvs, 0)
val ngv = list_vt_length(gvs)
//
in
//
case+ opt1 of
| ~None_vt() => GVnil()
| ~Some_vt(i1) =>
  (
    if
    (ngv <= 1)
    then arglst_concat(args, i1, ~1)
    else
    (
      case+
      gvals_get_int(gvs, 1)
      of // case+
      | ~None_vt() => GVnil()
      | ~Some_vt(i2) =>
          arglst_concat(args, i1, (if i2 >= 0 then i2 else 0))
        // end of [Some_vt]
    )
  )
//
end // end of [arglst]
//
(* ****** ****** *)
//
fun
mexp_eval
{n:int}
(
  e: !mexp
, args: !list_vt(Strptr1, n)
) : gval =
(
case+ e of
| @MEstr(s) => let
    val res =
      GVstr(strptr1_copy(s))
    // end of [val]
  in
    fold@(e); res
  end // end of [MEstr]
| MEint(i) => GVint(i)
| MEchr(c) => GVchr(c)
| MEarg(k) =>
  (
    case+
    arglst_get(args, k)
    of // case+
    | ~Some_vt(x) => GVstr(x)
    | ~None_vt() =>
        GVnil() where
      {
        val () =
        prerrln!("**ERROR**:", "UNDEFINED($", k, ")")
      } (* end of [None_vt] *)
  )
| @MEname(s) => let
    val () =
      undefined($UN.strptr2string(s))
    // end of [val]
  in
    fold@(e); GVnil()
  end // end of [MEname]
| @MEcall(s, es) => let
    val gvs = mexplst_eval(es, args)
    val name = $UN.strptr2string(s)
    val res =
    (
      ifcase
      | name = "fname" => fname(gvs)
      | name = "fname_ext" => fname_ext(gvs)
      | name = "arglst" => arglst(gvs, args)
      | _(*else*) => (undefined(name); GVnil())
    ) : gval // end of [val]
    val () = gvals_free(gvs)
  in
    fold@(e); res
  end // end of [MEcall]
) (* end of [mexp_eval] *)
//
and
mexplst_eval
{n:int}
(
  es: !mexplst
, args: !list_vt(Strptr1, n)
) : gvals =
(
case+ es of
| list_vt_nil() => list_vt_nil()
| @list_vt_cons(e, es1) => let
    val gv = mexp_eval(e, args)
    val gvs = mexplst_eval(es1, args)
  in
    fold@(es); list_vt_cons(gv, gvs)
  end // end of [list_vt_cons]
) (* end of [mexplst_eval] *)
//
(* ****** ****** *)
//
fun
gval_emit
(
  gv: gval, res: chars
) : chars =
(
case+ gv of
| ~GVnil() => res
| ~GVint(i) => let
    val s = tostrptr_int(i)
    val res =
      chars_push(res, $UN.strptr2string(s))
    // end of [val]
  in
    strptr_free(s); res
  end // end of [GVint]
| ~GVchr(c) => list_vt_cons(c, res)
| ~GVstr(s) => let
    val res =
      chars_push(res, $UN.strptr2string(s))
    // end of [val]
  in
    strptr_free(s); res
  end // end of [GVstr]
) where
{
fun
chars_push
(
  res: chars, s: string
) : chars = let
  val n = g0u2i(string_length(s))
  fun
  aux
  (
    res: chars, i: int
  ) : chars =
  (
    if i < n
      then aux(list_vt_cons(chr_at(string2ptr(s), i), res), i+1)
      else res
  ) (* end of [aux] *)
in
  aux(res, 0)
end // end of [chars_push]
} (* end of [gval_emit] *)
//
(* ****** ****** *)

implement
myatscc_evaldef
  (def, args) = let
//
val p0 = string2ptr(def)
val n0 = g0u2i(string_length(def))
//
fun
loop
{n:int}
(
  i: int
, args: !list_vt(Strptr1, n), res: chars
) : chars = let
  val opt = parse_exp(p0, i, n0)
in
  case+ opt of
  | ~None_vt() => res
  | ~Some_vt(ej) => let
      val gv = mexp_eval(ej.0, args)
      val () = mexp_free(ej.0)
    in
      loop(ej.1, args, gval_emit(gv, res))
    end // end of [Some_vt]
end // end of [loop]
//
val cs = loop(0, args, list_vt_nil())
//
in
//
$UN.castvwtp0{Strptr1}
(
  string_make_rlist_vt($UN.castvwtp0{List0_vt(charNZ)}(cs))
)
//
end // end of [myatscc_evaldef]

(* ****** ****** *)

(* end of [myatscc_evaler.dats] *)
