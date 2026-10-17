implement
label_LABint
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 0)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{label(l)}(p)
end // end of [label_LABint]

implement
label_LABsym
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 1)
val () = arena_store<symbol(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{label(l)}(p)
end // end of [label_LABsym]

implement
label_encode
  {l}(ar, v) =
(
case+ v of
| ~LABint(a0) => label_LABint(ar, a0)
| ~LABsym(a0) => label_LABsym(ar, a0)
) (* end of [label_encode] *)

implement
label_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
label_is_LABint
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
label_is_LABsym
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
label_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => LABint(arena_load<int>(ptr_add<byte>(p, 8)))
| _ => LABsym(arena_load<symbol(l)>(ptr_add<byte>(p, 8)))
//
end // end of [label_view]

implement
label_view_free
  (v) =
(
case+ v of
| ~LABint(_) => ()
| ~LABsym(_) => ()
) (* end of [label_view_free] *)

(* ****** ****** *)

implement
s2rt_S2RTint
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 0)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTint]

implement
s2rt_S2RTaddr
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 1)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTaddr]

implement
s2rt_S2RTbool
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 2)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTbool]

implement
s2rt_S2RTreal
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 3)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTreal]

implement
s2rt_S2RTfloat
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 4)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTfloat]

implement
s2rt_S2RTstring
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 5)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTstring]

implement
s2rt_S2RTcls
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 6)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTcls]

implement
s2rt_S2RTeff
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 7)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTeff]

implement
s2rt_S2RTtup
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 8)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTtup]

implement
s2rt_S2RTtype
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 9)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTtype]

implement
s2rt_S2RTvtype
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 10)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTvtype]

implement
s2rt_S2RTt0ype
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 11)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTt0ype]

implement
s2rt_S2RTvt0ype
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 12)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTvt0ype]

implement
s2rt_S2RTprop
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 13)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTprop]

implement
s2rt_S2RTview
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 14)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTview]

implement
s2rt_S2RTtkind
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 15)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTtkind]

implement
s2rt_S2RTfun
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 16)
val () = arena_store<alist(l, s2rt(l))>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s2rt(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTfun]

implement
s2rt_S2RTnamed
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 17)
val () = arena_store<symbol(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTnamed]

implement
s2rt_S2RTerror
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 18)
in
  $UN.cast{s2rt(l)}(p)
end // end of [s2rt_S2RTerror]

implement
s2rt_encode
  {l}(ar, v) =
(
case+ v of
| ~S2RTint() => s2rt_S2RTint(ar)
| ~S2RTaddr() => s2rt_S2RTaddr(ar)
| ~S2RTbool() => s2rt_S2RTbool(ar)
| ~S2RTreal() => s2rt_S2RTreal(ar)
| ~S2RTfloat() => s2rt_S2RTfloat(ar)
| ~S2RTstring() => s2rt_S2RTstring(ar)
| ~S2RTcls() => s2rt_S2RTcls(ar)
| ~S2RTeff() => s2rt_S2RTeff(ar)
| ~S2RTtup() => s2rt_S2RTtup(ar)
| ~S2RTtype() => s2rt_S2RTtype(ar)
| ~S2RTvtype() => s2rt_S2RTvtype(ar)
| ~S2RTt0ype() => s2rt_S2RTt0ype(ar)
| ~S2RTvt0ype() => s2rt_S2RTvt0ype(ar)
| ~S2RTprop() => s2rt_S2RTprop(ar)
| ~S2RTview() => s2rt_S2RTview(ar)
| ~S2RTtkind() => s2rt_S2RTtkind(ar)
| ~S2RTfun(a0, a1) => s2rt_S2RTfun(ar, a0, a1)
| ~S2RTnamed(a0) => s2rt_S2RTnamed(ar, a0)
| ~S2RTerror() => s2rt_S2RTerror(ar)
) (* end of [s2rt_encode] *)

implement
s2rt_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
s2rt_is_S2RTint
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
s2rt_is_S2RTaddr
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
s2rt_is_S2RTbool
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
s2rt_is_S2RTreal
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
s2rt_is_S2RTfloat
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
s2rt_is_S2RTstring
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
s2rt_is_S2RTcls
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
s2rt_is_S2RTeff
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 7)

implement
s2rt_is_S2RTtup
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 8)

implement
s2rt_is_S2RTtype
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 9)

implement
s2rt_is_S2RTvtype
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 10)

implement
s2rt_is_S2RTt0ype
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 11)

