(* ****** ****** *)
//
// A tiny simulated event loop for running the examples of the chapters
// on animation without a browser. The pending events are kept in a
// linear list, which is sorted according to the time when an event is
// due; an event is a linear thunk. A browser (or node) provides the
// real thing, [setTimeout].
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
//
datavtype
events =
  | events_nil of ()
  | events_cons of (int(*due*), thunk, events)
//
macdef
thunk_free(fwork) =
cloptr_free($UNSAFE.castvwtp0{cloptr(void)}(,(fwork)))
//
fun
events_free(evs: events): void =
(
case+ evs of
| ~events_nil() => ()
| ~events_cons(_, fwork, evs) => (thunk_free(fwork); events_free(evs))
)
//
// an event is inserted after those that are due no later
//
fun
events_insert
(due: int, fwork: thunk, evs: events): events =
(
case+ evs of
| ~events_nil() => events_cons(due, fwork, events_nil())
| ~events_cons(due1, fwork1, evs1) =>
  if due < due1
    then events_cons(due, fwork, events_cons(due1, fwork1, evs1))
    else events_cons(due1, fwork1, events_insert(due, fwork, evs1))
)
//
(* ****** ****** *)

var theClock_var: int = 0
var theEvents_var: ptr = the_null_ptr // an events-value is stored as a pointer
//
val theClock =
ref_make_viewptr{int}(view@ theClock_var | addr@ theClock_var)
val theEvents =
ref_make_viewptr{ptr}(view@ theEvents_var | addr@ theEvents_var)
//
implement
execute_after
(fwork, ms) = let
//
val evs = $UNSAFE.castvwtp0{events}(!theEvents)
val evs = events_insert(!theClock + ms, fwork, evs)
//
in
  !theEvents := $UNSAFE.castvwtp0{ptr}(evs)
end // end of [execute_after]
//
implement
eventloop_now() = !theClock
//
(* ****** ****** *)
//
// The first event is called when its time is due; the calls stop
// when no event is pending or when the clock goes beyond the limit
// (and the events that are still pending are freed).
//
implement
eventloop_run(limit) = let
//
val evs = $UNSAFE.castvwtp0{events}(!theEvents)
//
in
//
case+ evs of
| ~events_nil() => (!theEvents := the_null_ptr)
| ~events_cons(due, fwork, evs) =>
  if due <= limit
    then let
      val () = !theClock := due
      val () = !theEvents := $UNSAFE.castvwtp0{ptr}(evs)
      val () = fwork()
      val () = thunk_free(fwork)
    in
      eventloop_run(limit)
    end // end of [then]
    else let
      val () = thunk_free(fwork)
      val () = events_free(evs)
    in
      !theEvents := the_null_ptr
    end // end of [else]
//
end // end of [eventloop_run]
//
(* ****** ****** *)

(* end of [eventloop.hats] *)
