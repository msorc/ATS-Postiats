# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
# arenagen specification for pats_jsonize.{sats,dats}: the JSON value representation (--compact)
# python3 ../utils/arenagen/arenagen.py --global sats pats_jsonize.spec > pats_jsonize_gen.hats
# python3 ../utils/arenagen/arenagen.py --global --compact dats pats_jsonize.spec > pats_jsonize_gen_dats.hats
#
# [labjsonval] is the ATS1 pair @(string, jsonval) made a record (a glist holds one word per element).
# [JSONfloat] has a double: --compact stores a double field by value.
typedef jsonvalist = glist(jsonval)
typedef labjsonvalist = glist(labjsonval)
typedef jsonvalopt = gopt(jsonval)
type jsonval
  JSONnul ()
  JSONint (int)
  JSONintinf (intinf)
  JSONbool (bool)
  JSONfloat (double)
  JSONstring (string)
  JSONlocation (location)
  JSONfilename (filename)
  JSONlist (jsonvalist)
  JSONlablist (labjsonvalist)
  JSONoption (jsonvalopt)
record labjsonval (labjsonval_lab: string, labjsonval_val: jsonval)
