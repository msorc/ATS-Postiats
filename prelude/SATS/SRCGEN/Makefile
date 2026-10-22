#
# This Makefile is automatically generated
# from executing the following command-line:
#
# make -f Makefile.gen
#

######

PATSHOMEQ="$(PATSHOME)"

######

PATSCC=$(PATSHOMEQ)/bin/patscc
ATSDOC=$(PATSHOMEQ)/bin/atsdoc

######
PATSCCFLAGS=-DATS_MEMALLOC_LIBC
#
######

all::

######

all:: integer.sats
integer.sats: integer_atxt.exe ; ./$< > $@
integer_atxt.exe: integer_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ integer_atxt.dats -latsdoc
integer_atxt.dats: integer.atxt
	$(ATSDOC) --outcode $@ -i integer.atxt > integer_atxt.txt
clean:: ; $(RMF) integer_atxt.exe
cleanall:: ; $(RMF) integer.sats

all:: pointer.sats
pointer.sats: pointer_atxt.exe ; ./$< > $@
pointer_atxt.exe: pointer_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ pointer_atxt.dats -latsdoc
pointer_atxt.dats: pointer.atxt
	$(ATSDOC) --outcode $@ -i pointer.atxt > pointer_atxt.txt
clean:: ; $(RMF) pointer_atxt.exe
cleanall:: ; $(RMF) pointer.sats


all:: arith_prf.sats
arith_prf.sats: arith_prf_atxt.exe ; ./$< > $@
arith_prf_atxt.exe: arith_prf_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ arith_prf_atxt.dats -latsdoc
arith_prf_atxt.dats: arith_prf.atxt
	$(ATSDOC) --outcode $@ -i arith_prf.atxt > arith_prf_atxt.txt
clean:: ; $(RMF) arith_prf_atxt.exe
cleanall:: ; $(RMF) arith_prf.sats

all:: integer_long.sats
integer_long.sats: integer_long_atxt.exe ; ./$< > $@
integer_long_atxt.exe: integer_long_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ integer_long_atxt.dats -latsdoc
integer_long_atxt.dats: integer_long.atxt
	$(ATSDOC) --outcode $@ -i integer_long.atxt > integer_long_atxt.txt
clean:: ; $(RMF) integer_long_atxt.exe
cleanall:: ; $(RMF) integer_long.sats

all:: integer_size.sats
integer_size.sats: integer_size_atxt.exe ; ./$< > $@
integer_size_atxt.exe: integer_size_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ integer_size_atxt.dats -latsdoc
integer_size_atxt.dats: integer_size.atxt
	$(ATSDOC) --outcode $@ -i integer_size.atxt > integer_size_atxt.txt
clean:: ; $(RMF) integer_size_atxt.exe
cleanall:: ; $(RMF) integer_size.sats

all:: integer_short.sats
integer_short.sats: integer_short_atxt.exe ; ./$< > $@
integer_short_atxt.exe: integer_short_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ integer_short_atxt.dats -latsdoc
integer_short_atxt.dats: integer_short.atxt
	$(ATSDOC) --outcode $@ -i integer_short.atxt > integer_short_atxt.txt
clean:: ; $(RMF) integer_short_atxt.exe
cleanall:: ; $(RMF) integer_short.sats


all:: bool.sats
bool.sats: bool_atxt.exe ; ./$< > $@
bool_atxt.exe: bool_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ bool_atxt.dats -latsdoc
bool_atxt.dats: bool.atxt
	$(ATSDOC) --outcode $@ -i bool.atxt > bool_atxt.txt
clean:: ; $(RMF) bool_atxt.exe
cleanall:: ; $(RMF) bool.sats

all:: char.sats
char.sats: char_atxt.exe ; ./$< > $@
char_atxt.exe: char_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ char_atxt.dats -latsdoc
char_atxt.dats: char.atxt
	$(ATSDOC) --outcode $@ -i char.atxt > char_atxt.txt
clean:: ; $(RMF) char_atxt.exe
cleanall:: ; $(RMF) char.sats

