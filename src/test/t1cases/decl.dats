(* declarations *)
#pragma ("pragma1")
#pragma (1 + 2)
#codegen2 ("cg2")
#codegen2 ("cg2", 1)
%{^
#include <stdio.h>
%}
%{$
static int xxx = 1 ;
%}
%{
int yyy ;
%}
%{#
#define ZZZ 1
%}
extvar "myvar" = 1
exception E1 of ()
exception E2 of (int)
exception E3 of (int, bool)
macdef m1 (x) = x
macdef m2 = lam (x) => x
macrodef m3 (x) = x
macrodef rec m4 (x) = x
macdef m5 (x, y) = ,(x) + ,(y)
macdef m6 = `(1 + ,(m1 2))
val v1 = 1
val v2 = 1 and v3 = 2
val v4 : int = 1
val+ v5 = 1
val- v6 = 1
val (a, b) = (1, 2)
val ~(c) = 1
val rec v7 : int -> int = lam (x) => x
prval pv = ()
var x1: int = 1
var x2 = 2
var x3 : int
var x4: int with pf = 1
var !x5 = 3
var arr = @[int][3](0)
var arr2: @[int][3] = @[int][3](0)
fun fa (x: int) = x
fun{a:t@ype} fc (x: a) = x
implement fc<int> (x) = x
implement(a) fd<a> (x) = x
extern val ev : int
extern prval epv : unit_p
typedef t1 = int
vtypedef t2 = int
stadef st1 = int
sortdef so1 = int
abstype at1
abstype at2 = int
datatype dt1 = A1 | B1
dataprop dp1 = DP1
datavtype dvt1 = DV1
dataview dv1 = DVV1
