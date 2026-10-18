(* HX-2026-10: afiberchan with linear payloads (strptr, datavtype) *)
#include "share/atspre_staload.hats"
staload "libats/SATS/afiber.sats"
staload _ = "libats/DATS/afiber.dats"
staload "libats/SATS/afiberchan.sats"
staload _ = "libats/DATS/afiberchan.dats"

datavtype node = NODE of (int, strptr)

var the_ok: int = 0
val the_ok_ref = ref_make_viewptr{int}(view@ the_ok | addr@ the_ok)

fun sender (ch: !chan_vt(strptr)): void = {
  val () = chan_send<strptr> (ch, string0_copy ("abc"))
  val () = chan_send<strptr> (ch, string0_copy ("defg"))
  val () = chan_send<strptr> (ch, string0_copy ("hi"))
}

fun receiver (ch: !chan_vt(strptr)): void = {
  val-~Some_vt(s1) = chan_recv<strptr> (ch)
  val () = assertloc (string_length ($UNSAFE.castvwtp1{string}(s1)) = i2sz(3))
  val () = assertloc ($UNSAFE.castvwtp1{string}(s1) = "abc")
  val () = strptr_free (s1)
  val-~Some_vt(s2) = chan_recv<strptr> (ch)
  val () = assertloc (string_length ($UNSAFE.castvwtp1{string}(s2)) = i2sz(4))
  val () = assertloc ($UNSAFE.castvwtp1{string}(s2) = "defg")
  val () = strptr_free (s2)
  val () = the_ok_ref[] := the_ok_ref[] + 1
}

fun slist_free (xs: List_vt(strptr)): void =
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (s, rest) => (strptr_free (s); slist_free (rest))

fun nlist_free (xs: List_vt(node)): void =
  case+ xs of
  | ~list_vt_nil () => ()
  | ~list_vt_cons (~NODE(_, s), rest) => (strptr_free (s); nlist_free (rest))

fun nsender (ch: !chan_vt(node)): void = {
  val () = chan_send<node> (ch, NODE (1, string0_copy ("one")))
  val () = chan_send<node> (ch, NODE (2, string0_copy ("two")))
}

fun nreceiver (ch: !chan_vt(node)): void = {
  val-~Some_vt(~NODE(i, s)) = chan_recv<node> (ch)
  val () = assertloc (i = 1)
  val () = assertloc ($UNSAFE.castvwtp1{string}(s) = "one")
  val () = strptr_free (s)
  val-~Some_vt(~NODE(j, t)) = chan_recv<node> (ch)
  val () = assertloc (j = 2)
  val () = assertloc ($UNSAFE.castvwtp1{string}(t) = "two")
  val () = strptr_free (t)
  val () = the_ok_ref[] := the_ok_ref[] + 1
}

implement main0 () = {
  //
  val ch = chan_make<strptr> (4)
  val s = chan_ref<strptr> (ch)
  val r = chan_ref<strptr> (ch)
  val fs = afiber_spawn (llam () => let
    val () = sender (s)
    val xs = chan_unref<strptr> (s)
    val () = assertloc (list_vt_length (xs) = 0)
  in slist_free (xs) end)
  val fr = afiber_spawn (llam () => let
    val () = receiver (r)
    val xs = chan_unref<strptr> (r)
  in slist_free (xs) end)
  val () = afiber_join (fs)
  val () = afiber_join (fr)
  val () = assertloc (chan_size<strptr> (ch) = 1)
  val xs = chan_unref<strptr> (ch)
  val () = assertloc (list_vt_length (xs) = 1)
  val ~list_vt_cons (s3, xs2) = xs
  val ~list_vt_nil () = xs2
  val () = assertloc ($UNSAFE.castvwtp1{string}(s3) = "hi")
  val () = strptr_free (s3)
  //
  val nch = chan_make<node> (1)
  val ns = chan_ref<node> (nch)
  val nr = chan_ref<node> (nch)
  val fns = afiber_spawn (llam () => let
    val () = nsender (ns)
    val xs = chan_unref<node> (ns)
  in nlist_free (xs) end)
  val fnr = afiber_spawn (llam () => let
    val () = nreceiver (nr)
    val xs = chan_unref<node> (nr)
  in nlist_free (xs) end)
  val () = afiber_join (fns)
  val () = afiber_join (fnr)
  val xs = chan_unref<node> (nch)
  val () = assertloc (list_vt_length (xs) = 0)
  val () = nlist_free (xs)
  val () = assertloc (the_ok_ref[] = 2)
  val () = afiber_run_until_done ()
  val () = println! ("POS_linear: passed")
}
