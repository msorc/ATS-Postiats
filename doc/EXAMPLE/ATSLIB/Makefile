#
#
# This Makefile is automatically generated
# from executing the following command-line:
#
# make -f Makefile.gen
#
#

######
#
CCOPT=gcc
#
# CCOPT=gcc -std=c99
#
######

ifeq ("$(PATSHOME)","")
  PATSHOMEQ="$(ATSHOME)"
else
  PATSHOMEQ="$(PATSHOME)"
endif

######

PATSOPT=$(PATSHOMEQ)/bin/patsopt
PATSLIB=$(PATSHOMEQ)/ccomp/atslib/lib

######

all::

######

LNS=ln -s
RMF=rm -f

######

all:: prelude_basics
prelude_basics: prelude_basics.exe
prelude_basics.exe: prelude_basics_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2 -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -o $@ $<
prelude_basics_dats.c: prelude_basics.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_basics_dats.c --dynamic prelude_basics.dats
clean:: ; $(RMF) prelude_basics_dats.o
clean:: ; $(RMF) prelude_basics_dats.c
cleanall:: ; $(RMF) prelude_basics.exe
regress:: ; ./prelude_basics.exe ; ./prelude_basics.exe || (echo "$< failed" && exit 1)

######

all:: prelude_integer
prelude_integer: prelude_integer.exe
prelude_integer.exe: prelude_integer_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_integer_dats.c: prelude_integer.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_integer_dats.c --dynamic prelude_integer.dats
clean:: ; $(RMF) prelude_integer_dats.o
clean:: ; $(RMF) prelude_integer_dats.c
cleanall:: ; $(RMF) prelude_integer.exe
regress:: ./prelude_integer.exe ; ./prelude_integer.exe || (echo "$< failed" && exit 1)

######

all:: prelude_bool
prelude_bool: prelude_bool.exe
prelude_bool.exe: prelude_bool_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_bool_dats.c: prelude_bool.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_bool_dats.c --dynamic prelude_bool.dats
clean:: ; $(RMF) prelude_bool_dats.o
clean:: ; $(RMF) prelude_bool_dats.c
cleanall:: ; $(RMF) prelude_bool.exe
regress:: ./prelude_bool.exe ; ./prelude_bool.exe || (echo "$< failed" && exit 1)
all:: prelude_char
prelude_char: prelude_char.exe
prelude_char.exe: prelude_char_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_char_dats.c: prelude_char.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_char_dats.c --dynamic prelude_char.dats
clean:: ; $(RMF) prelude_char_dats.o
clean:: ; $(RMF) prelude_char_dats.c
cleanall:: ; $(RMF) prelude_char.exe
regress:: ./prelude_char.exe ; ./prelude_char.exe || (echo "$< failed" && exit 1)
all:: prelude_float
prelude_float: prelude_float.exe
prelude_float.exe: prelude_float_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< -lm
prelude_float_dats.c: prelude_float.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_float_dats.c --dynamic prelude_float.dats
clean:: ; $(RMF) prelude_float_dats.o
clean:: ; $(RMF) prelude_float_dats.c
cleanall:: ; $(RMF) prelude_float.exe
regress:: ./prelude_float.exe ; ./prelude_float.exe || (echo "$< failed" && exit 1)

######


######

all:: prelude_memory
prelude_memory: prelude_memory.exe
prelude_memory.exe: prelude_memory_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_memory_dats.c: prelude_memory.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_memory_dats.c --dynamic prelude_memory.dats
clean:: ; $(RMF) prelude_memory_dats.o
clean:: ; $(RMF) prelude_memory_dats.c
cleanall:: ; $(RMF) prelude_memory.exe
regress:: ./prelude_memory.exe ; ./prelude_memory.exe || (echo "$< failed" && exit 1)
all:: prelude_pointer
prelude_pointer: prelude_pointer.exe
prelude_pointer.exe: prelude_pointer_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_pointer_dats.c: prelude_pointer.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_pointer_dats.c --dynamic prelude_pointer.dats
clean:: ; $(RMF) prelude_pointer_dats.o
clean:: ; $(RMF) prelude_pointer_dats.c
cleanall:: ; $(RMF) prelude_pointer.exe
regress:: ./prelude_pointer.exe ; ./prelude_pointer.exe || (echo "$< failed" && exit 1)

######


######