implement
s2rt_is_S2RTvt0ype
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 12)

implement
s2rt_is_S2RTprop
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 13)

implement
s2rt_is_S2RTview
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 14)

implement
s2rt_is_S2RTtkind
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 15)

implement
s2rt_is_S2RTfun
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 16)

implement
s2rt_is_S2RTnamed
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 17)

implement
s2rt_is_S2RTerror
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 18)

implement
s2rt_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => S2RTint()
| 1 => S2RTaddr()
| 2 => S2RTbool()
| 3 => S2RTreal()
| 4 => S2RTfloat()
| 5 => S2RTstring()
| 6 => S2RTcls()
| 7 => S2RTeff()
| 8 => S2RTtup()
| 9 => S2RTtype()
| 10 => S2RTvtype()
| 11 => S2RTt0ype()
| 12 => S2RTvt0ype()
| 13 => S2RTprop()
| 14 => S2RTview()
| 15 => S2RTtkind()
| 16 => S2RTfun(arena_load<alist(l, s2rt(l))>(ptr_add<byte>(p, 8)), arena_load<s2rt(l)>(ptr_add<byte>(p, 16)))
| 17 => S2RTnamed(arena_load<symbol(l)>(ptr_add<byte>(p, 8)))
| _ => S2RTerror()
//
end // end of [s2rt_view]

implement
s2rt_view_free
  (v) =
(
case+ v of
| ~S2RTint() => ()
| ~S2RTaddr() => ()
| ~S2RTbool() => ()
| ~S2RTreal() => ()
| ~S2RTfloat() => ()
| ~S2RTstring() => ()
| ~S2RTcls() => ()
| ~S2RTeff() => ()
| ~S2RTtup() => ()
| ~S2RTtype() => ()
| ~S2RTvtype() => ()
| ~S2RTt0ype() => ()
| ~S2RTvt0ype() => ()
| ~S2RTprop() => ()
| ~S2RTview() => ()
| ~S2RTtkind() => ()
| ~S2RTfun(_, _) => ()
| ~S2RTnamed(_) => ()
| ~S2RTerror() => ()
) (* end of [s2rt_view_free] *)

(* ****** ****** *)

implement
tyreckind_TYRECKINDbox
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 0)
in
  $UN.cast{tyreckind(l)}(p)
end // end of [tyreckind_TYRECKINDbox]

implement
tyreckind_TYRECKINDbox_lin
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 1)
in
  $UN.cast{tyreckind(l)}(p)
end // end of [tyreckind_TYRECKINDbox_lin]

implement
tyreckind_TYRECKINDflt0
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 2)
in
  $UN.cast{tyreckind(l)}(p)
end // end of [tyreckind_TYRECKINDflt0]

implement
tyreckind_TYRECKINDflt1
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 3)
val () = arena_store<stamp>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{tyreckind(l)}(p)
end // end of [tyreckind_TYRECKINDflt1]

implement
tyreckind_TYRECKINDflt_ext
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 4)
val () = arena_store<astring(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{tyreckind(l)}(p)
end // end of [tyreckind_TYRECKINDflt_ext]

implement
tyreckind_encode
  {l}(ar, v) =
(
case+ v of
| ~TYRECKINDbox() => tyreckind_TYRECKINDbox(ar)
| ~TYRECKINDbox_lin() => tyreckind_TYRECKINDbox_lin(ar)
| ~TYRECKINDflt0() => tyreckind_TYRECKINDflt0(ar)
| ~TYRECKINDflt1(a0) => tyreckind_TYRECKINDflt1(ar, a0)
| ~TYRECKINDflt_ext(a0) => tyreckind_TYRECKINDflt_ext(ar, a0)
) (* end of [tyreckind_encode] *)

implement
tyreckind_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
tyreckind_is_TYRECKINDbox
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
tyreckind_is_TYRECKINDbox_lin
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
tyreckind_is_TYRECKINDflt0
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
tyreckind_is_TYRECKINDflt1
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
tyreckind_is_TYRECKINDflt_ext
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
tyreckind_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => TYRECKINDbox()
| 1 => TYRECKINDbox_lin()
| 2 => TYRECKINDflt0()
| 3 => TYRECKINDflt1(arena_load<stamp>(ptr_add<byte>(p, 8)))
| _ => TYRECKINDflt_ext(arena_load<astring(l)>(ptr_add<byte>(p, 8)))
//
end // end of [tyreckind_view]

implement
tyreckind_view_free
  (v) =
(
case+ v of
| ~TYRECKINDbox() => ()
| ~TYRECKINDbox_lin() => ()
| ~TYRECKINDflt0() => ()
| ~TYRECKINDflt1(_) => ()
| ~TYRECKINDflt_ext(_) => ()
) (* end of [tyreckind_view_free] *)

(* ****** ****** *)

implement
s2exp_S2EXP
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<s2rt(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s2exp_node(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{s2exp(l)}(p)
end // end of [s2exp_S2EXP]

implement
s2exp_encode
  {l}(ar, v) =
(
case+ v of
| ~S2EXP(a0, a1) => s2exp_S2EXP(ar, a0, a1)
) (* end of [s2exp_encode] *)

implement
s2exp_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
s2exp_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => S2EXP(arena_load<s2rt(l)>(ptr_add<byte>(p, 8)), arena_load<s2exp_node(l)>(ptr_add<byte>(p, 16)))
//
end // end of [s2exp_view]

implement
s2exp_view_free
  (v) =
(
case+ v of
| ~S2EXP(_, _) => ()
) (* end of [s2exp_view_free] *)

implement
s2exp_get_srt
  {l}(ar, x) =
  arena_load<s2rt(l)>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
s2exp_get_node
  {l}(ar, x) =
  arena_load<s2exp_node(l)>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
s2exp_node_S2Eint
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 0)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Eint]

implement
s2exp_node_S2Eintinf
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 1)
val () = arena_store<astring(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Eintinf]

