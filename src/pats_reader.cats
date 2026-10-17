/* ******************************************************************* */
/*                                                                     */
/*                         Applied Type System                         */
/*                                                                     */
/* ******************************************************************* */

/*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
** later version.
** 
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
** 
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*/

/* ****** ****** */
//
// Author: Hongwei Xi (gmhwxi@gmail.com)
// Start Time: March, 2011
//
/* ****** ****** */

#ifndef POSTIATS_SRC_PATS_READER_CATS
#define POSTIATS_SRC_PATS_READER_CATS

/* ****** ****** */

/*
** HX-2026-10: no GC
** the reader is a tagged struct (no closures stored in it):
** kind 0: rptr is a FILE* (closed by uninitize)
** kind 1: rptr is a linear closure () -<lincloptr1> int
** kind 2: rptr is a string, ridx the current index
** kind 3: rptr is a list_vt(char) (the remaining chars)
*/
typedef struct {
//
  atstype_int rkind ;
  atstype_ptr rptr ;
  atstype_size ridx ;
//
} pats_reader_struct ;

/* ****** ****** */

#endif // end of [POSTIATS_SRC_PATS_READER_CATS]

/* ****** ****** */

/* end of [pats_reader.cats] */