all:: float.sats
float.sats: float_atxt.exe ; ./$< > $@
float_atxt.exe: float_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ float_atxt.dats -latsdoc
float_atxt.dats: float.atxt
	$(ATSDOC) --outcode $@ -i float.atxt > float_atxt.txt
clean:: ; $(RMF) float_atxt.exe
cleanall:: ; $(RMF) float.sats

all:: string.sats
string.sats: string_atxt.exe ; ./$< > $@
string_atxt.exe: string_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ string_atxt.dats -latsdoc
string_atxt.dats: string.atxt
	$(ATSDOC) --outcode $@ -i string.atxt > string_atxt.txt
clean:: ; $(RMF) string_atxt.exe
cleanall:: ; $(RMF) string.sats

all:: strptr.sats
strptr.sats: strptr_atxt.exe ; ./$< > $@
strptr_atxt.exe: strptr_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ strptr_atxt.dats -latsdoc
strptr_atxt.dats: strptr.atxt
	$(ATSDOC) --outcode $@ -i strptr.atxt > strptr_atxt.txt
clean:: ; $(RMF) strptr_atxt.exe
cleanall:: ; $(RMF) strptr.sats

all:: integer_ptr.sats
integer_ptr.sats: integer_ptr_atxt.exe ; ./$< > $@
integer_ptr_atxt.exe: integer_ptr_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ integer_ptr_atxt.dats -latsdoc
integer_ptr_atxt.dats: integer_ptr.atxt
	$(ATSDOC) --outcode $@ -i integer_ptr.atxt > integer_ptr_atxt.txt
clean:: ; $(RMF) integer_ptr_atxt.exe
cleanall:: ; $(RMF) integer_ptr.sats

all:: integer_fixed.sats
integer_fixed.sats: integer_fixed_atxt.exe ; ./$< > $@
integer_fixed_atxt.exe: integer_fixed_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ integer_fixed_atxt.dats -latsdoc
integer_fixed_atxt.dats: integer_fixed.atxt
	$(ATSDOC) --outcode $@ -i integer_fixed.atxt > integer_fixed_atxt.txt
clean:: ; $(RMF) integer_fixed_atxt.exe
cleanall:: ; $(RMF) integer_fixed.sats


all:: tuple.sats
tuple.sats: tuple_atxt.exe ; ./$< > $@
tuple_atxt.exe: tuple_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ tuple_atxt.dats -latsdoc
tuple_atxt.dats: tuple.atxt
	$(ATSDOC) --outcode $@ -i tuple.atxt > tuple_atxt.txt
clean:: ; $(RMF) tuple_atxt.exe
cleanall:: ; $(RMF) tuple.sats

all:: memory.sats
memory.sats: memory_atxt.exe ; ./$< > $@
memory_atxt.exe: memory_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ memory_atxt.dats -latsdoc
memory_atxt.dats: memory.atxt
	$(ATSDOC) --outcode $@ -i memory.atxt > memory_atxt.txt
clean:: ; $(RMF) memory_atxt.exe
cleanall:: ; $(RMF) memory.sats

all:: reference.sats
reference.sats: reference_atxt.exe ; ./$< > $@
reference_atxt.exe: reference_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ reference_atxt.dats -latsdoc
reference_atxt.dats: reference.atxt
	$(ATSDOC) --outcode $@ -i reference.atxt > reference_atxt.txt
clean:: ; $(RMF) reference_atxt.exe
cleanall:: ; $(RMF) reference.sats


all:: unsafe.sats
unsafe.sats: unsafe_atxt.exe ; ./$< > $@
unsafe_atxt.exe: unsafe_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ unsafe_atxt.dats -latsdoc
unsafe_atxt.dats: unsafe.atxt
	$(ATSDOC) --outcode $@ -i unsafe.atxt > unsafe_atxt.txt
clean:: ; $(RMF) unsafe_atxt.exe
cleanall:: ; $(RMF) unsafe.sats

