symintr ++ **
fun inc_int (x: int): int = x + 1
fun inc_bool (x: bool): bool = not x
fun inc_char (x: char): char = x
overload ++ with inc_int
overload ++ with inc_bool
overload ++ with inc_char of 10
overload ** with inc_int
overload ** with inc_bool of 100
val x1 = ++ (1)
val x2 = ++ (true)
val x3 = ++ ('a')
val x4 = 3 ** 4
symintr pp
overload pp with inc_int
symelim pp
symintr qq
overload qq with nosuch
overload nosuch2 with inc_int
overload + with inc_int
overload [] with inc_int
overload .foo with inc_int
overload ! with inc_int
overload := with inc_int
symintr ww
overload ww with ww
overload print with inc_bool
overload prerr with $NOSUCH.x
local
symintr ll
overload ll with inc_int
in
val x5 = ll (1)
end
val x6 = ll (1)
overload ++ with inc_int of 5
overload ++ with inc_bool of 4
val x7 = ++ (1) + ++ (2)
fun{a:t@ype} tmp (x: a): a = x
overload tt with tmp
symintr uu
overload uu with tmp
val x8 = uu<int> (1)
val x9 = uu (1)