implement
s2exp_node_S2Ecst
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 2)
val () = arena_store<s2cst(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Ecst]

implement
s2exp_node_S2Evar
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 3)
val () = arena_store<s2var(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Evar]

implement
s2exp_node_S2EVar
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 4)
val () = arena_store<s2Var(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2EVar]

implement
s2exp_node_S2Eeqeq
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 5)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Eeqeq]

implement
s2exp_node_S2Esizeof
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 6)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Esizeof]

implement
s2exp_node_S2Eapp
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 7)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<alist(l, s2exp(l))>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Eapp]

implement
s2exp_node_S2Emetdec
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 8)
val () = arena_store<alist(l, s2exp(l))>(ptr_add<byte>(p, 8), a0)
val () = arena_store<alist(l, s2exp(l))>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Emetdec]

implement
s2exp_node_S2Etop
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 9)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Etop]

implement
s2exp_node_S2Einvar
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 10)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Einvar]

implement
s2exp_node_S2Efun
  {l}(ar, a0, a1, a2) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 11)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
val () = arena_store<alist(l, s2exp(l))>(ptr_add<byte>(p, 16), a1)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Efun]

implement
s2exp_node_S2Euni
  {l}(ar, a0, a1, a2) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 12)
val () = arena_store<alist(l, s2var(l))>(ptr_add<byte>(p, 8), a0)
val () = arena_store<alist(l, s2exp(l))>(ptr_add<byte>(p, 16), a1)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Euni]

implement
s2exp_node_S2Eexi
  {l}(ar, a0, a1, a2) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 13)
val () = arena_store<alist(l, s2var(l))>(ptr_add<byte>(p, 8), a0)
val () = arena_store<alist(l, s2exp(l))>(ptr_add<byte>(p, 16), a1)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Eexi]

implement
s2exp_node_S2Etyrec
  {l}(ar, a0, a1, a2) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 14)
val () = arena_store<tyreckind(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<int>(ptr_add<byte>(p, 16), a1)
val () = arena_store<alist(l, labs2exp(l))>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Etyrec]

implement
s2exp_node_S2Eextype
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 15)
val () = arena_store<symbol(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Eextype]

implement
s2exp_node_S2Eextkind
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 16)
val () = arena_store<symbol(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Eextkind]

implement
s2exp_node_S2Eerror
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 17)
in
  $UN.cast{s2exp_node(l)}(p)
end // end of [s2exp_node_S2Eerror]

implement
s2exp_node_encode
  {l}(ar, v) =
