# The error-message suite (see README). It does not inherit PATSOPT_LEGACY_ERRORS from ../Makefile:
# run it as `make -C errcases` (the runner also unsets the variable).
all:: test
test::
	sh run.sh
update::
	sh run.sh update
clean::
	$(RM) actual.*.tmp
