#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "contrib/afiber/SATS/afiber.sats"
staload _ = "contrib/afiber/DATS/afiber.dats"

var the_cnt: int = 0
val the_cnt_ref = ref_make_viewptr{int}(view@ the_cnt | addr@ the_cnt)
var the_deep: lint = 0L
val the_deep_ref = ref_make_viewptr{lint}(view@ the_deep | addr@ the_deep)

// non-tail recursion that touches its stack
fun deep (n: int): lint =
  if n = 0 then 0L else let
    var buf = @[char][16]('x')
    val p = addr@buf
    val () = $UN.ptr0_set_at<char> (p, n mod 16, 'y')
    val r = deep (n-1)
    val c = (if $UN.ptr0_get_at<char> (p, n mod 16) = 'y' then 1L else 0L): lint
  in r + c end

fun join_all (fs: List0_vt(afiber_vt)): void =
  case+ fs of
  | ~list_vt_cons (f, fs) => (afiber_join (f); join_all (fs))
  | ~list_vt_nil () => ()

fun spawn_n (i: int, n: int, acc: List0_vt(afiber_vt)): List0_vt(afiber_vt) =
  if i < n then let
    val f = afiber_spawn (llam () => the_cnt_ref[] := the_cnt_ref[] + 1)
  in spawn_n (i+1, n, list_vt_cons (f, acc)) end else acc

fun waves (w: int): void =
  if w < 10 then let
    val fs = spawn_n (0, 1000, list_vt_nil ())
    val fd = afiber_spawn (llam () => the_deep_ref[] := the_deep_ref[] + deep (600))
    val () = join_all (list_vt_cons (fd, fs))
  in waves (w+1) end else ()

implement main0 () = {
  val () = waves (0)
  val () = afiber_run_until_done ()
  val () = assertloc (the_cnt_ref[] = 10*1000)
  val () = assertloc (the_deep_ref[] = 10L * 600L)
  val () = assertloc (afiber_nlive () = 0L)
  val () = println! ("POS_waves: passed")
}
