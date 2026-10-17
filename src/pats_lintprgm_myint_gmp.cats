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
#ifndef PATS_LINTPRGM_MYINT_GMP_CATS
#define PATS_LINTPRGM_MYINT_GMP_CATS

/*
** HX-2026-10: a [myint(gmpknd)] is a pointer to a malloc-ed [mpz_t] (it is
** freed by [myint_free]); this is what pats_lintprgm_myint_gmp.dats of ATS1
** did through libc/SATS/gmp.sats. All the functions take and return [mpz_ptr].
*/

#include <stdio.h>
#include <stdlib.h>
#include <gmp.h>

#define PATSOPT_LPZ(x) ((mpz_ptr)(x))

static inline
atstype_ptr
patsopt_lpz_new_si (atstype_int i) {
  mpz_ptr p = (mpz_ptr)malloc (sizeof(__mpz_struct)) ;
  mpz_init_set_si (p, i) ; return p ;
}
static inline
atstype_ptr
patsopt_lpz_new_copy (atstype_ptr q) {
  mpz_ptr p = (mpz_ptr)malloc (sizeof(__mpz_struct)) ;
  mpz_init_set (p, PATSOPT_LPZ(q)) ; return p ;
}
static inline
atstype_ptr
patsopt_lpz_new_zero () {
  mpz_ptr p = (mpz_ptr)malloc (sizeof(__mpz_struct)) ;
  mpz_init (p) ; return p ;
}
static inline
atstype_void
patsopt_lpz_free (atstype_ptr p) {
  mpz_clear (PATSOPT_LPZ(p)) ; free (p) ; return ;
}

static inline atstype_void
patsopt_lpz_neg (atstype_ptr p) { mpz_neg (PATSOPT_LPZ(p), PATSOPT_LPZ(p)) ; }
static inline atstype_void
patsopt_lpz_neg_to (atstype_ptr r, atstype_ptr p) { mpz_neg (PATSOPT_LPZ(r), PATSOPT_LPZ(p)) ; }

static inline atstype_void
patsopt_lpz_add_si (atstype_ptr p, atstype_int i) {
  if (i >= 0) mpz_add_ui (PATSOPT_LPZ(p), PATSOPT_LPZ(p), (unsigned long)i) ;
  else mpz_sub_ui (PATSOPT_LPZ(p), PATSOPT_LPZ(p), (unsigned long)(-(long)i)) ;
}
static inline atstype_void
patsopt_lpz_add (atstype_ptr p, atstype_ptr q) { mpz_add (PATSOPT_LPZ(p), PATSOPT_LPZ(p), PATSOPT_LPZ(q)) ; }
static inline atstype_void
patsopt_lpz_sub (atstype_ptr p, atstype_ptr q) { mpz_sub (PATSOPT_LPZ(p), PATSOPT_LPZ(p), PATSOPT_LPZ(q)) ; }

// r := p * q (r may be p or q)
static inline atstype_void
patsopt_lpz_mul_to (atstype_ptr r, atstype_ptr p, atstype_ptr q) { mpz_mul (PATSOPT_LPZ(r), PATSOPT_LPZ(p), PATSOPT_LPZ(q)) ; }
// r := r + p * q
static inline atstype_void
patsopt_lpz_addmul (atstype_ptr r, atstype_ptr p, atstype_ptr q) { mpz_addmul (PATSOPT_LPZ(r), PATSOPT_LPZ(p), PATSOPT_LPZ(q)) ; }

static inline atstype_void
patsopt_lpz_tdiv_q (atstype_ptr p, atstype_ptr q) { mpz_tdiv_q (PATSOPT_LPZ(p), PATSOPT_LPZ(p), PATSOPT_LPZ(q)) ; }
static inline atstype_void
patsopt_lpz_divexact (atstype_ptr p, atstype_ptr q) { mpz_divexact (PATSOPT_LPZ(p), PATSOPT_LPZ(p), PATSOPT_LPZ(q)) ; }
static inline atstype_void
patsopt_lpz_mod_to (atstype_ptr r, atstype_ptr p, atstype_ptr q) { mpz_mod (PATSOPT_LPZ(r), PATSOPT_LPZ(p), PATSOPT_LPZ(q)) ; }
static inline atstype_void
patsopt_lpz_gcd (atstype_ptr p, atstype_ptr q) { mpz_gcd (PATSOPT_LPZ(p), PATSOPT_LPZ(p), PATSOPT_LPZ(q)) ; }

static inline atstype_int
patsopt_lpz_cmp_si (atstype_ptr p, atstype_int i) { return mpz_cmp_si (PATSOPT_LPZ(p), i) ; }
static inline atstype_int
patsopt_lpz_cmp (atstype_ptr p, atstype_ptr q) { return mpz_cmp (PATSOPT_LPZ(p), PATSOPT_LPZ(q)) ; }

static inline atstype_void
patsopt_lpz_fprint (atstype_ptr out, atstype_ptr p) { mpz_out_str ((FILE*)out, 10, PATSOPT_LPZ(p)) ; }

#endif // end of [PATS_LINTPRGM_MYINT_GMP_CATS]

/* ****** ****** */

/* end of [pats_lintprgm_myint_gmp.cats] */
