(* #symintr, overload in dynamic code *)
symintr foo bar
fun foo_int (x: int): int = x
fun foo_bool (x: bool): int = 1
overload foo with foo_int
overload foo with foo_bool of 10
overload bar with foo_int of 1
overload + with foo_int
overload [] with foo_bool
overload ~ with foo_int
overload fprint with foo_int of 1
overload .x with foo_int
overload :=+ with foo_int
overload prerr with foo_bool
overload print with foo_bool of 2
symelim foo
fun baz (x: int) = foo x + bar x
local
  fun lfoo (x: int) = x
  overload foo with lfoo
in
  val a = foo 1
end
