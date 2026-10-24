(* ****** ****** *)
//
// A tiny simulated event loop for running the examples of the chapters
// on animation without a browser. At most one event is pending: it is a
// linear thunk that is stored together with the time when it is due.
// A browser (or node) provides the real thing, [setTimeout].
//
(* ****** ****** *)

vtypedef
thunk = () -<lincloptr1> void

(* ****** ****** *)
//
extern
fun
execute_after
(fwork: thunk, ms: int): void
//
(* ****** ****** *)
//
extern
fun
eventloop_now(): int
extern
fun
eventloop_run(limit: int): void
//
(* ****** ****** *)

var theClock_var: int = 0
var theDueTime_var: int = 0
var thePending_var: ptr = the_null_ptr
//
val theClock =
ref_make_viewptr{int}(view@ theClock_var | addr@ theClock_var)
val theDueTime =
ref_make_viewptr{int}(view@ theDueTime_var | addr@ theDueTime_var)
val thePending =
ref_make_viewptr{ptr}(view@ thePending_var | addr@ thePending_var)
//
implement
execute_after
(fwork, ms) = let
//
val p0 = !thePending
//
in
//
if
iseqz(p0)
then let
  val () = !theDueTime := !theClock + ms
in
  !thePending := $UNSAFE.castvwtp0{ptr}(fwork)
end // end of [then]
else let
  // only one event can be pending in this simulation
  val () = cloptr_free($UNSAFE.castvwtp0{cloptr(void)}(fwork))
in
  prerrln! ("execute_after: an event is already pending")
end // end of [else]
//
end // end of [execute_after]
//
implement
eventloop_now() = !theClock
//
(* ****** ****** *)
//
// The pending thunk is called when its time is due; the calls stop
// when no event is pending or when the clock goes beyond the limit
// (and the thunk that is still pending is freed).
//
implement
eventloop_run(limit) = let
//
val p0 = !thePending
//
in
//
if
iseqz(p0)
then ()
else let
//
val () =
!thePending := the_null_ptr
val fwork = $UNSAFE.castvwtp0{thunk}(p0)
//
in
//
if
!theDueTime <= limit
then let
  val () = !theClock := !theDueTime
  val () = fwork()
  val () = cloptr_free($UNSAFE.castvwtp0{cloptr(void)}(fwork))
in
  eventloop_run(limit)
end // end of [then]
else cloptr_free($UNSAFE.castvwtp0{cloptr(void)}(fwork))
//
end // end of [else]
//
end // end of [eventloop_run]
//
(* ****** ****** *)

(* end of [eventloop.hats] *)
