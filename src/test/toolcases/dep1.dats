(* depgen cases: every place where a staload or an include can occur *)
#include "./inc_a.hats"
#include "inc_b.hats"
#include "./sub/../inc_c.hats"
#include "./missing.hats"
staload "./mod_a.sats"
staload X = "./mod_b.sats"
staload _ = "./mod_a.dats"
staload "sub/s.sats"
staload "./sub/s.sats"
staload "prelude/SATS/integer.sats"
staload "{$PATSHOME}/prelude/SATS/list.sats"
staload "libats/SATS/arena.sats"
staload "/nonexistent/abs.sats"
staload "./nonexistent.sats"
staload "$PATSHOMELOCS/x.sats"
staload "share/atspre_staload.hats"
#include "share/atspre_staload.hats"
dynload "./mod_a.dats"
//
local
staload "./mod_a.sats"
#include "./inc_a.hats"
in
staload "./mod_b.sats"
local
#include "inc_b.hats"
in
#include "inc_c.hats"
end
end
//
#if defined(X) #then
staload "./mod_a.sats"
#else
staload "./mod_b.sats"
#endif
#ifdef Y
#include "./inc_a.hats"
#elif defined(Z)
#include "./inc_b.hats"
#else
#include "./inc_c.hats"
#endif
#ifndef W
staload "./mod_c.sats"
#endif
//
val x1 = let staload "./mod_a.sats" in 1 end
val x2 = 1 where { staload "./mod_b.sats" #include "./inc_c.hats" }
val x3 = if true then let staload "./mod_a.sats" in 1 end else let #include "./inc_a.hats" in 2 end
val x4 = if true then 1 else let staload "./mod_b.sats" in 2 end
val x5 = (let staload "./mod_c.sats" in 1 end, 2)
val x6 = @(1, let #include "./inc_b.hats" in 2 end)
val x7 = '{a=let staload "./mod_a.sats" in 1 end, b=2}
val x8 = @[int][3](1, let staload "./mod_b.sats" in 2 end, 3)
val x9 = (1; let staload "./mod_a.sats" in 2 end)
val x10 = f (let staload "./mod_a.sats" in 1 end) (let staload "./mod_b.sats" in 2 end)
val x11 = sif true then let staload "./mod_a.sats" in 1 end else let staload "./mod_b.sats" in 2 end
val x12 = (foldat (let staload "./mod_c.sats" in x end))
val x13 = (freeat (let staload "./mod_c.sats" in x end))
val x14 = case+ 1 of _ => let staload "./mod_a.sats" in 1 end
val x15 = lam (x: int): int => let staload "./mod_b.sats" in x end
val x16 = let val y = let staload "./mod_a.sats" in 1 end in y end
val x17 = (let staload "./mod_a.sats" in 1 end) : int
fun f1 (x: int): int = let staload "./mod_c.sats" in x end
implement f2 (x) = x where { #include "./inc_a.hats" }