(
case+ v of
| ~S2Eint(a0) => s2exp_node_S2Eint(ar, a0)
| ~S2Eintinf(a0) => s2exp_node_S2Eintinf(ar, a0)
| ~S2Ecst(a0) => s2exp_node_S2Ecst(ar, a0)
| ~S2Evar(a0) => s2exp_node_S2Evar(ar, a0)
| ~S2EVar(a0) => s2exp_node_S2EVar(ar, a0)
| ~S2Eeqeq(a0, a1) => s2exp_node_S2Eeqeq(ar, a0, a1)
| ~S2Esizeof(a0) => s2exp_node_S2Esizeof(ar, a0)
| ~S2Eapp(a0, a1) => s2exp_node_S2Eapp(ar, a0, a1)
| ~S2Emetdec(a0, a1) => s2exp_node_S2Emetdec(ar, a0, a1)
| ~S2Etop(a0, a1) => s2exp_node_S2Etop(ar, a0, a1)
| ~S2Einvar(a0) => s2exp_node_S2Einvar(ar, a0)
| ~S2Efun(a0, a1, a2) => s2exp_node_S2Efun(ar, a0, a1, a2)
| ~S2Euni(a0, a1, a2) => s2exp_node_S2Euni(ar, a0, a1, a2)
| ~S2Eexi(a0, a1, a2) => s2exp_node_S2Eexi(ar, a0, a1, a2)
| ~S2Etyrec(a0, a1, a2) => s2exp_node_S2Etyrec(ar, a0, a1, a2)
| ~S2Eextype(a0) => s2exp_node_S2Eextype(ar, a0)
| ~S2Eextkind(a0) => s2exp_node_S2Eextkind(ar, a0)
| ~S2Eerror() => s2exp_node_S2Eerror(ar)
) (* end of [s2exp_node_encode] *)

implement
s2exp_node_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
s2exp_node_is_S2Eint
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
s2exp_node_is_S2Eintinf
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
s2exp_node_is_S2Ecst
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
s2exp_node_is_S2Evar
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
s2exp_node_is_S2EVar
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
s2exp_node_is_S2Eeqeq
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
s2exp_node_is_S2Esizeof
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
s2exp_node_is_S2Eapp
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 7)

implement
s2exp_node_is_S2Emetdec
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 8)

implement
s2exp_node_is_S2Etop
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 9)

implement
s2exp_node_is_S2Einvar
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 10)

implement
s2exp_node_is_S2Efun
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 11)

implement
s2exp_node_is_S2Euni
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 12)

implement
s2exp_node_is_S2Eexi
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 13)

implement
s2exp_node_is_S2Etyrec
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 14)

implement
s2exp_node_is_S2Eextype
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 15)

implement
s2exp_node_is_S2Eextkind
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 16)

implement
s2exp_node_is_S2Eerror
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 17)

implement
s2exp_node_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => S2Eint(arena_load<int>(ptr_add<byte>(p, 8)))
| 1 => S2Eintinf(arena_load<astring(l)>(ptr_add<byte>(p, 8)))
| 2 => S2Ecst(arena_load<s2cst(l)>(ptr_add<byte>(p, 8)))
| 3 => S2Evar(arena_load<s2var(l)>(ptr_add<byte>(p, 8)))
| 4 => S2EVar(arena_load<s2Var(l)>(ptr_add<byte>(p, 8)))
| 5 => S2Eeqeq(arena_load<s2exp(l)>(ptr_add<byte>(p, 8)), arena_load<s2exp(l)>(ptr_add<byte>(p, 16)))
| 6 => S2Esizeof(arena_load<s2exp(l)>(ptr_add<byte>(p, 8)))
| 7 => S2Eapp(arena_load<s2exp(l)>(ptr_add<byte>(p, 8)), arena_load<alist(l, s2exp(l))>(ptr_add<byte>(p, 16)))
| 8 => S2Emetdec(arena_load<alist(l, s2exp(l))>(ptr_add<byte>(p, 8)), arena_load<alist(l, s2exp(l))>(ptr_add<byte>(p, 16)))
| 9 => S2Etop(arena_load<int>(ptr_add<byte>(p, 8)), arena_load<s2exp(l)>(ptr_add<byte>(p, 16)))
| 10 => S2Einvar(arena_load<s2exp(l)>(ptr_add<byte>(p, 8)))
| 11 => S2Efun(arena_load<int>(ptr_add<byte>(p, 8)), arena_load<alist(l, s2exp(l))>(ptr_add<byte>(p, 16)), arena_load<s2exp(l)>(ptr_add<byte>(p, 24)))
| 12 => S2Euni(arena_load<alist(l, s2var(l))>(ptr_add<byte>(p, 8)), arena_load<alist(l, s2exp(l))>(ptr_add<byte>(p, 16)), arena_load<s2exp(l)>(ptr_add<byte>(p, 24)))
| 13 => S2Eexi(arena_load<alist(l, s2var(l))>(ptr_add<byte>(p, 8)), arena_load<alist(l, s2exp(l))>(ptr_add<byte>(p, 16)), arena_load<s2exp(l)>(ptr_add<byte>(p, 24)))
| 14 => S2Etyrec(arena_load<tyreckind(l)>(ptr_add<byte>(p, 8)), arena_load<int>(ptr_add<byte>(p, 16)), arena_load<alist(l, labs2exp(l))>(ptr_add<byte>(p, 24)))
| 15 => S2Eextype(arena_load<symbol(l)>(ptr_add<byte>(p, 8)))
| 16 => S2Eextkind(arena_load<symbol(l)>(ptr_add<byte>(p, 8)))
| _ => S2Eerror()
//
end // end of [s2exp_node_view]

