(* ****** ****** *)
(*
** The integer combinators of LECTURE/04: the beginning
** of the library of the book.  Included by the later lectures.
** A function argument is a stack-allocated closure
** that is passed by reference (nothing to allocate, nothing to free).
*)
(* ****** ****** *)
//
extern
fun
int_foreach
(n0: int, fwork: &(int) -<clo1> void): void
//
implement
int_foreach
(n0, fwork) =
loop(0, fwork) where {
  fun
  loop
  (i: int, fwork: &(int) -<clo1> void): void =
    if i < n0 then (fwork(i); loop(i+1, fwork)) else ()
  // end of [fun loop]
} (* end of [int_foreach] *)
//
(* ****** ****** *)
//
extern
fun
{res:t@ype}
int_foldleft
( n0: int
, res: res, fopr: &(res, int) -<clo1> res): res
//
implement
{res}(*tmp*)
int_foldleft
  (n0, res, fopr) =
  loop(res, 0, fopr) where
{
//
fun loop
( res: res, i: int
, fopr: &(res, int) -<clo1> res): res =
  if i < n0 then loop(fopr(res, i), i+1, fopr) else res
//
} (* end of [int_foldleft] *)
//
(* ****** ****** *)
//
extern
fun
int_cross_foreach
( m: int, n: int
, fwork: &(int, int) -<clo1> void): void
//
implement
int_cross_foreach
  (m, n, fwork) =
  loop1(0, fwork) where
{
//
fun
loop2
( i: int, j: int
, fwork: &(int, int) -<clo1> void): void =
  if j < n then (fwork(i, j); loop2(i, j+1, fwork)) else ()
//
fun
loop1
( i: int
, fwork: &(int, int) -<clo1> void): void =
  if i < m then (loop2(i, 0, fwork); loop1(i+1, fwork)) else ()
//
} (* end of [int_cross_foreach] *)
//
(* ****** ****** *)

//
extern
fun
int_foreach_method
(n0: int, fwork: &(int) -<clo1> void): void
//
extern
fun
{res:t@ype}
int_foldleft_method
(n0: int, res: res, fopr: &(res, int) -<clo1> res): res
//
overload .foreach with int_foreach_method
overload .foldleft with int_foldleft_method
//
implement
int_foreach_method(n0, fwork) = int_foreach(n0, fwork)
implement
{res}(*tmp*)
int_foldleft_method(n0, res, fopr) = int_foldleft<res>(n0, res, fopr)
//
(* ****** ****** *)

(* end of [intfun.hats] *)
