(* dynamic expressions: data *)
val a1 = (1, 2, 3)
val a2 = @(1, 2, 3)
val a3 = '(1, 2)
val a4 = @{x= 1, y= 2}
val a5 = '{x= 1, y= 2}
val a6 = (1 | 2)
val a7 = (pf | 2, 3)
val a8 = $tup (1, 2)
val a9 = $record {x= 1}
val a10 = list_vt_nil ()
val a11 = $list_vt (1, 2, 3)
val a12 = $list {int} (1, 2, 3)
val a13 = $list{int}()
val a14 = @[int](1, 2, 3)
val a15 = @[int][3](0)
val a16 = @[int][3]()
val a17 = $arrpsz{int}(1, 2, 3)
val a18 = $arrpsz(1, 2, 3)
val a19 = arr[0]
val a20 = arr[0, 1]
val a21 = arr[i][j]
val a22 = x.y
val a23 = x.1
val a24 = x.y.z
val a25 = p->x
val a26 = p->x->y
val a27 = !p
val a28 = !p.x
val a29 = &x
val a30 = &x.y
val a31 = &arr[0]
val a32 = view@ x
val a33 = x.[0]
val a34 = $ldelay (1)
val a35 = $delay (1)
val a36 = $effmask_all (1)
val a37 = ~x
val a38 = x + y * z
val a39 = x :: y :: nil
val a40 = (x := 1)
val a41 = (x :=: y)
val a42 = f (x) (y)
val a43 = f<int> (x)
val a44 = f {n} (x)
val a45 = f {n} {m} (x, y)
val a46 = f {n,m} (x, y)
val a48 = f (x | y)
val a49 = fold@ x
val a50 = free@ x
val a52 = #[n:int | n > 0] x
val a53 = 'a'
val a54 = "str" "ing"
val a55 = 0xFF
val a56 = 0777
val a57 = 1.5e3
val a58 = 123L
val a59 = 123UL
val a60 = 1.5f
val a61 = '\n'
val a62 = $mylocation
val a63 = $showtype x
val a64 = (x, y) : (int, int)
val a65 = x : int