implement
s2exp_node_view_free
  (v) =
(
case+ v of
| ~S2Eint(_) => ()
| ~S2Eintinf(_) => ()
| ~S2Ecst(_) => ()
| ~S2Evar(_) => ()
| ~S2EVar(_) => ()
| ~S2Eeqeq(_, _) => ()
| ~S2Esizeof(_) => ()
| ~S2Eapp(_, _) => ()
| ~S2Emetdec(_, _) => ()
| ~S2Etop(_, _) => ()
| ~S2Einvar(_) => ()
| ~S2Efun(_, _, _) => ()
| ~S2Euni(_, _, _) => ()
| ~S2Eexi(_, _, _) => ()
| ~S2Etyrec(_, _, _) => ()
| ~S2Eextype(_) => ()
| ~S2Eextkind(_) => ()
| ~S2Eerror() => ()
) (* end of [s2exp_node_view_free] *)

(* ****** ****** *)

implement
labs2exp_SLABELED
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<label(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{labs2exp(l)}(p)
end // end of [labs2exp_SLABELED]

implement
labs2exp_encode
  {l}(ar, v) =
(
case+ v of
| ~SLABELED(a0, a1) => labs2exp_SLABELED(ar, a0, a1)
) (* end of [labs2exp_encode] *)

implement
labs2exp_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
labs2exp_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => SLABELED(arena_load<label(l)>(ptr_add<byte>(p, 8)), arena_load<s2exp(l)>(ptr_add<byte>(p, 16)))
//
end // end of [labs2exp_view]

implement
labs2exp_view_free
  (v) =
(
case+ v of
| ~SLABELED(_, _) => ()
) (* end of [labs2exp_view_free] *)

implement
labs2exp_get_lab
  {l}(ar, x) =
  arena_load<label(l)>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
labs2exp_get_exp
  {l}(ar, x) =
  arena_load<s2exp(l)>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
c3nstrkind_C3TKmain
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 0)
in
  $UN.cast{c3nstrkind(l)}(p)
end // end of [c3nstrkind_C3TKmain]

implement
c3nstrkind_C3TKtermet_isnat
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 1)
in
  $UN.cast{c3nstrkind(l)}(p)
end // end of [c3nstrkind_C3TKtermet_isnat]

implement
c3nstrkind_C3TKtermet_isdec
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 2)
in
  $UN.cast{c3nstrkind(l)}(p)
end // end of [c3nstrkind_C3TKtermet_isdec]

implement
c3nstrkind_C3TKsolver
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 3)
val () = arena_store<int>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{c3nstrkind(l)}(p)
end // end of [c3nstrkind_C3TKsolver]

implement
c3nstrkind_C3TKignored
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 4)
in
  $UN.cast{c3nstrkind(l)}(p)
end // end of [c3nstrkind_C3TKignored]

implement
c3nstrkind_encode
  {l}(ar, v) =
(
case+ v of
| ~C3TKmain() => c3nstrkind_C3TKmain(ar)
| ~C3TKtermet_isnat() => c3nstrkind_C3TKtermet_isnat(ar)
| ~C3TKtermet_isdec() => c3nstrkind_C3TKtermet_isdec(ar)
| ~C3TKsolver(a0) => c3nstrkind_C3TKsolver(ar, a0)
| ~C3TKignored() => c3nstrkind_C3TKignored(ar)
) (* end of [c3nstrkind_encode] *)

implement
c3nstrkind_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
c3nstrkind_is_C3TKmain
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
c3nstrkind_is_C3TKtermet_isnat
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
c3nstrkind_is_C3TKtermet_isdec
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
c3nstrkind_is_C3TKsolver
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
c3nstrkind_is_C3TKignored
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
c3nstrkind_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => C3TKmain()
| 1 => C3TKtermet_isnat()
| 2 => C3TKtermet_isdec()
| 3 => C3TKsolver(arena_load<int>(ptr_add<byte>(p, 8)))
| _ => C3TKignored()
//
end // end of [c3nstrkind_view]

