(* up typing: external calls with linear arguments, $vcopyenv, scase/arrpsz without expected type, $raise in a pure function, $literal, lam@ in bodies *)
#include "share/atspre_staload.hats"
exception MyExn of int
datavtype dvt = DVT of int
fun dfree (x: dvt): void = let val+ ~DVT _ = x in end

fun xf1 (x: dvt): void = $extfcall (void, "ext_f", x)
fun xf2 (x: int, y: dvt): void = (dfree y; $extfcall (void, "ext_f", x))
fun xf3 (x: int): int = $extfcall (int, "ext_g", x, x)
fun xf4 (x: !dvt): void = $extfcall (void, "ext_f", x)
fun xm1 (x: dvt): void = $extmcall (void, x, "m", x)
fun xm2 (x: int): void = $extmcall (void, x, "m", 1)
fun xm3 (x: !dvt): void = $extmcall (void, x, "m")
fun xm4 (x: dvt, y: dvt): void = $extmcall (void, x, "m", y)

fun vc1 (x: int): int = $vcopyenv_v (x + 1)
fun vc2 (x: int): int = $vcopyenv_v (x)
fun vc3 (x: int): int = $vcopyenv_vt (x)
fun vc4 {l:addr} (pf: !int @ l | p: ptr l): int = $vcopyenv_vt (p)
fun vc5 (x: dvt): void = let val () = $vcopyenv_v (dfree x) in end


fun ap1 (): int = let val a = $arrpsz (1, 2, 3) in 0 end
fun ap2 (): int = let val a = $arrpsz {int} (1, 2, 3) in 0 end
fun ap3 (): int = let val a = $arrpsz {int} () in 0 end

fun rz1 .<>. ():<> int = $raise MyExn (1)
fun rz2 .<>. ():<> int = $raise (MyExn (2))
fun rz3 .<>. ():<!exn> int = $raise MyExn (1)

val l4 = $literal (1)
val l5 = $literal (true)

fun la1 (x: int): int -<cloptr1> int = lam (y) => x + y
fun la2 (x: int): int = let val f = lam@ (y: int): int => x + y in f (1) end
fun la3 (x: int): (int) -<cloptr1> int = lam (y: int) => lam@ (z: int): int => x + y + z
val la4 = lam (x: int) => lam@ (y: int): int => x + y
val la5 = lam (x: int) => (lam {n:int} (y: int n): int n => y)
val la6 = lam (x: int) => lam@ {n:int} (y: int n): int n => y
val la7 = lam@ (x: int) => lam@ (y: int): int => x + y

(* untyped declarations whose result is an integer or a float literal: the types are synthesized (suffixes that are valid and not supported) *)
fun sy1 (x: int) = 1uu
fun sy3 (x: int) = 0x1fuu
fun sy4 (x: int) = 1u
fun sy5 (x: int) = 1l
fun sy6 (x: int) = 1ul
fun sy7 (x: int) = 1ll
fun sy8 (x: int) = 1ull
fun sy9 (x: int) = 1lu
fun sy10 (x: int) = 1llu
fun sy11 (x: int) = 1.5
fun sy12 (x: int) = 1.5f
fun sy13 (x: int) = 1.5l
fun sy15 (x: int) = 1.5ff
fun sy16 (x: int) = (1, 2)
fun sy17 (x: int) = '(1, 2)
fun sy18 (x: int) = @{a=1, b="c"}
fun sy20 (x: int) = $UNSAFE.cast{int}(x)
fun sy21 (x: int) = $mylocation
fun sy22 (x: int) = $myfilename
fun sy23 (x: int) = $myfunction
fun sy24 (x: int) = ()
fun sy25 (x: int) = (x; 1u)
fun sy26 (x: int) = 'c'
fun sy27 (x: int) = true
fun sy28 (x: int) = "abc"
fun sy29 (x: int) = $lst_t(1, 2)
fun sy30 (x: int) = '[1, 2]
fun sy31 (x: int) = $lst_t{int}()
fun sy32 (x: int) = $lst_vt(1, 2)
fun sy33 (x: int) = $lst_vt{int}()
fun sy34 (x: int) = $list_vt(1, 2)
