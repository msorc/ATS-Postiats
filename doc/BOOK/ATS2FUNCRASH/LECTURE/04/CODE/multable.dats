(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)

extern fun html(): void
extern fun head(): void
extern fun body(): void
extern fun multable(): void

(* ****** ****** *)

implement
html() =
{
//
val () = println! ("<html>")
val () = head()
val () = body()
val () = println! ("</html>")
//
} (* end of [html] *)

(* ****** ****** *)

implement
head() =
{
val () =
println! ("<head>")
//
val () =
println!
("<meta charset=\"utf-8\">")
//
val () =
println! ("</head>")
//
} (* end of [head] *)

(* ****** ****** *)

implement
body() =
{
val () =
println! ("<body>")
//
val () =
println!
("\
<center>
<h1>Multiplication Table</h1>
</center>
")
val () = multable()
//
val () =
println! ("</body>")
//
} (* end of [body] *)

(* ****** ****** *)

#include "./intfun.hats"

(* ****** ****** *)

fun
auxrow(n: int): void = let
//
var fwork =
lam@(i: int): void =>
(
  print("<td>"); print!(i+1, " x ", n, " = ", (i+1)*n); print("</td>\n")
)
//
in
  (n).foreach(fwork)
end // end of [auxrow]

(* ****** ****** *)

fun
auxrows
(n: int): void = let
//
var fwork =
lam@(i: int): void =>
{
//
val n = i + 1
//
val () =
if
(n%2 = 0) then
print("<tr style=\"background:#c0c0c0\">\n");
val () =
if
(n%2 > 0) then
print("<tr style=\"background:#ffffff\">\n");
//
val () = auxrow(n)
val () = print("</tr>\n")
//
}
//
in
  (n).foreach(fwork)
end // end of [auxrows]

(* ****** ****** *)

implement
multable() =
{
val () =
println! ("<center>")
//
val () =
println! ("<table>")
val () = auxrows( 9 )
val () =
println! ("</table>")
//
val () =
println! ("</center>")
}

(* ****** ****** *)
//
implement
main0() = () where
{
//
val () =
println!
("<!DOCTYPE html>")
//
val () = html()
//
} (* end of [main0] *)
//
(* ****** ****** *)

(* end of [multable.dats] *)
