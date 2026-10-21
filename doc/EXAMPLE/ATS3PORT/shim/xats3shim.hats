(* ****** ****** *)
//
// xats3shim.hats
//
// An ATS2 shim for the parts of the ATS3 (ATS-Xanadu) prelude
// that have no direct ATS2 counterpart:
//
//   * [GSEQ]/[GASQ]: the generic sequence layer.  In ATS3 a
//     [GSEQ(xs, x0)] abstracts over the *container* [xs] (a list,
//     an array, a string, ...) and offers [prod], [sum], [foritm],
//     [iforitm], [listize], [rlistize], [strmize], [forall] and
//     [exists].  In ATS2 the container is not abstracted away:
//     one uses [list_vt] for lists, [arrayptr] for arrays and
//     [intrange] for ranges.  The folds over a sequence are
//     missing from the ATS2 prelude and are provided here.
//
//   * [gdbg]: the debugging layer.  [gdbg_trace] traces a call
//     to a function of one integer argument.
//
//   * a few string operations that ATS2 does not have.
//
// The file is meant to be included:
//
//   #include "../shim/xats3shim.hats"
//
// (the path of an [include] is relative to the current
// directory, so the tests that live in a subdirectory of this
// one have to say [../shim/...]).
//
// The file staloads what it needs, so the program that includes
// it does not have to.
//
// Note that the operations on [list_vt] below take a read-only
// view of a sequence; the sequence itself stays the property of
// the caller, which has to free it (there is no garbage
// collector in ATS2).
//
// ****** ****** *)

(* ****** ****** *)

staload "prelude/SATS/list_vt.sats"
staload "prelude/SATS/string.sats"
staload "prelude/SATS/char.sats"
staload "prelude/SATS/arrayptr.sats"
staload "prelude/SATS/integer_size.sats"
staload "libats/SATS/arena.sats"
staload UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)
//
// [gseq_prod]: the product of the elements of a sequence.
// This is the ATS3 [GSEQ(xs).prod()].
//
fun {n:int} gseq_prod (xs: !list_vt(int, n)): int =
(
case+ xs of
| list_vt_nil() => 1
| list_vt_cons(x, xs2) => x * gseq_prod (xs2)
) (* end of [gseq_prod] *)

(* ****** ****** *)
//
// [gseq_sum]: the sum of the elements of a sequence.
// This is the ATS3 [GSEQ(xs).sum()].
//
fun {n:int} gseq_sum (xs: !list_vt(int, n)): int =
(
case+ xs of
| list_vt_nil() => 0
| list_vt_cons(x, xs2) => x + gseq_sum (xs2)
) (* end of [gseq_sum] *)

(* ****** ****** *)
//
// [gasq_bin$search]: a binary search over a sorted array.
// This is the ATS3 [GASQ(xs).bin$search(x0)]; the array is
// assumed to be sorted in increasing order and the answer is
// the index of the first element that is not less than the
// searched-for value.  The comparison function is given the
// element and the searched-for value and returns a negative
// number, zero or a positive number, as [compare] does.  The
// answer is the index of the first element that is greater
// than the searched-for value (the upper bound).
//
fun {a:t0p}{n:int}
gasq_bin$search (A: !arrayptr(a, n), len: int, x0: a, cmp: (a, a) -> int): int =
let
  val p = arrayptr2ptr (A)
  fun loop (p: ptr, lo: int, hi: int): int =
    if lo >= hi then hi
    else let
      val mid = lo + (hi - lo) / 2
      val c = cmp ($UN.ptr0_get_at_int (p, mid), x0)
    in
      if c <= 0 then loop (p, lo, mid) else loop (p, mid + 1, hi)
    end
in
  loop (p, 0, len)
end (* end of [gasq_bin$search] *)

(* ****** ****** *)
//
// [gdbg_trace]: the ATS3 [gdbg] layer.  It traces a call to a
// function of one integer argument.
//
// The printed lines have the ATS3 shape:
//
//   <name>: arg1 = <arg>
//   <name>: res0 = <res>
//
fun gdbg_trace (f: int -> int, x: int, nm: string): int =
let
  val () = println! (nm, ": arg1 = ", x)
  val y = f (x)
  val () = println! (nm, ": res0 = ", y)
