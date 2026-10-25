(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** a division by zero in a #define expression is an error of the program
** (patsopt used to die of SIGFPE); the integer arithmetic of #define wraps
** around: (BIG + 1) is ~BIG - 1 and ((~BIG - 1) / ~1) is ~BIG - 1 as well
*)
#define BIG 2147483647
#define WRAP ((BIG + 1) + ((~BIG - 1) / ~1))
#define ZERO (WRAP + WRAP)
#print (1 / ZERO)
implement main0 () = ()
