fn libatsynmark_ld (p: ptr, k: int): ptr = $UN.ptr0_get<ptr> (ptr0_add_gint<byte> (p, k))
fn libatsynmark_st (p: ptr, k: int, x: ptr): void = $UN.ptr0_set<ptr> (ptr0_add_gint<byte> (p, k), x)
fn libatsynmark_alloc (n: int): ptr = the_garena_alloc ($UN.cast{size_t} (n))
//

implement
d0eclrep_D0ECLREPsing
  (a0, a1) = let
val p = libatsynmark_alloc (32)
val () = libatsynmark_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = libatsynmark_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = libatsynmark_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{d0eclrep} (p)
end // end of [d0eclrep_D0ECLREPsing]

implement
d0eclrep_D0ECLREPinclude
  (a0, a1, a2) = let
val p = libatsynmark_alloc (32)
val () = libatsynmark_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = libatsynmark_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = libatsynmark_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
val () = libatsynmark_st (p, 24, $UN.cast{ptr} ($UN.cast{lint} (a2)))
in
  $UN.cast{d0eclrep} (p)
end // end of [d0eclrep_D0ECLREPinclude]

implement
d0eclrep_D0ECLREPguadecl
  (a0) = let
val p = libatsynmark_alloc (32)
val () = libatsynmark_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = libatsynmark_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{d0eclrep} (p)
end // end of [d0eclrep_D0ECLREPguadecl]

implement
d0eclrep_encode
  (v) =
(
case+ v of
| ~D0ECLREPsing(a0, a1) => d0eclrep_D0ECLREPsing(a0, a1)
| ~D0ECLREPinclude(a0, a1, a2) => d0eclrep_D0ECLREPinclude(a0, a1, a2)
| ~D0ECLREPguadecl(a0) => d0eclrep_D0ECLREPguadecl(a0)
) (* end of [d0eclrep_encode] *)

implement
d0eclrep_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (libatsynmark_ld ($UN.cast{ptr} (x), 0)))

implement
d0eclrep_is_D0ECLREPsing
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsynmark_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
d0eclrep_is_D0ECLREPinclude
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsynmark_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
d0eclrep_is_D0ECLREPguadecl
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsynmark_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
d0eclrep_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (libatsynmark_ld (p, 0)))
//
in
//
case+ tag of
| 0 => D0ECLREPsing($UN.cast{d0ecl} ($UN.cast{lint} (libatsynmark_ld (p, 8))), $UN.cast{charlst} ($UN.cast{lint} (libatsynmark_ld (p, 16))))
| 1 => D0ECLREPinclude($UN.cast{d0ecl} ($UN.cast{lint} (libatsynmark_ld (p, 8))), $UN.cast{charlst} ($UN.cast{lint} (libatsynmark_ld (p, 16))), $UN.cast{d0eclreplst} ($UN.cast{lint} (libatsynmark_ld (p, 24))))
| _ => D0ECLREPguadecl($UN.cast{guad0eclrep} ($UN.cast{lint} (libatsynmark_ld (p, 8))))
//
end // end of [d0eclrep_view]

implement
d0eclrep_view_free
  (v) =
(
case+ v of
| ~D0ECLREPsing(_, _) => ()
| ~D0ECLREPinclude(_, _, _) => ()
| ~D0ECLREPguadecl(_) => ()
) (* end of [d0eclrep_view_free] *)

(* ****** ****** *)

implement
guad0eclrep_GUAD0ECLREPone
  (a0) = let
val p = libatsynmark_alloc (24)
val () = libatsynmark_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (0)))
val () = libatsynmark_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
in
  $UN.cast{guad0eclrep} (p)
end // end of [guad0eclrep_GUAD0ECLREPone]

implement
guad0eclrep_GUAD0ECLREPtwo
  (a0, a1) = let
val p = libatsynmark_alloc (24)
val () = libatsynmark_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (1)))
val () = libatsynmark_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = libatsynmark_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{guad0eclrep} (p)
end // end of [guad0eclrep_GUAD0ECLREPtwo]

implement
guad0eclrep_GUAD0ECLREPcons
  (a0, a1) = let
val p = libatsynmark_alloc (24)
val () = libatsynmark_st (p, 0, $UN.cast{ptr} ($UN.cast{lint} (2)))
val () = libatsynmark_st (p, 8, $UN.cast{ptr} ($UN.cast{lint} (a0)))
val () = libatsynmark_st (p, 16, $UN.cast{ptr} ($UN.cast{lint} (a1)))
in
  $UN.cast{guad0eclrep} (p)
end // end of [guad0eclrep_GUAD0ECLREPcons]

implement
guad0eclrep_encode
  (v) =
(
case+ v of
| ~GUAD0ECLREPone(a0) => guad0eclrep_GUAD0ECLREPone(a0)
| ~GUAD0ECLREPtwo(a0, a1) => guad0eclrep_GUAD0ECLREPtwo(a0, a1)
| ~GUAD0ECLREPcons(a0, a1) => guad0eclrep_GUAD0ECLREPcons(a0, a1)
) (* end of [guad0eclrep_encode] *)

implement
guad0eclrep_tag
  (x) = $UN.cast{int} ($UN.cast{lint} (libatsynmark_ld ($UN.cast{ptr} (x), 0)))

implement
guad0eclrep_is_GUAD0ECLREPone
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsynmark_ld ($UN.cast{ptr} (x), 0))) = 0)

implement
guad0eclrep_is_GUAD0ECLREPtwo
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsynmark_ld ($UN.cast{ptr} (x), 0))) = 1)

implement
guad0eclrep_is_GUAD0ECLREPcons
  (x) = ($UN.cast{int} ($UN.cast{lint} (libatsynmark_ld ($UN.cast{ptr} (x), 0))) = 2)

implement
guad0eclrep_view
  (x) = let
//
val p = $UN.cast{ptr} (x)
val tag = $UN.cast{int} ($UN.cast{lint} (libatsynmark_ld (p, 0)))
//
in
//
case+ tag of
| 0 => GUAD0ECLREPone($UN.cast{d0eclreplst} ($UN.cast{lint} (libatsynmark_ld (p, 8))))
| 1 => GUAD0ECLREPtwo($UN.cast{d0eclreplst} ($UN.cast{lint} (libatsynmark_ld (p, 8))), $UN.cast{d0eclreplst} ($UN.cast{lint} (libatsynmark_ld (p, 16))))
| _ => GUAD0ECLREPcons($UN.cast{d0eclreplst} ($UN.cast{lint} (libatsynmark_ld (p, 8))), $UN.cast{guad0eclrep} ($UN.cast{lint} (libatsynmark_ld (p, 16))))
//
end // end of [guad0eclrep_view]

implement
guad0eclrep_view_free
  (v) =
(
case+ v of
| ~GUAD0ECLREPone(_) => ()
| ~GUAD0ECLREPtwo(_, _) => ()
| ~GUAD0ECLREPcons(_, _) => ()
) (* end of [guad0eclrep_view_free] *)

(* ****** ****** *)
