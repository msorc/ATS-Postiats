#
# HX-2026-10: no GC
# The arena encoding (in the global arena) of JSON values:
#   python3 $PATSHOME/utils/arenagen/arenagen.py sats --global \
#     SATS/jsonats.spec > SATS/jsonats_gen.hats
#   python3 $PATSHOME/utils/arenagen/arenagen.py dats --global \
#     SATS/jsonats.spec > DATS/jsonats_gen.hats
#
type jsonval
  JSONnul ()
  JSONbool (bool)
  JSONint (int)
  JSONfloat (double)
  JSONstring (string)
  JSONarray (glist(jsonval))
  JSONobject (glist(@(string, jsonval)))
