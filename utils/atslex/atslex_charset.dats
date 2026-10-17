(*
** atslex: lexer for ATS
*)

(* ****** ****** *)
//
#include
"share/atspre_staload.hats"  
//
(* ****** ****** *)

staload "./atslex.sats"

(* ****** ****** *)

%{^
#include <stdint.h>
static inline
uint64_t atspre_uint64_bit(int i) { return ((uint64_t)1) << i ; }
static inline
int atspre_uint64_test(uint64_t w, uint64_t b) { return (w & b) != 0 ; }
static inline
uint64_t atspre_uint64_lor(uint64_t w1, uint64_t w2) { return w1 | w2 ; }
static inline
uint64_t atspre_uint64_land(uint64_t w1, uint64_t w2) { return w1 & w2 ; }
static inline
uint64_t atspre_uint64_lnot(uint64_t w) { return ~w ; }
%}


(* ****** ****** *)

#define UCHAR_MAX 0xFF

(* ****** ****** *)
//
// HX-2026-10: no GC
// the bits 64*k+i of a charset are kept in the
// i-th bit of its k-th component
//
assume
charset_t0ype = @(uint64, uint64, uint64, uint64)
//
(* ****** ****** *)

#define i2uc(i) int2uchar0(i)
#define uc2i(c) uchar2int0(c)

(* ****** ****** *)

extern
fun bit_get (cs: charset, i: int): bool
extern
fun bit_set (cs: charset, i: int): charset

local
//
macdef w0 = $UNSAFE.cast{uint64}(0)
macdef w1 = $UNSAFE.cast{uint64}(1)
//
fun
bit (i: int): uint64 =
  $extfcall(uint64, "atspre_uint64_bit", i)
//
in (* in of [local] *)

implement
bit_get (cs, i) = let
  val k = i / 64 and b = bit (i % 64)
  val w =
  (
    if k = 0 then cs.0
    else if k = 1 then cs.1
    else if k = 2 then cs.2 else cs.3
  ) : uint64
in
  $extfcall(bool, "atspre_uint64_test", w, b)
end // end of [bit_get]

implement
bit_set (cs, i) = let
  val k = i / 64 and b = bit (i % 64)
  macdef bor (w) = $extfcall(uint64, "atspre_uint64_lor", ,(w), b)
in
  if k = 0 then @(bor(cs.0), cs.1, cs.2, cs.3)
  else if k = 1 then @(cs.0, bor(cs.1), cs.2, cs.3)
  else if k = 2 then @(cs.0, cs.1, bor(cs.2), cs.3)
  else @(cs.0, cs.1, cs.2, bor(cs.3))
end // end of [bit_set]

end // end of [local]

(* ****** ****** *)

local

fun
fprint_range
(
  out: FILEref
, c1: int, c2: int
) : void = let
//
fun fpc
(
  out: FILEref, i: int
) : void =
(
  if isprint (i)
    then $extfcall(void, "fprintf", out, "%c", i)
    else $extfcall(void, "fprintf", out, "0x%x'", i)
  // end of [if]
) (* end of [fpc] *)
//
in
//
if c1 < c2
  then let
    val () = fpc (out, c1)
    val () = fprint (out, '-')
    val () = fpc (out, c2)
  in
    // nothing
  end // end of [then]
  else fpc (out, c1)
// end of [if]
//
end // end of [fprint_range]

in (* in of [local] *)

implement
fprint_charset
  (out, cs0) = let
//
// HX: printing the maximal ranges of members
//
fun loop
  (i: int): void =
(
if i <= UCHAR_MAX then
(
  if bit_get (cs0, i)
    then let
      fun last (j: int): int =
        if j < UCHAR_MAX
          then (if bit_get (cs0, j+1) then last (j+1) else j)
          else j
      val j = last (i)
      val () = fprint (out, " ")
      val () = fprint_range (out, i, j)
    in
      loop (j+1)
    end // end of [then]
    else loop (i+1)
  // end of [if]
)
) (* end of [loop] *)
//
in
  fprint (out, "["); loop (0); fprint (out, " ]")
end // end of [fprint_charset]

end // end of [local]

(* ****** ****** *)

implement
print_charset (cs) = fprint_charset (stdout_ref, cs)
implement
prerr_charset (cs) = fprint_charset (stderr_ref, cs)

(* ****** ****** *)

local
//
macdef w0 = $UNSAFE.cast{uint64}(0)
//
macdef
wand(w1, w2) = $extfcall(uint64, "atspre_uint64_land", ,(w1), ,(w2))
macdef
wor(w1, w2) = $extfcall(uint64, "atspre_uint64_lor", ,(w1), ,(w2))
macdef
wnot(w) = $extfcall(uint64, "atspre_uint64_lnot", ,(w))
//
in (* in of [local] *)

implement
charset_nil = @(w0, w0, w0, w0)
implement
charset_all = @(wnot(w0), wnot(w0), wnot(w0), wnot(w0))

implement
charset_comp (cs) =
  @(wnot(cs.0), wnot(cs.1), wnot(cs.2), wnot(cs.3))
implement
charset_union (cs1, cs2) =
  @(wor(cs1.0, cs2.0), wor(cs1.1, cs2.1), wor(cs1.2, cs2.2), wor(cs1.3, cs2.3))
implement
charset_inter (cs1, cs2) =
  @(wand(cs1.0, cs2.0), wand(cs1.1, cs2.1), wand(cs1.2, cs2.2), wand(cs1.3, cs2.3))
implement
charset_diff (cs1, cs2) = charset_inter (cs1, charset_comp (cs2))

end // end of [local]

(* ****** ****** *)

implement
charset_sing (c) = bit_set (charset_nil, uc2i(c))

implement
charset_interval
  (c1, c2) = let
//
val i1 = uc2i(c1) and i2 = uc2i(c2)
val i1 = min(i1, i2) and i2 = max(i1, i2)
//
fun loop (cs: charset, i: int): charset =
  if i <= i2 then loop (bit_set (cs, i), i+1) else cs
//
in
  loop (charset_nil, i1)
end // end of [charset_interval]

implement
charset_is_member (cs, c0) = bit_get (cs, uc2i(c0))

(* ****** ****** *)

(* end of [atslex_charset.dats] *)
