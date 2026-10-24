(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(*
** The atext macros of the tutorials written in DocBook (the libcairo
** tutorial, npm-utils/contrib/atscntrb/atscntrb-hx-libcairo/TUTORIAL).
**
** The ATS1 file of this name was in the ATS1 install only (never in this
** repository); this one is rebuilt from the macros that the six chapters use
** (para, atscode, dyncode, stacode, code, emph, command, filename, title,
** comment, timestamp): all are those of docbookatxt.hats, except dyncode and
** stacode, which tag code in the same way as the one of
** doc/BOOK/ATS2TUTORIAL/MYTEXT/ats2tutorial.dats.
*)

(* ****** ****** *)

//
// the chapters have their own dynload "libatsdoc/dynloadall.dats", and a
// module must not have two of them
//
#define ATSDOC_NO_DYNLOAD 1
//
#include "utils/atsdoc/HATS/docbookatxt.hats"

(* ****** ****** *)

macdef dyncode (x) = xmltagging ("code", ,(x))
macdef stacode (x) = xmltagging ("code", ,(x))

(* ****** ****** *)

(* end of [tutorialatxt.dats] *)
