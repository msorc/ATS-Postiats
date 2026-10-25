/***********************************************************************/
/*                                                                     */
/*                         Applied Type System                         */
/*                                                                     */
/***********************************************************************/

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
// Author: Hongwei Xi (hwxi AT cs DOT bu DOT edu)
// Time: March, 2012
//
/* ****** ****** */

#ifndef PATS_LINTPRGM_MYINT_CATS
#define PATS_LINTPRGM_MYINT_CATS

typedef atstype_int intknd ; // -> int
typedef atstype_ptr gmpknd ; // -> a malloc-ed mpz_t (pats_lintprgm_myint_gmp.cats)

/*
** HX-2026-10: the gcd of the prelude of ATS1 (the sign of the arguments is ignored)
*/
static inline
atstype_int
patsopt_lintprgm_gcd_int_int (atstype_int m0, atstype_int n0) {
  int m, n, t ;
  if (m0 >= 0) m = m0; else m = -m0 ;
  if (n0 >= 0) n = n0; else n = -n0 ;
  while (m) { t = n % m ; n = m ; m = t ; }
  return n ;
}

#endif // end of [PATS_LINTPRGM_MYINT_CATS]

/* ****** ****** */

/* end of [pats_lintprgm_myint.cats] */