all:: prelude_filebas
prelude_filebas: prelude_filebas.exe
prelude_filebas.exe: prelude_filebas_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< -L$(PATSLIB) -latslib
prelude_filebas_dats.c: prelude_filebas.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_filebas_dats.c --dynamic prelude_filebas.dats
clean:: ; $(RMF) prelude_filebas_dats.o
clean:: ; $(RMF) prelude_filebas_dats.c
cleanall:: ; $(RMF) prelude_filebas.exe
regress:: ./prelude_filebas.exe ; ./prelude_filebas.exe || (echo "$< failed" && exit 1)

######

all:: prelude_checkast
prelude_checkast: prelude_checkast.exe
prelude_checkast.exe: prelude_checkast_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2 -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -o $@ $<
prelude_checkast_dats.c: prelude_checkast.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_checkast_dats.c --dynamic prelude_checkast.dats
clean:: ; $(RMF) prelude_checkast_dats.o
clean:: ; $(RMF) prelude_checkast_dats.c
cleanall:: ; $(RMF) prelude_checkast.exe
regress:: ; ./prelude_checkast.exe ; ./prelude_checkast.exe || (echo "$< failed" && exit 1)

######

all:: prelude_intrange
prelude_intrange: prelude_intrange.exe
prelude_intrange.exe: prelude_intrange_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_intrange_dats.c: prelude_intrange.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_intrange_dats.c --dynamic prelude_intrange.dats
clean:: ; $(RMF) prelude_intrange_dats.o
clean:: ; $(RMF) prelude_intrange_dats.c
cleanall:: ; $(RMF) prelude_intrange.exe
regress:: ./prelude_intrange.exe ; ./prelude_intrange.exe || (echo "$< failed" && exit 1)

######

all:: prelude_list_vt
prelude_list_vt: prelude_list_vt.exe
prelude_list_vt.exe: prelude_list_vt_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_list_vt_dats.c: prelude_list_vt.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_list_vt_dats.c --dynamic prelude_list_vt.dats
clean:: ; $(RMF) prelude_list_vt_dats.o
clean:: ; $(RMF) prelude_list_vt_dats.c
cleanall:: ; $(RMF) prelude_list_vt.exe
regress:: ./prelude_list_vt.exe ; ./prelude_list_vt.exe || (echo "$< failed" && exit 1)

all:: prelude_option_vt
prelude_option_vt: prelude_option_vt.exe
prelude_option_vt.exe: prelude_option_vt_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_option_vt_dats.c: prelude_option_vt.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_option_vt_dats.c --dynamic prelude_option_vt.dats
clean:: ; $(RMF) prelude_option_vt_dats.o
clean:: ; $(RMF) prelude_option_vt_dats.c
cleanall:: ; $(RMF) prelude_option_vt.exe
regress:: ./prelude_option_vt.exe ; ./prelude_option_vt.exe || (echo "$< failed" && exit 1)

all:: prelude_array
prelude_array: prelude_array.exe
prelude_array.exe: prelude_array_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_array_dats.c: prelude_array.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_array_dats.c --dynamic prelude_array.dats
clean:: ; $(RMF) prelude_array_dats.o
clean:: ; $(RMF) prelude_array_dats.c
cleanall:: ; $(RMF) prelude_array.exe
regress:: ./prelude_array.exe ; ./prelude_array.exe || (echo "$< failed" && exit 1)

all:: prelude_matrix
prelude_matrix: prelude_matrix.exe
prelude_matrix.exe: prelude_matrix_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_matrix_dats.c: prelude_matrix.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_matrix_dats.c --dynamic prelude_matrix.dats
clean:: ; $(RMF) prelude_matrix_dats.o
clean:: ; $(RMF) prelude_matrix_dats.c
cleanall:: ; $(RMF) prelude_matrix.exe
regress:: ./prelude_matrix.exe ; ./prelude_matrix.exe || (echo "$< failed" && exit 1)
all:: prelude_matrixptr
prelude_matrixptr: prelude_matrixptr.exe
prelude_matrixptr.exe: prelude_matrixptr_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_matrixptr_dats.c: prelude_matrixptr.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_matrixptr_dats.c --dynamic prelude_matrixptr.dats
clean:: ; $(RMF) prelude_matrixptr_dats.o
clean:: ; $(RMF) prelude_matrixptr_dats.c
cleanall:: ; $(RMF) prelude_matrixptr.exe
regress:: ./prelude_matrixptr.exe ; ./prelude_matrixptr.exe || (echo "$< failed" && exit 1)
all:: prelude_matrixref
prelude_matrixref: prelude_matrixref.exe
prelude_matrixref.exe: prelude_matrixref_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_matrixref_dats.c: prelude_matrixref.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_matrixref_dats.c --dynamic prelude_matrixref.dats
clean:: ; $(RMF) prelude_matrixref_dats.o
clean:: ; $(RMF) prelude_matrixref_dats.c
cleanall:: ; $(RMF) prelude_matrixref.exe
regress:: ./prelude_matrixref.exe ; ./prelude_matrixref.exe || (echo "$< failed" && exit 1)