implement
c3nstrkind_view_free
  (v) =
(
case+ v of
| ~C3TKmain() => ()
| ~C3TKtermet_isnat() => ()
| ~C3TKtermet_isdec() => ()
| ~C3TKsolver(_) => ()
| ~C3TKignored() => ()
) (* end of [c3nstrkind_view_free] *)

(* ****** ****** *)

implement
s3itm_S3ITMsvar
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<s2var(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s3itm(l)}(p)
end // end of [s3itm_S3ITMsvar]

implement
s3itm_S3ITMsVar
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 1)
val () = arena_store<s2Var(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s3itm(l)}(p)
end // end of [s3itm_S3ITMsVar]

implement
s3itm_S3ITMhypo
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 2)
val () = arena_store<h3ypo(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s3itm(l)}(p)
end // end of [s3itm_S3ITMhypo]

implement
s3itm_S3ITMcnstr
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 3)
val () = arena_store<c3nstr(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s3itm(l)}(p)
end // end of [s3itm_S3ITMcnstr]

implement
s3itm_S3ITMcnstr_ref
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 4)
val () = arena_store<astring(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<c3nstropt(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{s3itm(l)}(p)
end // end of [s3itm_S3ITMcnstr_ref]

implement
s3itm_S3ITMdisj
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 5)
val () = arena_store<alist(l, alist(l, s3itm(l)))>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s3itm(l)}(p)
end // end of [s3itm_S3ITMdisj]

implement
s3itm_S3ITMsolassert
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 6)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{s3itm(l)}(p)
end // end of [s3itm_S3ITMsolassert]

implement
s3itm_encode
  {l}(ar, v) =
(
case+ v of
| ~S3ITMsvar(a0) => s3itm_S3ITMsvar(ar, a0)
| ~S3ITMsVar(a0) => s3itm_S3ITMsVar(ar, a0)
| ~S3ITMhypo(a0) => s3itm_S3ITMhypo(ar, a0)
| ~S3ITMcnstr(a0) => s3itm_S3ITMcnstr(ar, a0)
| ~S3ITMcnstr_ref(a0, a1) => s3itm_S3ITMcnstr_ref(ar, a0, a1)
| ~S3ITMdisj(a0) => s3itm_S3ITMdisj(ar, a0)
| ~S3ITMsolassert(a0) => s3itm_S3ITMsolassert(ar, a0)
) (* end of [s3itm_encode] *)

implement
s3itm_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
s3itm_is_S3ITMsvar
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
s3itm_is_S3ITMsVar
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
s3itm_is_S3ITMhypo
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
s3itm_is_S3ITMcnstr
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 3)

implement
s3itm_is_S3ITMcnstr_ref
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 4)

implement
s3itm_is_S3ITMdisj
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 5)

implement
s3itm_is_S3ITMsolassert
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 6)

implement
s3itm_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => S3ITMsvar(arena_load<s2var(l)>(ptr_add<byte>(p, 8)))
| 1 => S3ITMsVar(arena_load<s2Var(l)>(ptr_add<byte>(p, 8)))
| 2 => S3ITMhypo(arena_load<h3ypo(l)>(ptr_add<byte>(p, 8)))
| 3 => S3ITMcnstr(arena_load<c3nstr(l)>(ptr_add<byte>(p, 8)))
| 4 => S3ITMcnstr_ref(arena_load<astring(l)>(ptr_add<byte>(p, 8)), arena_load<c3nstropt(l)>(ptr_add<byte>(p, 16)))
| 5 => S3ITMdisj(arena_load<alist(l, alist(l, s3itm(l)))>(ptr_add<byte>(p, 8)))
| _ => S3ITMsolassert(arena_load<s2exp(l)>(ptr_add<byte>(p, 8)))
//
end // end of [s3itm_view]

implement
s3itm_view_free
  (v) =
(
case+ v of
| ~S3ITMsvar(_) => ()
| ~S3ITMsVar(_) => ()
| ~S3ITMhypo(_) => ()
| ~S3ITMcnstr(_) => ()
| ~S3ITMcnstr_ref(_, _) => ()
| ~S3ITMdisj(_) => ()
| ~S3ITMsolassert(_) => ()
) (* end of [s3itm_view_free] *)

