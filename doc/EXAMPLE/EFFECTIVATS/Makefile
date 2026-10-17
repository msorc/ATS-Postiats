#
# A simple Makefile
#

######

MAKE=make

######

all::
clean:: ; $(MAKE) all TARGET=clean
cleanall:: ; $(MAKE) all TARGET=cleanall

######
#
TARGET=all
#
# TARGET=main.html
# TARGET=all upload_main
#
######

all :: \
prop-logic
prop-logic:: ; \
$(MAKE) -C $@ $(TARGET)

all :: \
file-copying
file-copying:: ; \
$(MAKE) -C $@ $(TARGET)




all :: \
word-counting
word-counting:: ; \
$(MAKE) -C $@ $(TARGET)

all :: \
stack-array
stack-array:: ; \
$(MAKE) -C $@ $(TARGET)

all :: \
queue-sllist2
queue-sllist2:: ; \
$(MAKE) -C $@ $(TARGET)

all :: \
mergesort
mergesort:: ; \
$(MAKE) -C $@ $(TARGET)


all :: \
sorting-linear-lists
sorting-linear-lists:: ; \
$(MAKE) -C $@ $(TARGET)




all :: \
Readers-and-Writers
Readers-and-Writers:: ; \
$(MAKE) -C $@ $(TARGET)


# all :: \
# http-server
# http-server:: ; \
# $(MAKE) -C $@ $(TARGET)


all :: \
PwTP-bool-vs-prop
PwTP-bool-vs-prop:: ; \
$(MAKE) -C $@ $(TARGET)




all :: \
linear-streams
linear-streams:: ; \
$(MAKE) -C $@ $(TARGET)






######

uploadall::
uploadall::upload_index
uploadall::upload_prop-logic
uploadall::upload_file-copying
uploadall::upload_word-counting
uploadall::upload_stack-array
uploadall::upload_queue-sllist2
uploadall::upload_mergesort
uploadall::upload_sorting-linear-lists
uploadall::upload_Readers-and-Writers
uploadall::upload_http-server
uploadall::upload_PwTP-bool-vs-prop
uploadall::upload_linear-streams

######

SCP=scp

######

upload_index:: ; \
  $(SCP) \
  ./index.html \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/

######

upload_prop-logic:: ; \
  $(SCP) \
  prop-logic/index.html \
  prop-logic/Makefile prop-logic/*.?ats \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/prop-logic/

######

upload_file-copying:: ; \
  $(SCP) \
  file-copying/index.html \
  file-copying/Makefile file-copying/*.?ats \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/file-copying/

######

upload_stack-array:: ; \
  $(SCP) \
  stack-array/index.html \
  stack-array/Makefile stack-array/*.?ats \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/stack-array/

######

upload_queue-sllist2:: ; \
  $(SCP) \
  queue-sllist2/index.html \
  queue-sllist2/Makefile queue-sllist2/*.?ats \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/queue-sllist2/

######

upload_word-counting:: ; \
  $(SCP) \
  word-counting/index.html \
  word-counting/Makefile word-counting/*.?ats \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/word-counting/

######

upload_mergesort:: ; \
  $(SCP) \
  mergesort/index.html \
  mergesort/Makefile mergesort/*.?ats \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/mergesort/

######

upload_sorting-linear-lists:: ; \
  $(SCP) \
  sorting-linear-lists/index.html \
  sorting-linear-lists/Makefile \
  sorting-linear-lists/mylist.dats \
  sorting-linear-lists/mylist_mergesort.dats \
  sorting-linear-lists/mergesort_sllist.dats \
  sorting-linear-lists/mergesort_list_vt.dats \
  sorting-linear-lists/mylist_quicksort.dats \
  sorting-linear-lists/quicksort_sllist.dats \
  sorting-linear-lists/quicksort_list_vt.dats \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/sorting-linear-lists

######

upload_Readers-and-Writers:: ; \
  $(SCP) \
  Readers-and-Writers/index.html \
  Readers-and-Writers/Makefile \
  Readers-and-Writers/DB_read_write.sats \
  Readers-and-Writers/DB_read_write.dats \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/Readers-and-Writers/

######

upload_http-server:: ; \
  $(SCP) \
  http-server/index.html \
  http-server/Makefile \
  http-server/myserver.dats \
  http-server/myserver2.dats \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/http-server

######

upload_PwTP-bool-vs-prop:: ; \
  $(SCP) \
  PwTP-bool-vs-prop/index.html \
  PwTP-bool-vs-prop/Makefile \
  PwTP-bool-vs-prop/bool-vs-prop.dats \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/PwTP-bool-vs-prop

######

upload_linear-streams:: ; \
  $(SCP) \
  linear-streams/index.html \
  linear-streams/Makefile linear-streams/*.?ats \
  ats-hwxi,ats-lang@web.sourceforge.net:htdocs/EXAMPLE/EFFECTIVATS/linear-streams/

######

###### end of [Makefile] ######
