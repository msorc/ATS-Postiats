implement
atextdef_TEXTDEFnil
  () = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 0)
in
  $UN.cast{atextdef}(p)
end // end of [atextdef_TEXTDEFnil]

implement
atextdef_TEXTDEFval
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 1)
val () = arena_store<atext>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{atextdef}(p)
end // end of [atextdef_TEXTDEFval]

implement
atextdef_TEXTDEFfun
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 2)
val () = arena_store<atextfun>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{atextdef}(p)
end // end of [atextdef_TEXTDEFfun]

implement
atextdef_TEXTDEFfstr
  (a0) = let
val p = the_garena_alloc(i2sz(16))
val () = arena_store<int>(p, 3)
val () = arena_store<atextfstr>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{atextdef}(p)
end // end of [atextdef_TEXTDEFfstr]

implement
atextdef_encode
  (v) =
(
case+ v of
| ~TEXTDEFnil() => atextdef_TEXTDEFnil()
| ~TEXTDEFval(a0) => atextdef_TEXTDEFval(a0)
| ~TEXTDEFfun(a0) => atextdef_TEXTDEFfun(a0)
| ~TEXTDEFfstr(a0) => atextdef_TEXTDEFfstr(a0)
) (* end of [atextdef_encode] *)

implement
atextdef_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
atextdef_is_TEXTDEFnil
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
atextdef_is_TEXTDEFval
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
atextdef_is_TEXTDEFfun
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
atextdef_is_TEXTDEFfstr
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
atextdef_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => TEXTDEFnil()
| 1 => TEXTDEFval(arena_load<atext>(ptr_add<byte>(p, 8)))
| 2 => TEXTDEFfun(arena_load<atextfun>(ptr_add<byte>(p, 8)))
| _ => TEXTDEFfstr(arena_load<atextfstr>(ptr_add<byte>(p, 8)))
//
end // end of [atextdef_view]

implement
atextdef_view_free
  (v) =
(
case+ v of
| ~TEXTDEFnil() => ()
| ~TEXTDEFval(_) => ()
| ~TEXTDEFfun(_) => ()
| ~TEXTDEFfstr(_) => ()
) (* end of [atextdef_view_free] *)

(* ****** ****** *)

implement
commarg_CAhelp
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{commarg}(p)
end // end of [commarg_CAhelp]

implement
commarg_CAgitem
  (a0) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 1)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{commarg}(p)
end // end of [commarg_CAgitem]

implement
commarg_CAnsharp
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 2)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
val () = arena_store<gopt(string)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{commarg}(p)
end // end of [commarg_CAnsharp]

implement
commarg_CAinpfil
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 3)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
val () = arena_store<gopt(string)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{commarg}(p)
end // end of [commarg_CAinpfil]

implement
commarg_CAoutfil
  (a0, a1) = let
val p = the_garena_alloc(i2sz(24))
val () = arena_store<int>(p, 4)
val () = arena_store<string>(ptr_add<byte>(p, 8), a0)
val () = arena_store<gopt(string)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{commarg}(p)
end // end of [commarg_CAoutfil]

implement
commarg_encode
  (v) =
(
case+ v of
| ~CAhelp(a0) => commarg_CAhelp(a0)
| ~CAgitem(a0) => commarg_CAgitem(a0)
| ~CAnsharp(a0, a1) => commarg_CAnsharp(a0, a1)
| ~CAinpfil(a0, a1) => commarg_CAinpfil(a0, a1)
| ~CAoutfil(a0, a1) => commarg_CAoutfil(a0, a1)
) (* end of [commarg_encode] *)

implement
commarg_tag
  (x) = arena_load<int>($UN.cast{ptr}(x))

implement
commarg_is_CAhelp
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
commarg_is_CAgitem
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
commarg_is_CAnsharp
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
commarg_is_CAinpfil
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
commarg_is_CAoutfil
  (x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
commarg_view
  (x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => CAhelp(arena_load<string>(ptr_add<byte>(p, 8)))
| 1 => CAgitem(arena_load<string>(ptr_add<byte>(p, 8)))
| 2 => CAnsharp(arena_load<string>(ptr_add<byte>(p, 8)), arena_load<gopt(string)>(ptr_add<byte>(p, 16)))
| 3 => CAinpfil(arena_load<string>(ptr_add<byte>(p, 8)), arena_load<gopt(string)>(ptr_add<byte>(p, 16)))
| _ => CAoutfil(arena_load<string>(ptr_add<byte>(p, 8)), arena_load<gopt(string)>(ptr_add<byte>(p, 16)))
//
end // end of [commarg_view]

implement
commarg_view_free
  (v) =
(
case+ v of
| ~CAhelp(_) => ()
| ~CAgitem(_) => ()
| ~CAnsharp(_, _) => ()
| ~CAinpfil(_, _) => ()
| ~CAoutfil(_, _) => ()
) (* end of [commarg_view_free] *)

(* ****** ****** *)
