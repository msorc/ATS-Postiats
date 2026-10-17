local
val x1 = 1
fun f1 (x: int): int = x + x1
in
val x2 = f1 (2)
fun f2 (x: int): int = f1 (x)
end
val x3 = f2 (x1)
local
datatype dd = DA | DB
in
fun f3 (x: dd): int = case+ x of DA () => 1 | DB () => 2
end
local
in
val x4 = 1
end
local
local
val y1 = 1
in
val y2 = y1
end
in
val y3 = y2 + y1
end
val x5 = let
  local val z = 1 in val w = z end
in w end
local
abstype la
in
assume la = int
end
local
stadef lz = 3
sortdef ls = int
in
typedef lt = int (lz)
end
val x6 = lz