######

all:: prelude_grandom
prelude_grandom: prelude_grandom.exe
prelude_grandom.exe: prelude_grandom_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_grandom_dats.c: prelude_grandom.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_grandom_dats.c --dynamic prelude_grandom.dats
clean:: ; $(RMF) prelude_grandom_dats.o
clean:: ; $(RMF) prelude_grandom_dats.c
cleanall:: ; $(RMF) prelude_grandom.exe
regress:: ./prelude_grandom.exe ; ./prelude_grandom.exe || (echo "$< failed" && exit 1)

######

all:: prelude_gprint
prelude_gprint: prelude_gprint.exe
prelude_gprint.exe: prelude_gprint_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
prelude_gprint_dats.c: prelude_gprint.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output prelude_gprint_dats.c --dynamic prelude_gprint.dats
clean:: ; $(RMF) prelude_gprint_dats.o
clean:: ; $(RMF) prelude_gprint_dats.c
cleanall:: ; $(RMF) prelude_gprint.exe
regress:: ./prelude_gprint.exe ; ./prelude_gprint.exe || (echo "$< failed" && exit 1)

######

all:: libats_qlist
libats_qlist: libats_qlist.exe
libats_qlist.exe: libats_qlist_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_qlist_dats.c: libats_qlist.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_qlist_dats.c --dynamic libats_qlist.dats
clean:: ; $(RMF) libats_qlist_dats.o
clean:: ; $(RMF) libats_qlist_dats.c
cleanall:: ; $(RMF) libats_qlist.exe
regress:: ./libats_qlist.exe ; ./libats_qlist.exe || (echo "$< failed" && exit 1)
all:: libats_sllist
libats_sllist: libats_sllist.exe
libats_sllist.exe: libats_sllist_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_sllist_dats.c: libats_sllist.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_sllist_dats.c --dynamic libats_sllist.dats
clean:: ; $(RMF) libats_sllist_dats.o
clean:: ; $(RMF) libats_sllist_dats.c
cleanall:: ; $(RMF) libats_sllist.exe
regress:: ./libats_sllist.exe ; ./libats_sllist.exe || (echo "$< failed" && exit 1)
all:: libats_dllist
libats_dllist: libats_dllist.exe
libats_dllist.exe: libats_dllist_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_dllist_dats.c: libats_dllist.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_dllist_dats.c --dynamic libats_dllist.dats
clean:: ; $(RMF) libats_dllist_dats.o
clean:: ; $(RMF) libats_dllist_dats.c
cleanall:: ; $(RMF) libats_dllist.exe
regress:: ./libats_dllist.exe ; ./libats_dllist.exe || (echo "$< failed" && exit 1)

######


######

all:: libats_bitvec
libats_bitvec: libats_bitvec.exe
libats_bitvec.exe: libats_bitvec_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_bitvec_dats.c: libats_bitvec.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_bitvec_dats.c --dynamic libats_bitvec.dats
clean:: ; $(RMF) libats_bitvec_dats.o
clean:: ; $(RMF) libats_bitvec_dats.c
cleanall:: ; $(RMF) libats_bitvec.exe
regress:: ./libats_bitvec.exe ; ./libats_bitvec.exe || (echo "$< failed" && exit 1)

######

