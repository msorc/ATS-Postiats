%{^
#include "c3drv.h"
%}
// the C functions of c3drv.c
extern fun c3_open (path: string): void = "mac#c3_open"
extern fun c3_line (): int = "mac#c3_line"
extern fun c3_more (): int = "mac#c3_more"
extern fun c3_int (): int = "mac#c3_int"
extern fun c3_str (): string = "mac#c3_str"
extern fun c3_put (t: int, i: int, p: ptr): void = "mac#c3_put"
extern fun c3_get (t: int, i: int): ptr = "mac#c3_get"
extern fun c3_put_env (p: ptr): void = "mac#c3_put_env"
extern fun c3_get_env (): ptr = "mac#c3_get_env"
extern fun c3_env_isnull (): int = "mac#c3_env_isnull"
extern fun c3_lineno (): int = "mac#c3_lineno"
