%{^
#include "lpdrv.h"
%}
// the C functions of lpdrv.c; the file that includes this one defines
// LPCNAME(x) (ATS1: "x", ATS2: "mac#x") as a string macro
extern fun lpdrv_open (path: string): void = "mac#lpdrv_open"
extern fun lpdrv_next (): int = "mac#lpdrv_next"
extern fun lpdrv_id (): string = "mac#lpdrv_id"
extern fun lpdrv_label (): string = "mac#lpdrv_label"
extern fun lpdrv_N (): int = "mac#lpdrv_N"
extern fun lpdrv_nhint (): int = "mac#lpdrv_nhint"
extern fun lpdrv_hint (j: int): int = "mac#lpdrv_hint"
extern fun lpdrv_ntop (): int = "mac#lpdrv_ntop"
extern fun lpdrv_top (j: int): int = "mac#lpdrv_top"
extern fun lpdrv_nvec (): int = "mac#lpdrv_nvec"
extern fun lpdrv_vec (j: int): int = "mac#lpdrv_vec"
extern fun lpdrv_ntype (k: int): int = "mac#lpdrv_ntype"
extern fun lpdrv_nknd (k: int): int = "mac#lpdrv_nknd"
extern fun lpdrv_nch (k: int): int = "mac#lpdrv_nch"
extern fun lpdrv_ch (k: int, j: int): int = "mac#lpdrv_ch"
extern fun lpdrv_coef (k: int, i: int): string = "mac#lpdrv_coef"
extern fun lpdrv_arg (j: int): string = "mac#lpdrv_arg"
extern fun lpdrv_isneg (s: string): int = "mac#lpdrv_isneg"
extern fun lpdrv_abs (s: string): string = "mac#lpdrv_abs"
