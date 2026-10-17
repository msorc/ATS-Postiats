(* test of pats_avlmap.dats: random insertions, removals and unions are compared with a table of booleans; the persistence
   (an old version does not change), the height bound (AVL: h < 1.45 log2 (n+2)) and the order of the keys are checked *)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
#include "../mylibies.hats"
staload "../pats_avlmap.sats"
staload _ = "../pats_avlmap.dats"
dynload "../pats_avlmap.dats"

#define NKEY 300

fn cmp (x: ptr, y: ptr): int = let
  val x = $UN.cast{int} (x) and y = $UN.cast{int} (y)
in
  if x < y then ~1 else (if x > y then 1 else 0)
end

fn tnew (): ptr = the_garena_alloc ($UN.cast{size_t} (NKEY * 8))
fn tget (t: ptr, i: int): bool = $UN.ptr0_get<bool> (ptr0_add_gint<bool> (t, i))
fn tset (t: ptr, i: int, b: bool): void = $UN.ptr0_set<bool> (ptr0_add_gint<bool> (t, i), b)

fn chk (m: avlmap, tbl: ptr): int = let
  // 0 if the map equals the table
  var err: int = 0
  val ks = avlmap_keys (m)
  val vs = avlmap_vals (m)
  fun loop (ks: List0_vt (ptr), vs: List0_vt (ptr), prev: int, n: int, err: &int): int =
    case+ ks of
    | ~list_vt_cons (k, ks) => (
      case+ vs of
      | ~list_vt_cons (v, vs) => let
          val k = $UN.cast{int} (k)
          val () = if k <= prev then err := err + 1
          val () = if $UN.cast{int} (v) != 3 * k then err := err + 1
        in
          loop (ks, vs, k, n + 1, err)
        end
      | ~list_vt_nil () => (list_vt_free (ks); err := err + 1; n)
      )
    | ~list_vt_nil () => (list_vt_free (vs); n)
  val n = loop (ks, vs, ~1, 0, err)
  var cnt: int = 0
  var i: int
  val () = for (i := 0; i < NKEY; i := i + 1) let
    val present = tget (tbl, i)
    val found = avlmap_ismem (m, $UN.cast{ptr} (i), cmp)
    var res: ptr?
    val found2 = avlmap_find (m, $UN.cast{ptr} (i), cmp, res)
  in
    if present then cnt := cnt + 1
    else ();
    if present != found then err := err + 1;
    if present != found2 then err := err + 1;
    if found2 then (if $UN.cast{int} (res) != 3 * i then err := err + 1)
  end
  val () = if n != cnt then err := err + 1
  val () = if avlmap_size (m) != cnt then err := err + 1
  val h = avlmap_height (m)
  // the height is O(log n): h <= 1.5 log2 (n+2) + 2
  fun lg2 (n: int): int = if n <= 1 then 0 else 1 + lg2 (n / 2)
  val () = if h > (lg2 (cnt + 2) * 3) / 2 + 2 then err := err + 1
in
  err
end

implement main0 () = {
  var seed: int = 12345
  fun rnd (seed: &int): int = let
    val () = seed := ((seed * 75 + 74) mod 65537)
  in
    seed
  end
  val tbl = tnew ()
  var m: avlmap = avlmap_nil ()
  var nerr: int = 0
  var i: int
  var saved: avlmap = avlmap_nil ()
  val savedtbl = tnew ()
  val () = for (i := 0; i < 20000; i := i + 1) let
    val r = rnd (seed) mod 10
    val k = rnd (seed) mod NKEY
  in
    if r < 5 then let
      val () = m := avlmap_insert (m, $UN.cast{ptr} (k), $UN.cast{ptr} (3 * k), cmp)
    in
      tset (tbl, k, true)
    end
    else if r < 8 then let
      val () = m := avlmap_remove (m, $UN.cast{ptr} (k), cmp)
    in
      tset (tbl, k, false)
    end
    else if r = 8 then let
      // a union with a small random map
      var m2: avlmap = avlmap_nil ()
      var j: int
      val () = for (j := 0; j < 10; j := j + 1) let
        val k2 = rnd (seed) mod NKEY
      in
        m2 := avlmap_insert (m2, $UN.cast{ptr} (k2), $UN.cast{ptr} (3 * k2), cmp);
        tset (tbl, k2, true)
      end
    in
      m := avlmap_union (m, m2, cmp)
    end
    else let
      // snapshot (to check the persistence at the end)
      val () = saved := m
      var j: int
      val () = for (j := 0; j < NKEY; j := j + 1)
        tset (savedtbl, j, tget (tbl, j))
    in end;
    if i mod 100 = 0 then nerr := nerr + chk (m, tbl)
  end
  val () = nerr := nerr + chk (m, tbl)
  val () = nerr := nerr + chk (saved, savedtbl)   // the old version is unchanged
  // ascending and descending insertions (the rotations)
  var up: avlmap = avlmap_nil ()
  var dn: avlmap = avlmap_nil ()
  val tup = tnew ()
  val () = for (i := 0; i < NKEY; i := i + 1) let
    val () = up := avlmap_insert (up, $UN.cast{ptr} (i), $UN.cast{ptr} (3 * i), cmp)
    val () = dn := avlmap_insert (dn, $UN.cast{ptr} (NKEY - 1 - i), $UN.cast{ptr} (3 * (NKEY - 1 - i)), cmp)
  in
    tset (tup, i, true)
  end
  val () = nerr := nerr + chk (up, tup) + chk (dn, tup)
  // the removal of everything, in the middle first
  val () = for (i := 0; i < NKEY; i := i + 1) let
    val k = (i * 7) mod NKEY
  in
    up := avlmap_remove (up, $UN.cast{ptr} (k), cmp);
    tset (tup, k, false);
    if i mod 17 = 0 then nerr := nerr + chk (up, tup)
  end
  val () = nerr := nerr + chk (up, tup)
  val () = println! ("test_avlmap: errors = ", nerr)
  val () = if nerr > 0 then assertloc (false)
}