in
  y
end (* end of [gdbg_trace] *)


(* ****** ****** *)
//
// [gdbg_trace_str]: the ATS3 [gdbg] layer for a function of two
// string arguments.
//
fun gdbg_trace_str (f: (string, string) -> string, x1: string, x2: string, nm: string): string =
let
  val () = println! (nm, ": arg1 = ", x1)
  val () = println! (nm, ": arg2 = ", x2)
  val y = f (x1, x2)
  val () = println! (nm, ": res0 = ", y)
in
  y
end (* end of [gdbg_trace_str] *)

(* ****** ****** *)
//
// [string_of_strptr]: turn a string buffer into a string that
// lives in the global arena.  Since ATS2 has no garbage
// collector, a string that is built at run-time has to be
// given an owner; the global arena is used here.
//
fun string_of_strptr (t: Strptr1): string =
let
  val s = $UN.strptr2string (t)
  val r = the_garena_strdup (s)
  val () = strptr_free (t)
in
  r
end (* end of [string_of_strptr] *)

(* ****** ****** *)
//
// [string_append2]: append a string to another one; the result
// is a string that lives in the global arena.
//
fun string_append2 (s1: string, s2: string): string =
let
  val t = string_append (s1, s2)
in
  string_of_strptr (t)
end (* end of [string_append2] *)

(* ****** ****** *)
//
// [string_prefix]: the first [n] characters of a string.
// This is the ATS3 [prefix].
//
fun string_prefix (s: string, n: int): string =
let
  val len = g0uint2int_size_int (string_length (s))
  val n2 = if n < len then n else len
  val p = $UN.cast2ptr (string2ptr (s))
  fun loop (i: int, acc: string): string =
    if i >= n2 then acc
    else (let
      val c = $UN.ptr0_get_at_int<char> (p, i)
      val cs = char2string (c)
    in
      loop (i + 1, string_append2 (acc, cs))
    end)
in
  loop (0, "")
end (* end of [string_prefix] *)

(* ****** ****** *)
//
// [string_suffix]: the part of a string that starts at the
// index [i].  This is the ATS3 [suffix].
//
fun string_suffix (s: string, i: int): string =
let
  val len = g0uint2int_size_int (string_length (s))
  val i2 = if i < 0 then 0 else (if i > len then len else i)
  val p = $UN.cast2ptr (string2ptr (s))
  fun loop (j: int, acc: string): string =
    if j >= len then acc
    else (let
      val c = $UN.ptr0_get_at_int<char> (p, j)
      val cs = char2string (c)
    in
      loop (j + 1, string_append2 (acc, cs))
    end)
in
  loop (i2, "")
end (* end of [string_suffix] *)

(* ****** ****** *)
//
// [string_slice]: the substring of [s] that starts at the index
// [i] and ends at the index [j] (the end is exclusive).  This is
// the ATS3 [slice].
//
fun string_slice (s: string, i: int, j: int): string =
let
  val len = g0uint2int_size_int (string_length (s))
  val i2 = if i < 0 then 0 else (if i > len then len else i)
  val j2 = if j < i2 then i2 else (if j > len then len else j)
  val p = $UN.cast2ptr (string2ptr (s))
  fun loop (k: int, acc: string): string =
    if k >= j2 then acc
    else (let
      val c = $UN.ptr0_get_at_int<char> (p, k)
      val cs = char2string (c)
    in
      loop (k + 1, string_append2 (acc, cs))
    end)
in
  loop (i2, "")
end (* end of [string_slice] *)

(* ****** ****** *)
//
// [string_reverse]: the reversed copy of a string.
// This is the ATS3 [strn_reverse].
//
fun string_reverse (s: string): string =
let
  val len = g0uint2int_size_int (string_length (s))
  val p = $UN.cast2ptr (string2ptr (s))
  fun loop (i: int, acc: string): string =
    if i < 0 then acc
    else (let
      val c = $UN.ptr0_get_at_int<char> (p, i)
      val cs = char2string (c)
    in
      loop (i - 1, string_append2 (acc, cs))
    end)
in
  loop (len - 1, "")
end (* end of [string_reverse] *)
