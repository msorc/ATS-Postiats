(* an evaluated float constant cannot be a pattern: the pattern is erroneous and the exhaustiveness check ends the translation *)
#include "share/atspre_staload.hats"
#define F2 %(1.0+2.0)
fun d2 (x: double): int = case+ x of | F2 => 1 | _ => 0