all:: libats_stkarray
libats_stkarray: libats_stkarray.exe
libats_stkarray.exe: libats_stkarray_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_stkarray_dats.c: libats_stkarray.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_stkarray_dats.c --dynamic libats_stkarray.dats
clean:: ; $(RMF) libats_stkarray_dats.o
clean:: ; $(RMF) libats_stkarray_dats.c
cleanall:: ; $(RMF) libats_stkarray.exe
regress:: ./libats_stkarray.exe ; ./libats_stkarray.exe || (echo "$< failed" && exit 1)
all:: libats_deqarray
libats_deqarray: libats_deqarray.exe
libats_deqarray.exe: libats_deqarray_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_deqarray_dats.c: libats_deqarray.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_deqarray_dats.c --dynamic libats_deqarray.dats
clean:: ; $(RMF) libats_deqarray_dats.o
clean:: ; $(RMF) libats_deqarray_dats.c
cleanall:: ; $(RMF) libats_deqarray.exe
regress:: ./libats_deqarray.exe ; ./libats_deqarray.exe || (echo "$< failed" && exit 1)

######

all:: libats_dynarray
libats_dynarray: libats_dynarray.exe
libats_dynarray.exe: libats_dynarray_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_dynarray_dats.c: libats_dynarray.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_dynarray_dats.c --dynamic libats_dynarray.dats
clean:: ; $(RMF) libats_dynarray_dats.o
clean:: ; $(RMF) libats_dynarray_dats.c
cleanall:: ; $(RMF) libats_dynarray.exe
regress:: ./libats_dynarray.exe ; ./libats_dynarray.exe || (echo "$< failed" && exit 1)

######

all:: libats_refcount
libats_refcount: libats_refcount.exe
libats_refcount.exe: libats_refcount_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_refcount_dats.c: libats_refcount.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_refcount_dats.c --dynamic libats_refcount.dats
clean:: ; $(RMF) libats_refcount_dats.o
clean:: ; $(RMF) libats_refcount_dats.c
cleanall:: ; $(RMF) libats_refcount.exe
regress:: ./libats_refcount.exe ; ./libats_refcount.exe || (echo "$< failed" && exit 1)

######



######



######

all:: libats_hashtbl_chain
libats_hashtbl_chain: libats_hashtbl_chain.exe
libats_hashtbl_chain.exe: libats_hashtbl_chain_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_hashtbl_chain_dats.c: libats_hashtbl_chain.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_hashtbl_chain_dats.c --dynamic libats_hashtbl_chain.dats
clean:: ; $(RMF) libats_hashtbl_chain_dats.o
clean:: ; $(RMF) libats_hashtbl_chain_dats.c
cleanall:: ; $(RMF) libats_hashtbl_chain.exe
regress:: ./libats_hashtbl_chain.exe ; ./libats_hashtbl_chain.exe || (echo "$< failed" && exit 1)
all:: libats_hashtbl_linprb
libats_hashtbl_linprb: libats_hashtbl_linprb.exe
libats_hashtbl_linprb.exe: libats_hashtbl_linprb_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_hashtbl_linprb_dats.c: libats_hashtbl_linprb.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_hashtbl_linprb_dats.c --dynamic libats_hashtbl_linprb.dats
clean:: ; $(RMF) libats_hashtbl_linprb_dats.o
clean:: ; $(RMF) libats_hashtbl_linprb_dats.c
cleanall:: ; $(RMF) libats_hashtbl_linprb.exe
regress:: ./libats_hashtbl_linprb.exe ; ./libats_hashtbl_linprb.exe || (echo "$< failed" && exit 1)

######


######


######


######


######


######

all:: libats_linmap_list
libats_linmap_list: libats_linmap_list.exe
libats_linmap_list.exe: libats_linmap_list_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_linmap_list_dats.c: libats_linmap_list.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_linmap_list_dats.c --dynamic libats_linmap_list.dats
clean:: ; $(RMF) libats_linmap_list_dats.o
clean:: ; $(RMF) libats_linmap_list_dats.c
cleanall:: ; $(RMF) libats_linmap_list.exe
regress:: ./libats_linmap_list.exe ; ./libats_linmap_list.exe || (echo "$< failed" && exit 1)
all:: libats_linmap_avltree
libats_linmap_avltree: libats_linmap_avltree.exe
libats_linmap_avltree.exe: libats_linmap_avltree_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_linmap_avltree_dats.c: libats_linmap_avltree.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_linmap_avltree_dats.c --dynamic libats_linmap_avltree.dats
clean:: ; $(RMF) libats_linmap_avltree_dats.o
clean:: ; $(RMF) libats_linmap_avltree_dats.c
cleanall:: ; $(RMF) libats_linmap_avltree.exe
regress:: ./libats_linmap_avltree.exe ; ./libats_linmap_avltree.exe || (echo "$< failed" && exit 1)
all:: libats_linmap_randbst
libats_linmap_randbst: libats_linmap_randbst.exe
libats_linmap_randbst.exe: libats_linmap_randbst_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_linmap_randbst_dats.c: libats_linmap_randbst.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_linmap_randbst_dats.c --dynamic libats_linmap_randbst.dats
clean:: ; $(RMF) libats_linmap_randbst_dats.o
clean:: ; $(RMF) libats_linmap_randbst_dats.c
cleanall:: ; $(RMF) libats_linmap_randbst.exe
regress:: ./libats_linmap_randbst.exe ; ./libats_linmap_randbst.exe || (echo "$< failed" && exit 1)
all:: libats_linmap_skiplist
libats_linmap_skiplist: libats_linmap_skiplist.exe
libats_linmap_skiplist.exe: libats_linmap_skiplist_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< -L$(PATSLIB) -latslib
libats_linmap_skiplist_dats.c: libats_linmap_skiplist.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_linmap_skiplist_dats.c --dynamic libats_linmap_skiplist.dats
clean:: ; $(RMF) libats_linmap_skiplist_dats.o
clean:: ; $(RMF) libats_linmap_skiplist_dats.c
cleanall:: ; $(RMF) libats_linmap_skiplist.exe
regress:: ./libats_linmap_skiplist.exe ; ./libats_linmap_skiplist.exe || (echo "$< failed" && exit 1)

