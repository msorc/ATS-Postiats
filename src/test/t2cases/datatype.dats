datatype cc = CRed | CGreen | CBlue
datatype dd (a:t@ype) = DNil | DCons of (a, dd a)
datavtype ee (a:vt@ype) = ENil | ECons of (a, ee a)
datatype tr (n:int) = TLeaf (0) | {n1,n2:nat} TNode (n1+n2+1) of (tr n1, tr n2)
dataprop pp (int) = PP0 (0) | {n:nat} PP1 (n+1) of pp n
dataview vv (addr) = VV0 (null) | {l:addr} VV1 (l) of (int @ l)
dataviewtype ww = WW0 | WW1 of (int, ww)
dataprop FACT (int, int) = FACTzero (0, 1) | {n:nat}{r,r1:int} FACTsucc (n+1, r1) of (FACT (n, r), MUL (n+1, r, r1))
datatype ev (n:int) = EV0 (0) | {n:nat} EV1 (n+2) of ev n
and od (n:int) = OD1 (1) | {n:nat} OD2 (n+2) of od n
datavtype lst1 (a:vt@ype, int) =
  | lst1_nil (a, 0) of ()
  | {n:nat} lst1_cons (a, n+1) of (a, lst1 (a, n))
exception MyExn
exception MyExn2 of (int, string)
exception {a:type} BadExn of a
datatype bad1 (a:t@ype) = B1 of a
datatype bad2 = B2 of (int, nosuch)
datatype bad3 (n:int) = B3 (true)
datatype bad4 (n:int) = B4 (1, 2)
datatype bad5 = B5 (0)
datatype bad6 (n:int) = B6
datatype bad7 = B7 of (int) | B7 of (bool)
dataprop bad8 = B8 of (int)
datatype bad9 (n:nosuch) = B9
fun f (x: cc): int = case+ x of CRed () => 1 | CGreen () => 2 | CBlue () => 3
fun g {n:nat} (x: dd (int)): int = case+ x of DNil () => 0 | DCons (a, _) => a
