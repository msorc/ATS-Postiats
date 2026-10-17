# arenagen specification for pats_constraint3.sats: the static expressions of the constraint solver (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_constraint3.spec > pats_constraint3_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_constraint3.spec > pats_constraint3_gen_dats.hats
#
# Same conventions as pats_staexp2.spec (PORTING.md, "Constraint solving (constraint3)"): [s3exp] is the ATS1 datatype of the same name.
typedef s3explst = glist(s3exp)
vtypedef s3explst_vt = List0_vt(s3exp)
type s3exp
  S3Evar (s2var)
  S3Ecst (s2cst)
  S3Enull ()
  S3Eunit ()
  S3Ebool (bool)
  S3Ebvar (s2var)
  S3Ebneg (s3exp)
  S3Ebadd (s3exp, s3exp)
  S3Ebmul (s3exp, s3exp)
  S3Ebeq (s3exp, s3exp)
  S3Ebneq (s3exp, s3exp)
  S3Ebineq (int, s3exp)
  S3Ebdom (s2var)
  S3Eiatm (s2varmset)
  S3Eicff (intinf, s3exp)
  S3Eisum (s3explst)
  S3Eimul (s3exp, s3exp)
  S3Esizeof (s2zexp)
  S3Eapp (s3exp, s3explst)
  S3Eerr (s2rt)
