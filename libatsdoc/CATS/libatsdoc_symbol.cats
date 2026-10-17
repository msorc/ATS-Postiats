/***********************************************************************/
/*                                                                     */
/*                         Applied Type System                         */
/*                                                                     */
/***********************************************************************/

/*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-20?? Hongwei Xi, ATS Trustworthy Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of the GNU LESSER GENERAL PUBLIC LICENSE as published by the
** Free Software Foundation; either version 2.1, or (at your option)  any
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

/*
** HX-2026-10: no GC
** The table of the symbols of libatsdoc (hash table with chaining that
** grows; entries are never freed). The value of a symbol is what
** [theAtextMap] holds (NULL: none).
*/

#ifndef LIBATSDOC_SYMBOL_CATS
#define LIBATSDOC_SYMBOL_CATS

#include <stdlib.h>
#include <string.h>

typedef struct libatsdoc_symbol_struct {
  char *name ;
  unsigned int stamp ;
  void *value ; // the atext of the symbol (NULL if none)
  struct libatsdoc_symbol_struct *next ;
} libatsdoc_symbol_struct ;

extern atstype_ptr libatsdoc_symbol_empty ;

atstype_ptr libatsdoc_symbol_make_string (atstype_ptr name) ;

#define libatsdoc_symbol_get_name(x) (((libatsdoc_symbol_struct*)(x))->name)
#define libatsdoc_symbol_get_stamp(x) (((libatsdoc_symbol_struct*)(x))->stamp)

#define libatsdoc_symbol_get_value(x) (((libatsdoc_symbol_struct*)(x))->value)
#define libatsdoc_symbol_set_value(x, v) (((libatsdoc_symbol_struct*)(x))->value = (v))

#endif // end of [LIBATSDOC_SYMBOL_CATS]

/* end of [libatsdoc_symbol.cats] */
