(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(* ****** ****** *)
//
// HX-2026-10: no GC
//
// What [pats_syntax] needs of the parser ([pats_parsing], not ported yet):
// the parsing errors it reports. They are implemented by the parser (the
// tests give stubs).
//
(* ****** ****** *)

staload "./pats_basics.sats"
staload
LOC = "./pats_location.sats"
typedef location = $LOC.location

(* ****** ****** *)
//
fun parerr_p0at_as(loc: location): void // [PE_p0at_as]
fun parerr_add_ifunclosed(loc: location, name: string): void
//
(* ****** ****** *)

(* end of [pats_syntax_boundary.sats] *)
