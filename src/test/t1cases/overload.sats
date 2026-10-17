(* #symintr, overload *)
symintr foo bar
fun foo_int (x: int): int
fun foo_bool (x: bool): int
overload foo with foo_int
overload foo with foo_bool of 10
overload bar with foo_int of 1
overload + with foo_int
overload [] with foo_bool
overload ~ with foo_int
overload fprint with foo_int of 1
symelim foo
fun bar_int (x: int): int
overload bar with bar_int of 2
overload bar with foo_int of 1
overload foo with bar_int of 5
