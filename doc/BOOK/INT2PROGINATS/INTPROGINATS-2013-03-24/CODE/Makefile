#
# A simple Makefile
#

######

checkall::
checkall:: ; make -C CHAPTER_THMPRVING checkall
checkall:: ; make -C CHAPTER_VVTINTRO checkall
checkall:: ; make -C CHAPTER_ABSVTYPES checkall

######

cleanall:: ; rm -f *~
cleanall:: ; make -C CHAPTER_THMPRVING cleanall
cleanall:: ; make -C CHAPTER_VVTINTRO cleanall
cleanall:: ; make -C CHAPTER_ABSVTYPES cleanall

distclean:: cleanall

######

upload:: THMPRVING
upload:: VVTINTRO
upload:: ABSVTYPES

######

THMPRVING:
	scp -r CHAPTER_THMPRVING ats-hwxi,ats-lang@web.sourceforge.net:htdocs/DOCUMENT/INTPROGINATS/CODE

VVTINTRO:
	scp -r CHAPTER_VVTINTRO ats-hwxi,ats-lang@web.sourceforge.net:htdocs/DOCUMENT/INTPROGINATS/CODE

ABSVTYPES:
	scp -r CHAPTER_ABSVTYPES ats-hwxi,ats-lang@web.sourceforge.net:htdocs/DOCUMENT/INTPROGINATS/CODE

###### end of [Makefile]
