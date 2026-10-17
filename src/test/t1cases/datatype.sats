(* data types *)
datatype list0 (a:t@ype) = nil0 of () | cons0 of (a, list0 a)
datatype tree (a:t@ype+, int) =
  | Leaf (a, 0)
  | {n1,n2:nat} Node (a, n1+n2+1) of (tree (a, n1), a, tree (a, n2))
and forest (a:t@ype) = Forest of List0 (tree (a, 0))
dataprop fact (int, int) =
  | FACTzero (0, 1)
  | {n:nat}{r:int} FACTsucc (n+1, (n+1)*r) of fact (n, r)
dataview dv (l:addr) = dvnil (null) | {l:agz} dvcons (l) of (int @ l)
datavtype dvt (a:vt@ype) = dvtnil of () | dvtcons of (a, dvt a)
dataviewtype dvt2 = dvt2a | dvt2b of (int)
datatype ex = ex1 | ex2 of int
datatype d3 (a:t@ype) = D3 of (int, a) | D4 of (@(int, a), @{x= int, y= a})
exception MyExn of ()
exception MyExn2 of (int, string)
datatype d4 = {a:int} D5 of (int a) | {a:int | a > 0} D6 of (int a, bool) | {a:int} D7 of (int a)
datatype d5 = D8 of (int, int) | D9 of @(int, int) | D10 of (int | int)
datatype d6 (n: int) = D11 (0) | D12 (1) of (d6 0, int, d6 2)
