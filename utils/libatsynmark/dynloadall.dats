(*
**
** Some utility functions
** for manipulating the syntax of ATS2
**
** Contributed by Hongwei Xi (gmhwxiATgmailDOTcom)
**
** Start Time: June, 2012
**
*)
(* ****** ****** *)
//
// HX-2016-02-20:
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file)
//
// The C function [libatsynmark_dynloadall] (declared in
// SATS/libatsynmark.sats) initializes libatsopt (the lexer, the parser, ...:
// [libatsopt_dynloadall] of libatsopt.a) and the environment of the constants
// of level 1. The modules of libatsynmark have nothing to initialize
// (ATS_DYNLOADFLAG 0 in each of them). Call it before using anything else of
// libatsynmark and libatsopt (later calls do nothing).
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

#define ATS_DYNLOADFLAG 0 // manual dynloading

(* ****** ****** *)

staload "./SATS/libatsynmark.sats"

(* ****** ****** *)
staload
TRENV1 = "src/pats_trans1_env.sats"

(* ****** ****** *)
//
extern
fun
libatsopt_dynloadall(): void = "ext#libatsopt_dynloadall"
//
// HX: returns 0 only for the first call
//
extern
fun
libatsynmark_dynloadall_flag(): int = "ext#libatsynmark_dynloadall_flag"
//
(* ****** ****** *)

implement
libatsynmark_dynloadall
  ((*void*)) = let
  val flag = libatsynmark_dynloadall_flag ()
in
//
if flag = 0 then let
  val () = libatsopt_dynloadall ()
in
  // the environment of the (level-1) constants, for [-DATS XYZ=def]
  $TRENV1.the_trans1_env_initialize ((*void*))
end else () // end of [if]
//
end // end of [libatsynmark_dynloadall]

(* ****** ****** *)

%{$
int
libatsynmark_dynloadall_flag (void)
{
  static int theFlag = 0 ;
  int res = theFlag ; theFlag = 1 ; return res ;
}
%}

(* ****** ****** *)

(* end of [dynloadall.dats] *)