all:: checkast.sats
checkast.sats: checkast_atxt.exe ; ./$< > $@
checkast_atxt.exe: checkast_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ checkast_atxt.dats -latsdoc
checkast_atxt.dats: checkast.atxt
	$(ATSDOC) --outcode $@ -i checkast.atxt > checkast_atxt.txt
clean:: ; $(RMF) checkast_atxt.exe
cleanall:: ; $(RMF) checkast.sats


all:: filebas.sats
filebas.sats: filebas_atxt.exe ; ./$< > $@
filebas_atxt.exe: filebas_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ filebas_atxt.dats -latsdoc
filebas_atxt.dats: filebas.atxt
	$(ATSDOC) --outcode $@ -i filebas.atxt > filebas_atxt.txt
clean:: ; $(RMF) filebas_atxt.exe
cleanall:: ; $(RMF) filebas.sats

all:: intrange.sats
intrange.sats: intrange_atxt.exe ; ./$< > $@
intrange_atxt.exe: intrange_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ intrange_atxt.dats -latsdoc
intrange_atxt.dats: intrange.atxt
	$(ATSDOC) --outcode $@ -i intrange.atxt > intrange_atxt.txt
clean:: ; $(RMF) intrange_atxt.exe
cleanall:: ; $(RMF) intrange.sats


all:: gorder.sats
gorder.sats: gorder_atxt.exe ; ./$< > $@
gorder_atxt.exe: gorder_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ gorder_atxt.dats -latsdoc
gorder_atxt.dats: gorder.atxt
	$(ATSDOC) --outcode $@ -i gorder.atxt > gorder_atxt.txt
clean:: ; $(RMF) gorder_atxt.exe
cleanall:: ; $(RMF) gorder.sats

all:: gnumber.sats
gnumber.sats: gnumber_atxt.exe ; ./$< > $@
gnumber_atxt.exe: gnumber_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ gnumber_atxt.dats -latsdoc
gnumber_atxt.dats: gnumber.atxt
	$(ATSDOC) --outcode $@ -i gnumber.atxt > gnumber_atxt.txt
clean:: ; $(RMF) gnumber_atxt.exe
cleanall:: ; $(RMF) gnumber.sats

all:: grandom.sats
grandom.sats: grandom_atxt.exe ; ./$< > $@
grandom_atxt.exe: grandom_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ grandom_atxt.dats -latsdoc
grandom_atxt.dats: grandom.atxt
	$(ATSDOC) --outcode $@ -i grandom.atxt > grandom_atxt.txt
clean:: ; $(RMF) grandom_atxt.exe
cleanall:: ; $(RMF) grandom.sats


all:: list_vt.sats
list_vt.sats: list_vt_atxt.exe ; ./$< > $@
list_vt_atxt.exe: list_vt_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ list_vt_atxt.dats -latsdoc
list_vt_atxt.dats: list_vt.atxt
	$(ATSDOC) --outcode $@ -i list_vt.atxt > list_vt_atxt.txt
clean:: ; $(RMF) list_vt_atxt.exe
cleanall:: ; $(RMF) list_vt.sats


all:: option_vt.sats
option_vt.sats: option_vt_atxt.exe ; ./$< > $@
option_vt_atxt.exe: option_vt_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ option_vt_atxt.dats -latsdoc
option_vt_atxt.dats: option_vt.atxt
	$(ATSDOC) --outcode $@ -i option_vt.atxt > option_vt_atxt.txt
clean:: ; $(RMF) option_vt_atxt.exe
cleanall:: ; $(RMF) option_vt.sats


all:: array.sats
array.sats: array_atxt.exe ; ./$< > $@
array_atxt.exe: array_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ array_atxt.dats -latsdoc
array_atxt.dats: array.atxt
	$(ATSDOC) --outcode $@ -i array.atxt > array_atxt.txt
clean:: ; $(RMF) array_atxt.exe
cleanall:: ; $(RMF) array.sats

all:: array_prf.sats
array_prf.sats: array_prf_atxt.exe ; ./$< > $@
array_prf_atxt.exe: array_prf_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ array_prf_atxt.dats -latsdoc
array_prf_atxt.dats: array_prf.atxt
	$(ATSDOC) --outcode $@ -i array_prf.atxt > array_prf_atxt.txt
