(* fixity declarations (level-1 translation) *)
infixl 60 +++
infixr 70 ***
infix 50 ===
prefix 80 !!!
postfix 90 ???
infixl (+) +++-
infixr ( * ) ***+ ***-
infixl ( +++ ) pp
nonfix pp
typedef plus (a:t0p, b:t0p) = @(a, b)
stadef +++ = plus
stadef x1 = int +++ bool +++ char
stadef x2 = int *** bool *** char
stadef x3 = !!! int
stadef x4 = int ???
fun foo (x: int +++ int): int
fun bar (x: int, y: int): int