######


######

all:: libats_linheap_binomial
libats_linheap_binomial: libats_linheap_binomial.exe
libats_linheap_binomial.exe: libats_linheap_binomial_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_linheap_binomial_dats.c: libats_linheap_binomial.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_linheap_binomial_dats.c --dynamic libats_linheap_binomial.dats
clean:: ; $(RMF) libats_linheap_binomial_dats.o
clean:: ; $(RMF) libats_linheap_binomial_dats.c
cleanall:: ; $(RMF) libats_linheap_binomial.exe
regress:: ./libats_linheap_binomial.exe ; ./libats_linheap_binomial.exe || (echo "$< failed" && exit 1)
all:: libats_linheap_binomial2
libats_linheap_binomial2: libats_linheap_binomial2.exe
libats_linheap_binomial2.exe: libats_linheap_binomial2_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_linheap_binomial2_dats.c: libats_linheap_binomial2.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_linheap_binomial2_dats.c --dynamic libats_linheap_binomial2.dats
clean:: ; $(RMF) libats_linheap_binomial2_dats.o
clean:: ; $(RMF) libats_linheap_binomial2_dats.c
cleanall:: ; $(RMF) libats_linheap_binomial2.exe
regress:: ./libats_linheap_binomial2.exe ; ./libats_linheap_binomial2.exe || (echo "$< failed" && exit 1)

######

all:: libats_lindeque_dllist
libats_lindeque_dllist: libats_lindeque_dllist.exe
libats_lindeque_dllist.exe: libats_lindeque_dllist_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_lindeque_dllist_dats.c: libats_lindeque_dllist.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_lindeque_dllist_dats.c --dynamic libats_lindeque_dllist.dats
clean:: ; $(RMF) libats_lindeque_dllist_dats.o
clean:: ; $(RMF) libats_lindeque_dllist_dats.c
cleanall:: ; $(RMF) libats_lindeque_dllist.exe
regress:: ./libats_lindeque_dllist.exe ; ./libats_lindeque_dllist.exe || (echo "$< failed" && exit 1)

######


######


######


######


######


######


######


######


######

