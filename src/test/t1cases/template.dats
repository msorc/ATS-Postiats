(* templates *)
fun{a:t@ype} foo (x: a): a = x
fun{a,b:t@ype} bar (x: a, y: b): (a, b) = (x, y)
extern fun{a:t@ype} baz (x: a): a
implement{a} baz (x) = foo<a> (x)
implement baz<int> (x) = x + 1
implement {a} baz2 (x) = x
implement baz3<int><bool> (x) = x
val a = foo<int> (1)
val b = bar<int,bool> (1, true)
val c = baz<int> (1)
fun{a:t@ype}{b:t@ype} qux (x: a, y: b) = x
val e = qux<int><bool> (1, true)
extern fun{} p1 (): void
implement(a) p2<a> (x) = x
val g = (foo<int>)
val h = foo<int>
val j = list_vt_cons<int>(1, list_vt_nil())
