(* effects: effect variables ({fe:eff}), effect annotations (<!exn>, <!ntm>, <!ref>, <!wrt>, <!all>), $effmask_*, checks that fail *)
#include "share/atspre_staload.hats"
exception MyExn of int

fun app0 {fe:eff} .<>. (f: () -<fe> void):<fe> void = f ()
fun app1 {fe:eff} .<>. (f: () -<fe> void):<> void = f ()
fun app2 {fe:eff} .<>. (f: () -<fe> void):<!exn> void = f ()
fun app3 {fe1,fe2:eff} .<>. (f: () -<fe1> void, g: () -<fe2> void):<fe1,fe2> void = (f (); g ())
fun app4 {fe1,fe2:eff} .<>. (f: () -<fe1> void, g: () -<fe2> void):<fe1> void = (f (); g ())
fun app5 {fe1,fe2:eff} .<>. (f: () -<fe1> void, g: () -<fe2> void):<fe2> void = (f (); g ())
fun app6 {fe:eff} .<>. (f: () -<fe> void):<!ref,fe> void = f ()
fun app7 {fe:eff} (f: () -<fe> void): void = $effmask_all (f ())
fun app8 {fe:eff} .<>. (f: () -<fe> void):<> void = $effmask_exn (f ())
fun app9 {fe:eff} .<>. (f: () -<fe> void):<> void = $effmask_ntm (f ())
fun app10 {fe:eff} .<>. (f: () -<fe> void):<> void = $effmask_ref (f ())
fun app11 {fe:eff} .<>. (f: () -<fe> void):<> void = $effmask_wrt (f ())
fun app12 {fe:eff} .<>. (f: () -<fe> void):<!all> void = f ()
fun app13 {fe:eff} .<>. (f: () -<fe> void):<!exn,!ntm,!ref,!wrt> void = f ()

fun e0 .<>. ():<!exn> int = $raise MyExn (1)
fun e1 .<>. ():<> int = e0 ()
fun e2 .<>. ():<!exn> int = e0 ()
fun e3 .<>. ():<!ntm> int = e0 ()
fun e4 .<>. ():<!ref> int = e0 ()
fun e5 .<>. ():<!wrt> int = e0 ()
fun e6 (): int = e0 ()
fun e7 .<>. ():<!all> int = e0 ()
fun e8 .<>. ():<!exn,!ntm> int = e0 ()
fun e9 .<>. ():<> int = $effmask_exn (e0 ())
fun e10 .<>. ():<> int = $effmask_all (e0 ())
fun e11 .<>. ():<> int = $effmask_ref (e0 ())

fun n0 .<>. ():<!ntm> int = n0 ()
fun n1 .<>. ():<> int = n0 ()
fun n2 .<>. ():<!ntm> int = n0 ()
fun n3 .<>. ():<!exn> int = n0 ()
fun n4 .<>. ():<> int = $effmask_ntm (n0 ())

fun r0 .<>. (x: ref(int)):<!ref> int = !x
fun r1 .<>. (x: ref(int)):<> int = !x
fun r2 .<>. (x: ref(int)):<> void = !x := 1
fun r3 .<>. (x: ref(int)):<!ref> void = !x := 1
fun r4 .<>. (x: ref(int)):<!wrt> void = !x := 1
fun r5 .<>. (x: ref(int)):<!ref,!wrt> void = !x := 1
fun r6 .<>. (x: ref(int)):<> int = $effmask_ref (!x)
fun r7 .<>. (x: ref(int)):<> void = $effmask_wrt (!x := 1)

fun m0 {fe:eff} .<>. (f: () -<fe> int):<fe> int = $effmask_ref (f ())
fun m1 {fe:eff} .<>. (f: () -<fe> int):<!ref> int = $effmask_wrt (f ())
fun m2 {fe:eff} .<>. (f: () -<fe> int):<> int = $effmask_exn ($effmask_ntm (f ()))
fun m3 {fe:eff} .<>. (f: () -<fe> int):<> int = $effmask_exn ($effmask_ntm ($effmask_ref ($effmask_wrt (f ()))))
fun m4 {fe:eff} .<>. (f: () -<fe> int):<!exn,fe> int = let val x = f () in x + e0 () end
fun m5 {fe:eff} .<>. (f: () -<fe> int):<!exn> int = let val x = f () in x + e0 () end

fun c0 .<>. (x: int):<> int = case+ x of | 0 => 1 | 1 => 2
fun c1 .<>. (x: int):<!exn> int = case+ x of | 0 => 1 | 1 => 2
fun c2 .<>. (x: int):<> int = case- x of | 0 => 1 | 1 => 2
fun c3 .<>. (x: int):<> int = case x of | 0 => 1 | 1 => 2
fun c4 .<>. (x: int):<!exn> int = case x of | 0 => 1 | 1 => 2
fun c5 .<>. (x: int):<> int = $effmask_exn (case+ x of | 0 => 1 | 1 => 2)
fun c6 .<>. (x: int):<> int = let val+ 0 = x in 1 end
fun c7 .<>. (x: int):<!exn> int = let val+ 0 = x in 1 end

val g0 = lam (f: () -<> void): void => f ()
val g1 = lam {fe:eff} (f: () -<fe> void): void => f ()
val g2 = lam (f: () -<fun,!exn> void): void => f ()
val g3 = lam (f: () -<fun,!exn> void): void => f ()
val g4 = lam (f: (() -<fun,!ref,!exn> void)): void => f ()
val g5 = lam (f: () -<fun,!all> void): void => f ()
val g6 = lam (f: () -<fun,!all> void): void => f ()