all:: libats_libc_fcntl
libats_libc_fcntl: libats_libc_fcntl.exe
libats_libc_fcntl.exe: libats_libc_fcntl_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2 -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -o $@ $<
libats_libc_fcntl_dats.c: libats_libc_fcntl.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_fcntl_dats.c --dynamic libats_libc_fcntl.dats
clean:: ; $(RMF) libats_libc_fcntl_dats.o
clean:: ; $(RMF) libats_libc_fcntl_dats.c
cleanall:: ; $(RMF) libats_libc_fcntl.exe
regress:: ; ./libats_libc_fcntl.exe ; ./libats_libc_fcntl.exe || (echo "$< failed" && exit 1)
all:: libats_libc_fnmatch
libats_libc_fnmatch: libats_libc_fnmatch.exe
libats_libc_fnmatch.exe: libats_libc_fnmatch_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2 -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -o $@ $<
libats_libc_fnmatch_dats.c: libats_libc_fnmatch.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_fnmatch_dats.c --dynamic libats_libc_fnmatch.dats
clean:: ; $(RMF) libats_libc_fnmatch_dats.o
clean:: ; $(RMF) libats_libc_fnmatch_dats.c
cleanall:: ; $(RMF) libats_libc_fnmatch.exe
regress:: ; ./libats_libc_fnmatch.exe ; ./libats_libc_fnmatch.exe || (echo "$< failed" && exit 1)
all:: libats_libc_math
libats_libc_math: libats_libc_math.exe
libats_libc_math.exe: libats_libc_math_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime  -o $@ $< -lm
libats_libc_math_dats.c: libats_libc_math.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_math_dats.c --dynamic libats_libc_math.dats
clean:: ; $(RMF) libats_libc_math_dats.o
clean:: ; $(RMF) libats_libc_math_dats.c
cleanall:: ; $(RMF) libats_libc_math.exe
regress:: ./libats_libc_math.exe ; ./libats_libc_math.exe || (echo "$< failed" && exit 1)
all:: libats_libc_dlfcn
libats_libc_dlfcn: libats_libc_dlfcn.exe
libats_libc_dlfcn.exe: libats_libc_dlfcn_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime  -o $@ $< -ldl
libats_libc_dlfcn_dats.c: libats_libc_dlfcn.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_dlfcn_dats.c --dynamic libats_libc_dlfcn.dats
clean:: ; $(RMF) libats_libc_dlfcn_dats.o
clean:: ; $(RMF) libats_libc_dlfcn_dats.c
cleanall:: ; $(RMF) libats_libc_dlfcn.exe
regress:: ./libats_libc_dlfcn.exe ; ./libats_libc_dlfcn.exe || (echo "$< failed" && exit 1)
all:: libats_libc_dirent
libats_libc_dirent: libats_libc_dirent.exe
libats_libc_dirent.exe: libats_libc_dirent_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< -L$(PATSLIB) -latslib
libats_libc_dirent_dats.c: libats_libc_dirent.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_dirent_dats.c --dynamic libats_libc_dirent.dats
clean:: ; $(RMF) libats_libc_dirent_dats.o
clean:: ; $(RMF) libats_libc_dirent_dats.c
cleanall:: ; $(RMF) libats_libc_dirent.exe
regress:: ./libats_libc_dirent.exe ; ./libats_libc_dirent.exe || (echo "$< failed" && exit 1)
all:: libats_libc_malloc
libats_libc_malloc: libats_libc_malloc.exe
libats_libc_malloc.exe: libats_libc_malloc_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_libc_malloc_dats.c: libats_libc_malloc.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_malloc_dats.c --dynamic libats_libc_malloc.dats
clean:: ; $(RMF) libats_libc_malloc_dats.o
clean:: ; $(RMF) libats_libc_malloc_dats.c
cleanall:: ; $(RMF) libats_libc_malloc.exe
regress:: ./libats_libc_malloc.exe ; ./libats_libc_malloc.exe || (echo "$< failed" && exit 1)
all:: libats_libc_signal
libats_libc_signal: libats_libc_signal.exe
libats_libc_signal.exe: libats_libc_signal_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< -L$(PATSLIB) -latslib
libats_libc_signal_dats.c: libats_libc_signal.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_signal_dats.c --dynamic libats_libc_signal.dats
clean:: ; $(RMF) libats_libc_signal_dats.o
clean:: ; $(RMF) libats_libc_signal_dats.c
cleanall:: ; $(RMF) libats_libc_signal.exe
regress:: ./libats_libc_signal.exe ; ./libats_libc_signal.exe || (echo "$< failed" && exit 1)
all:: libats_libc_stdio
libats_libc_stdio: libats_libc_stdio.exe
libats_libc_stdio.exe: libats_libc_stdio_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< -L$(PATSLIB) -latslib
libats_libc_stdio_dats.c: libats_libc_stdio.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_stdio_dats.c --dynamic libats_libc_stdio.dats
clean:: ; $(RMF) libats_libc_stdio_dats.o
clean:: ; $(RMF) libats_libc_stdio_dats.c
cleanall:: ; $(RMF) libats_libc_stdio.exe
regress:: ./libats_libc_stdio.exe ; ./libats_libc_stdio.exe || (echo "$< failed" && exit 1)
all:: libats_libc_stdlib
libats_libc_stdlib: libats_libc_stdlib.exe
libats_libc_stdlib.exe: libats_libc_stdlib_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_libc_stdlib_dats.c: libats_libc_stdlib.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_stdlib_dats.c --dynamic libats_libc_stdlib.dats
clean:: ; $(RMF) libats_libc_stdlib_dats.o
clean:: ; $(RMF) libats_libc_stdlib_dats.c
cleanall:: ; $(RMF) libats_libc_stdlib.exe
regress:: ./libats_libc_stdlib.exe ; ./libats_libc_stdlib.exe || (echo "$< failed" && exit 1)
all:: libats_libc_string
libats_libc_string: libats_libc_string.exe
libats_libc_string.exe: libats_libc_string_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< -L$(PATSLIB) -latslib
libats_libc_string_dats.c: libats_libc_string.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_string_dats.c --dynamic libats_libc_string.dats
clean:: ; $(RMF) libats_libc_string_dats.o
clean:: ; $(RMF) libats_libc_string_dats.c
cleanall:: ; $(RMF) libats_libc_string.exe
regress:: ./libats_libc_string.exe ; ./libats_libc_string.exe || (echo "$< failed" && exit 1)
all:: libats_libc_strings
libats_libc_strings: libats_libc_strings.exe
libats_libc_strings.exe: libats_libc_strings_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_libc_strings_dats.c: libats_libc_strings.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_strings_dats.c --dynamic libats_libc_strings.dats
clean:: ; $(RMF) libats_libc_strings_dats.o
clean:: ; $(RMF) libats_libc_strings_dats.c
cleanall:: ; $(RMF) libats_libc_strings.exe
regress:: ./libats_libc_strings.exe ; ./libats_libc_strings.exe || (echo "$< failed" && exit 1)
all:: libats_libc_time
libats_libc_time: libats_libc_time.exe
libats_libc_time.exe: libats_libc_time_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< 
libats_libc_time_dats.c: libats_libc_time.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_time_dats.c --dynamic libats_libc_time.dats
clean:: ; $(RMF) libats_libc_time_dats.o
clean:: ; $(RMF) libats_libc_time_dats.c
cleanall:: ; $(RMF) libats_libc_time.exe
regress:: ./libats_libc_time.exe ; ./libats_libc_time.exe || (echo "$< failed" && exit 1)
all:: libats_libc_unistd
libats_libc_unistd: libats_libc_unistd.exe
libats_libc_unistd.exe: libats_libc_unistd_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< -L$(PATSLIB) -latslib
libats_libc_unistd_dats.c: libats_libc_unistd.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_unistd_dats.c --dynamic libats_libc_unistd.dats
clean:: ; $(RMF) libats_libc_unistd_dats.o
clean:: ; $(RMF) libats_libc_unistd_dats.c
cleanall:: ; $(RMF) libats_libc_unistd.exe
regress:: ./libats_libc_unistd.exe ; ./libats_libc_unistd.exe || (echo "$< failed" && exit 1)

