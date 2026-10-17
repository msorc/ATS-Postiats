abstype
form_type(l:addr) = ptr
typedef
form(l:addr) = form_type(l)

//
datavtype
form_view(l:addr) =
  | FORMint of (int)
  | FORMbool of (bool)
  | FORMintrep of (astring(l))
  | FORMs2var of (s2var(l))
  | FORMs2cst of (s2cst(l))
  | FORMs2exp of (s2exp(l))
  | FORMnot of (form(l))
  | FORMconj of (form(l), form(l))
  | FORMdisj of (form(l), form(l))
  | FORMimpl of (form(l), form(l))
//
fun
form_encode{l:addr}(ar: !arena(l), v: form_view(l)): form(l)
fun
form_view{l:addr}(ar: !arena(l), x: form(l)): form_view(l)
fun
form_view_free{l:addr}(v: form_view(l)): void
fun
form_tag{l:addr}(ar: !arena(l), x: form(l)): int
fun
form_FORMint{l:addr}(ar: !arena(l), a0: int): form(l)
fun
form_FORMbool{l:addr}(ar: !arena(l), a0: bool): form(l)
fun
form_FORMintrep{l:addr}(ar: !arena(l), a0: astring(l)): form(l)
fun
form_FORMs2var{l:addr}(ar: !arena(l), a0: s2var(l)): form(l)
fun
form_FORMs2cst{l:addr}(ar: !arena(l), a0: s2cst(l)): form(l)
fun
form_FORMs2exp{l:addr}(ar: !arena(l), a0: s2exp(l)): form(l)
fun
form_FORMnot{l:addr}(ar: !arena(l), a0: form(l)): form(l)
fun
form_FORMconj{l:addr}(ar: !arena(l), a0: form(l), a1: form(l)): form(l)
fun
form_FORMdisj{l:addr}(ar: !arena(l), a0: form(l), a1: form(l)): form(l)
fun
form_FORMimpl{l:addr}(ar: !arena(l), a0: form(l), a1: form(l)): form(l)
fun
form_is_FORMint{l:addr}(ar: !arena(l), x: form(l)): bool
fun
form_is_FORMbool{l:addr}(ar: !arena(l), x: form(l)): bool
fun
form_is_FORMintrep{l:addr}(ar: !arena(l), x: form(l)): bool
fun
form_is_FORMs2var{l:addr}(ar: !arena(l), x: form(l)): bool
fun
form_is_FORMs2cst{l:addr}(ar: !arena(l), x: form(l)): bool
fun
form_is_FORMs2exp{l:addr}(ar: !arena(l), x: form(l)): bool
fun
form_is_FORMnot{l:addr}(ar: !arena(l), x: form(l)): bool
fun
form_is_FORMconj{l:addr}(ar: !arena(l), x: form(l)): bool
fun
form_is_FORMdisj{l:addr}(ar: !arena(l), x: form(l)): bool
fun
form_is_FORMimpl{l:addr}(ar: !arena(l), x: form(l)): bool
//
