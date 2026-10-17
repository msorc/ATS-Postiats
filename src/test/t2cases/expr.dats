// dynamic expressions
val i1 = 1 + 2 * 3
val i2 = ~i1
val b1 = (i1 > 3) && not (i1 = 2) || false
val c1 = 'a'
val s1 = "hello"
val f1 = 3.14
val u1 = ()
val t1 = (1, true)
val t2 = @(1, 'c', "s")
val t3 = '(1, 2)
val r1 = @{ x= 1, y= true }
val r2 = '{ x= 1, y= 2 }
val r3 = @{ x= 1, y= true }.x
val l1 = $list (1, 2, 3)
val l2 = $list_vt (1, 2)
val a1 = @[int][3] (1, 2, 3)
val a2 = @[int][2] (0)
val a3 = @[int] (1, 2)
val x1 = if true then 1 else 2
val x2 = if true then ()
val x3 = (if false then 1 else 2) : int
val x4 = let val y = 1; val z = 2 in y + z end
val x5 = y + z where { val y = 1 val z = 2 }
val x6 = (1; 2; 3)
val x7 = case+ 1 of 0 => 0 | n when n > 0 => n | _ => ~1
val x8 = case 1 of 0 => 0 | _ => 1
val x9 = lam (x: int): int => x + 1
val x10 = llam (x: int): int => x + 1
val x11 = fix f (n: int): int => if n > 0 then n * f (n-1) else 1
val x12 = lam (x: int, y: int): int => x + y
val x13 = lam@ (x: int): int => x
val x14 = lam (): int => 0
val x15 = lam (x: int): [n:nat] int n => abs (x)
val x16 = try 1 with ~MyExn => 2
val x17 = $raise MyExn
val x18 = (1: int)
val x19 = $effmask_all (1)
val x20 = $effmask_wrt (2)
val x21 = $effmask_ntm (3)
val x22 = $tyrep (int)
val x23 = $extval (int, "0")
val x24 = $extfcall (int, "f", 1, 2)
val x25 = $extmcall (int, x23, "m", 1)
val x26 = $ldelay (1)
val x27 = $ldelay (1, ())
val x28 = $delay (1)
val x29 = $showtype (1)
val x30 = $mylocation
val x31 = $myfilename
val x32 = $myfunction
val x33 = $arrpsz{int} (1, 2)
val x34 = $arrpsz (1, 2)
var v1: int = 0
var v2 = 1
var v3: int with pf = 0
prvar pv: int = 0
val () = v1 := 1
val () = v1 := v1 + 1
val x35 = !p where { val p = $UNSAFE.cast{ptr} (0) }
val x36 = ~i1 + (i1 land 1) + (i1 lor 2) + (i1 lxor 3)
val x37 = i1 mod 2 + i1 / 2 + i1 - 1
fun app0 (f: int -> int, x: int): int = f (x)
fun app1 (x: int): int = app0 (lam y => y + x, 1)
fun app2 {a:t@ype} (x: a): a = x
val x38 = app2<int> (1)
val x39 = app2 (1)
fnx f1 (x: int): int = f2 (x)
and f2 (x: int): int = if x > 0 then f1 (x - 1) else 0
fun{a:t@ype} tf (x: a): a = x
val x40 = tf<int> (1)
val () = println! ("a", 1)
val () = print "x"
val () = prerr "y"