######


######

all:: libats_libc_gdbm_gdbm
libats_libc_gdbm_gdbm: libats_libc_gdbm_gdbm.exe
libats_libc_gdbm_gdbm.exe: libats_libc_gdbm_gdbm_dats.c ;   $(CCOPT) -D_GNU_SOURCE -O2     -I$(PATSHOMEQ) -I$(PATSHOMEQ)/ccomp/runtime -DATS_MEMALLOC_LIBC -o $@ $< -lgdbm
libats_libc_gdbm_gdbm_dats.c: libats_libc_gdbm_gdbm.dats ;   $(PATSOPT) -IATS$(PATSHOMEQ)/contrib --output libats_libc_gdbm_gdbm_dats.c --dynamic libats_libc_gdbm_gdbm.dats
clean:: ; $(RMF) libats_libc_gdbm_gdbm_dats.o
clean:: ; $(RMF) libats_libc_gdbm_gdbm_dats.c
cleanall:: ; $(RMF) libats_libc_gdbm_gdbm.exe
regress:: ./libats_libc_gdbm_gdbm.exe ; ./libats_libc_gdbm_gdbm.exe || (echo "$< failed" && exit 1)

######




######


######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o *_?ats.c
clean:: ; $(RMF) *_atxt.txt
clean:: ; $(RMF) *_atxt.dats
clean:: ; $(RMF) gdbmtest.gdbm
clean:: ; $(RMF) Makefile.exe

cleanall:: clean

###### end of [Makefile] ######