(* ****** ****** *)

implement
h3ypo_H3YPO
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<astring(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<h3ypo_node(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{h3ypo(l)}(p)
end // end of [h3ypo_H3YPO]

implement
h3ypo_encode
  {l}(ar, v) =
(
case+ v of
| ~H3YPO(a0, a1) => h3ypo_H3YPO(ar, a0, a1)
) (* end of [h3ypo_encode] *)

implement
h3ypo_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
h3ypo_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => H3YPO(arena_load<astring(l)>(ptr_add<byte>(p, 8)), arena_load<h3ypo_node(l)>(ptr_add<byte>(p, 16)))
//
end // end of [h3ypo_view]

implement
h3ypo_view_free
  (v) =
(
case+ v of
| ~H3YPO(_, _) => ()
) (* end of [h3ypo_view_free] *)

implement
h3ypo_get_loc
  {l}(ar, x) =
  arena_load<astring(l)>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
h3ypo_get_node
  {l}(ar, x) =
  arena_load<h3ypo_node(l)>(ptr_add<byte>($UN.cast{ptr}(x), 16))

(* ****** ****** *)

implement
h3ypo_node_H3YPOprop
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 0)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{h3ypo_node(l)}(p)
end // end of [h3ypo_node_H3YPOprop]

implement
h3ypo_node_H3YPObind
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 1)
val () = arena_store<s2var(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{h3ypo_node(l)}(p)
end // end of [h3ypo_node_H3YPObind]

implement
h3ypo_node_H3YPOeqeq
  {l}(ar, a0, a1) = let
val p = arena_alloc(ar, i2sz(24))
val () = arena_store<int>(p, 2)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 16), a1)
in
  $UN.cast{h3ypo_node(l)}(p)
end // end of [h3ypo_node_H3YPOeqeq]

implement
h3ypo_node_encode
  {l}(ar, v) =
(
case+ v of
| ~H3YPOprop(a0) => h3ypo_node_H3YPOprop(ar, a0)
| ~H3YPObind(a0, a1) => h3ypo_node_H3YPObind(ar, a0, a1)
| ~H3YPOeqeq(a0, a1) => h3ypo_node_H3YPOeqeq(ar, a0, a1)
) (* end of [h3ypo_node_encode] *)

implement
h3ypo_node_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
h3ypo_node_is_H3YPOprop
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
h3ypo_node_is_H3YPObind
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
h3ypo_node_is_H3YPOeqeq
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
h3ypo_node_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => H3YPOprop(arena_load<s2exp(l)>(ptr_add<byte>(p, 8)))
| 1 => H3YPObind(arena_load<s2var(l)>(ptr_add<byte>(p, 8)), arena_load<s2exp(l)>(ptr_add<byte>(p, 16)))
| _ => H3YPOeqeq(arena_load<s2exp(l)>(ptr_add<byte>(p, 8)), arena_load<s2exp(l)>(ptr_add<byte>(p, 16)))
//
end // end of [h3ypo_node_view]

implement
h3ypo_node_view_free
  (v) =
(
case+ v of
| ~H3YPOprop(_) => ()
| ~H3YPObind(_, _) => ()
| ~H3YPOeqeq(_, _) => ()
) (* end of [h3ypo_node_view_free] *)

(* ****** ****** *)

implement
c3nstr_C3NSTR
  {l}(ar, a0, a1, a2) = let
val p = arena_alloc(ar, i2sz(32))
val () = arena_store<int>(p, 0)
val () = arena_store<astring(l)>(ptr_add<byte>(p, 8), a0)
val () = arena_store<c3nstrkind(l)>(ptr_add<byte>(p, 16), a1)
val () = arena_store<c3nstr_node(l)>(ptr_add<byte>(p, 24), a2)
in
  $UN.cast{c3nstr(l)}(p)
end // end of [c3nstr_C3NSTR]

implement
c3nstr_encode
  {l}(ar, v) =
(
case+ v of
| ~C3NSTR(a0, a1, a2) => c3nstr_C3NSTR(ar, a0, a1, a2)
) (* end of [c3nstr_encode] *)

implement
c3nstr_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
c3nstr_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| _ => C3NSTR(arena_load<astring(l)>(ptr_add<byte>(p, 8)), arena_load<c3nstrkind(l)>(ptr_add<byte>(p, 16)), arena_load<c3nstr_node(l)>(ptr_add<byte>(p, 24)))
//
end // end of [c3nstr_view]

implement
c3nstr_view_free
  (v) =
