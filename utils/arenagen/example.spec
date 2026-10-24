# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
type exp
  EXPint (int)
  EXPvar (astring(l))
  EXPadd (exp(l), exp(l))
  EXPlet (astring(l), exp(l), exp(l))