clean:: ; $(RMF) array_prf_atxt.exe
cleanall:: ; $(RMF) array_prf.sats

all:: arrayptr.sats
arrayptr.sats: arrayptr_atxt.exe ; ./$< > $@
arrayptr_atxt.exe: arrayptr_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ arrayptr_atxt.dats -latsdoc
arrayptr_atxt.dats: arrayptr.atxt
	$(ATSDOC) --outcode $@ -i arrayptr.atxt > arrayptr_atxt.txt
clean:: ; $(RMF) arrayptr_atxt.exe
cleanall:: ; $(RMF) arrayptr.sats


all:: matrix.sats
matrix.sats: matrix_atxt.exe ; ./$< > $@
matrix_atxt.exe: matrix_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ matrix_atxt.dats -latsdoc
matrix_atxt.dats: matrix.atxt
	$(ATSDOC) --outcode $@ -i matrix.atxt > matrix_atxt.txt
clean:: ; $(RMF) matrix_atxt.exe
cleanall:: ; $(RMF) matrix.sats

all:: matrixptr.sats
matrixptr.sats: matrixptr_atxt.exe ; ./$< > $@
matrixptr_atxt.exe: matrixptr_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ matrixptr_atxt.dats -latsdoc
matrixptr_atxt.dats: matrixptr.atxt
	$(ATSDOC) --outcode $@ -i matrixptr.atxt > matrixptr_atxt.txt
clean:: ; $(RMF) matrixptr_atxt.exe
cleanall:: ; $(RMF) matrixptr.sats


all:: stream_vt.sats
stream_vt.sats: stream_vt_atxt.exe ; ./$< > $@
stream_vt_atxt.exe: stream_vt_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ stream_vt_atxt.dats -latsdoc
stream_vt_atxt.dats: stream_vt.atxt
	$(ATSDOC) --outcode $@ -i stream_vt.atxt > stream_vt_atxt.txt
clean:: ; $(RMF) stream_vt_atxt.exe
cleanall:: ; $(RMF) stream_vt.sats


all:: gprint.sats
gprint.sats: gprint_atxt.exe ; ./$< > $@
gprint_atxt.exe: gprint_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ gprint_atxt.dats -latsdoc
gprint_atxt.dats: gprint.atxt
	$(ATSDOC) --outcode $@ -i gprint.atxt > gprint_atxt.txt
clean:: ; $(RMF) gprint_atxt.exe
cleanall:: ; $(RMF) gprint.sats

all:: tostring.sats
tostring.sats: tostring_atxt.exe ; ./$< > $@
tostring_atxt.exe: tostring_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ tostring_atxt.dats -latsdoc
tostring_atxt.dats: tostring.atxt
	$(ATSDOC) --outcode $@ -i tostring.atxt > tostring_atxt.txt
clean:: ; $(RMF) tostring_atxt.exe
cleanall:: ; $(RMF) tostring.sats



all:: parray.sats
parray.sats: parray_atxt.exe ; ./$< > $@
parray_atxt.exe: parray_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ parray_atxt.dats -latsdoc
parray_atxt.dats: parray.atxt
	$(ATSDOC) --outcode $@ -i parray.atxt > parray_atxt.txt
clean:: ; $(RMF) parray_atxt.exe
cleanall:: ; $(RMF) parray.sats


all:: extern.sats
extern.sats: extern_atxt.exe ; ./$< > $@
extern_atxt.exe: extern_atxt.dats
	$(PATSCC) $(PATSCCFLAGS) -o $@ extern_atxt.dats -latsdoc
extern_atxt.dats: extern.atxt
	$(ATSDOC) --outcode $@ -i extern.atxt > extern_atxt.txt
clean:: ; $(RMF) extern_atxt.exe
cleanall:: ; $(RMF) extern.sats


######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o *_?ats.c
clean:: ; $(RMF) *_atxt.txt
clean:: ; $(RMF) *_atxt.dats

cleanall:: clean

###### end of [Makefile] ######
