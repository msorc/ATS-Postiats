(* local ... in ... end *)
local
  #define N 1
  infixl 10 +++
  fun f (x: int) = x
  local
    #define M 2
    fun g (x: int) = x + N
  in
    fun h (x: int) = g x +++ f x
  end
in
  fun k (x: int) = h x + N
end
val a = k 1 +++ 2
val b = N
val c = let
  #define Q 3
  infixr 20 ##
  val x = 1 ## Q
in x end
val d = Q
val e = (g 1) where { #define W 4 fun g (x: int) = x + W }
val f = W
