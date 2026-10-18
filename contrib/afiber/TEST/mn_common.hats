(*
** MS-2026-10: afiber
** shared helpers of the M:N tests (POS_mn_xxx): a global parking mutex
** [mx_lock]/[mx_unlock] (the tests share counters through [ref]s that
** are only touched while holding it), [sleep_ms], [now_ms].
** Include after the staloads of afiber.sats and of unsafe.sats (as $UN).
*)

var the_mtx: ptr = the_null_ptr
val the_mtx_ref = ref_make_viewptr{ptr}(view@ the_mtx | addr@ the_mtx)

fun mx_init (): void =
  the_mtx_ref[] := $UN.castvwtp0{ptr}(afiber_mutex_make ())

fun mx_fini (): void =
  afiber_mutex_free ($UN.castvwtp0{afiber_mutex}(the_mtx_ref[]))

fun mx_lock (): void = let
  val m = $UN.castvwtp1{afiber_mutex}(the_mtx_ref[])
  val () = afiber_mutex_lock (m)
  prval () = $UN.cast2void (m)
in end

fun mx_unlock (): void = let
  val m = $UN.castvwtp1{afiber_mutex}(the_mtx_ref[])
  val () = afiber_mutex_unlock (m)
  prval () = $UN.cast2void (m)
in end

fun now_ms (): lint = $UN.cast{lint}(afiber_clock_ns () / $UN.cast{ullint}(1000000))

fun sleep_ms (ms: int): void = afiber_sleep_msec ($UN.cast{ullint}(ms))

(* end of [mn_common.hats] *)