(
case+ v of
| ~C3NSTR(_, _, _) => ()
) (* end of [c3nstr_view_free] *)

implement
c3nstr_get_loc
  {l}(ar, x) =
  arena_load<astring(l)>(ptr_add<byte>($UN.cast{ptr}(x), 8))

implement
c3nstr_get_kind
  {l}(ar, x) =
  arena_load<c3nstrkind(l)>(ptr_add<byte>($UN.cast{ptr}(x), 16))

implement
c3nstr_get_node
  {l}(ar, x) =
  arena_load<c3nstr_node(l)>(ptr_add<byte>($UN.cast{ptr}(x), 24))

(* ****** ****** *)

implement
c3nstr_node_C3NSTRprop
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 0)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{c3nstr_node(l)}(p)
end // end of [c3nstr_node_C3NSTRprop]

implement
c3nstr_node_C3NSTRitmlst
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 1)
val () = arena_store<alist(l, s3itm(l))>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{c3nstr_node(l)}(p)
end // end of [c3nstr_node_C3NSTRitmlst]

implement
c3nstr_node_C3NSTRsolverify
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 2)
val () = arena_store<s2exp(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{c3nstr_node(l)}(p)
end // end of [c3nstr_node_C3NSTRsolverify]

implement
c3nstr_node_encode
  {l}(ar, v) =
(
case+ v of
| ~C3NSTRprop(a0) => c3nstr_node_C3NSTRprop(ar, a0)
| ~C3NSTRitmlst(a0) => c3nstr_node_C3NSTRitmlst(ar, a0)
| ~C3NSTRsolverify(a0) => c3nstr_node_C3NSTRsolverify(ar, a0)
) (* end of [c3nstr_node_encode] *)

implement
c3nstr_node_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
c3nstr_node_is_C3NSTRprop
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
c3nstr_node_is_C3NSTRitmlst
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
c3nstr_node_is_C3NSTRsolverify
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 2)

implement
c3nstr_node_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => C3NSTRprop(arena_load<s2exp(l)>(ptr_add<byte>(p, 8)))
| 1 => C3NSTRitmlst(arena_load<alist(l, s3itm(l))>(ptr_add<byte>(p, 8)))
| _ => C3NSTRsolverify(arena_load<s2exp(l)>(ptr_add<byte>(p, 8)))
//
end // end of [c3nstr_node_view]

implement
c3nstr_node_view_free
  (v) =
(
case+ v of
| ~C3NSTRprop(_) => ()
| ~C3NSTRitmlst(_) => ()
| ~C3NSTRsolverify(_) => ()
) (* end of [c3nstr_node_view_free] *)

(* ****** ****** *)

implement
c3nstropt_C3NSTRnone
  {l}(ar) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 0)
in
  $UN.cast{c3nstropt(l)}(p)
end // end of [c3nstropt_C3NSTRnone]

implement
c3nstropt_C3NSTRsome
  {l}(ar, a0) = let
val p = arena_alloc(ar, i2sz(16))
val () = arena_store<int>(p, 1)
val () = arena_store<c3nstr(l)>(ptr_add<byte>(p, 8), a0)
in
  $UN.cast{c3nstropt(l)}(p)
end // end of [c3nstropt_C3NSTRsome]

implement
c3nstropt_encode
  {l}(ar, v) =
(
case+ v of
| ~C3NSTRnone() => c3nstropt_C3NSTRnone(ar)
| ~C3NSTRsome(a0) => c3nstropt_C3NSTRsome(ar, a0)
) (* end of [c3nstropt_encode] *)

implement
c3nstropt_tag
  (ar, x) = arena_load<int>($UN.cast{ptr}(x))

implement
c3nstropt_is_C3NSTRnone
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 0)

implement
c3nstropt_is_C3NSTRsome
  (ar, x) = (arena_load<int>($UN.cast{ptr}(x)) = 1)

implement
c3nstropt_view
  {l}(ar, x) = let
//
val p = $UN.cast{ptr}(x)
val tag = arena_load<int>(p)
//
in
//
case+ tag of
| 0 => C3NSTRnone()
| _ => C3NSTRsome(arena_load<c3nstr(l)>(ptr_add<byte>(p, 8)))
//
end // end of [c3nstropt_view]

implement
c3nstropt_view_free
  (v) =
(
case+ v of
| ~C3NSTRnone() => ()
| ~C3NSTRsome(_) => ()
) (* end of [c3nstropt_view_free] *)

(* ****** ****** *)
