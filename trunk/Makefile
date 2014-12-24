FONTFORGE:=/usr/bin/env fontforge
XGRIDFIT:=/usr/bin/env xgridfit
VERSION:=$(shell date +"%Y%m%d")
FAMILY=Istok
PKGNAME=istok
SFDFILES=$(FAMILY)-Regular.sfd $(FAMILY)-Italic.sfd $(FAMILY)-Bold.sfd $(FAMILY)-BoldItalic.sfd
DOCUMENTS=AUTHORS ChangeLog COPYING README TODO
#OTFFILES=$(FAMILY)-Regular.otf $(FAMILY)-Italic.otf $(FAMILY)-Bold.otf $(FAMILY)-BoldItalic.otf
TTFFILES=$(FAMILY)-Regular.ttf $(FAMILY)-Italic.ttf $(FAMILY)-Bold.ttf $(FAMILY)-BoldItalic.ttf
PFBFILES=$(FAMILY)-Regular.pfb $(FAMILY)-Italic.pfb $(FAMILY)-Bold.pfb $(FAMILY)-BoldItalic.pfb
#AFMFILES=$(FAMILY)-Regular.afm $(FAMILY)-Italic.afm $(FAMILY)-Bold.afm $(FAMILY)-BoldItalic.afm
XGRIDFITFLAGS=-p 25 -G no
FFSCRIPTS=generate.ff 
EXTRAFFSCRIPTS=make_dup_vertshift.ff new_glyph.ff add_anchor_ext.ff \
	add_anchor_y.ff add_anchor_med.ff anchors.ff combining.ff make_comb.ff \
	dub_glyph.ff spaces_dashes.ff case_sub.ff add_ipa.ff hflip_glyph.ff \
	make_dup_rot.ff add_accented.ff dub_glyph_ch.ff same_cyrext.ff \
	make_cap_accent.ff make_superscript.ff dub_aligned.ff same_kern.ff \
	make_kern.ff cop_kern_left.ff cop_kern_right.ff cop_kern_acc.ff \
	cop_kern.ff cop_kern_mult.ff copy_anchors_acc.ff sc_sub.ff tab_sub.ff \
	liga_sub.ff sub_onum.ff alt_sub.ff \
	make_kern_sc.ff same_kern_sc.ff
#DIFFFILES=$(FAMILY)-Regular.xgf.diff # $(FAMILY)-Italic.xgf.diff $(FAMILY)-Bold.xgf.diff $(FAMILY)-BoldItalic.xgf.diff
XGFFILES=skipautoinst.txt \
	upr_*.xgf $(FAMILY)-Regular.ed.xgf it_*.xgf $(FAMILY)-Italic.ed.xgf $(FAMILY)-Bold.xgf $(FAMILY)-BoldItalic.ed.xgf

INSTALL=install -m 644 -p
MKDIR=install -m 755 -d
TAR=tar --owner=root --group=root -cvf
TARPREFIX=tar --owner=root --group=root \
 --transform 's,^,$(PKGNAME)-$(VERSION)/,' --show-transformed-names -cvf
COMPRESS=xz -9
TTX=ttx
TEXENC=t1,t2a,t2b,t2c,ts1,ot1
#PYTHON=python -W all
PYTHON=fontforge -lang=py -script 

TEXPREFIX=./texmf
DESTDIR=
prefix=/usr
fontdir=$(prefix)/share/fonts/TTF
docdir=$(prefix)/doc/$(PKGNAME)

all: $(TTFFILES)

$(FAMILY)-Regular.gen.ttf: $(FAMILY)-Regular.sfd  $(FFSCRIPTS) $(EXTRAFFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Regular

$(FAMILY)-Regular.ttf: $(FAMILY)-Regular.py $(FAMILY)-Regular.gen.ttf
	$(FONTFORGE) -lang=py -script $(FAMILY)-Regular.py

$(FAMILY)-Italic.gen.ttf: $(FAMILY)-Italic.sfd $(FFSCRIPTS) $(EXTRAFFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Italic 

$(FAMILY)-Italic.ttf: $(FAMILY)-Italic.py $(FAMILY)-Italic.gen.ttf
	$(FONTFORGE) -lang=py -script $(FAMILY)-Italic.py

$(FAMILY)-Bold.gen.ttf: $(FAMILY)-Bold.sfd $(FFSCRIPTS) $(EXTRAFFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Bold 

$(FAMILY)-BoldItalic.gen.ttf: $(FAMILY)-BoldItalic.sfd $(FFSCRIPTS) $(EXTRAFFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-BoldItalic 

$(FAMILY)-BoldItalic.ttf: $(FAMILY)-BoldItalic.py $(FAMILY)-BoldItalic.gen.ttf
	$(FONTFORGE) -lang=py -script $(FAMILY)-BoldItalic.py

%.gen.ttf: %.sfd
	fontforge -lang=ff -script generate.ff $*

%.pdf: %.ttf
	fntsample -f $< -o $@

$(FAMILY)-Bold.ttf: $(FAMILY)-Bold.gen.ttf $(FAMILY)-Bold.py
	fontforge -lang=py -script  $(FAMILY)-Bold.py

$(FAMILY)-Bold.py: $(FAMILY)-Bold.xgf $(FAMILY)-Bold_acc.xgf upr_*.xgf
	$(XGRIDFIT) -m -p 25 -G no -i $(FAMILY)-Bold_.sfd -o $(FAMILY)-Bold.ttf \
	-O $(FAMILY)-Bold.py $(FAMILY)-Bold.xgf

%.ttf: %.py %.gen.ttf
	fontforge -lang=py -script $*.py

%.gen.ttx: %.gen.ttf 
	-rm $*.gen.ttx
	$(TTX) $*.gen.ttf

%.gen.xgf: %.gen.ttx
	-rm $*.xgf
	ttx2xgf $*.gen.ttx $*.gen.xgf
#	patch -l --no-backup-if-mismatch < $*.xgf.diff

%.tmp.xgf: %.ed.xgf upr_*.xgf it_*.xgf %_acc.xgf
	xmllint --xinclude $*.ed.xgf > $*.tmp.xgf

%.xml: %.gen.xgf %.tmp.xgf
	xgfmerge -o $@ $^

%.py: %.xml
	xgridfit -p 25 -G no -i $*.gen.ttf -o $*.ttf $<

$(FAMILY)-Regular_acc.xgf: $(FAMILY)-Regular_.sfd inst_acc.py
	$(PYTHON) inst_acc.py -c -s skipautoinst.txt -i $(FAMILY)-Regular_.sfd  -o $(FAMILY)-Regular_acc.xgf

$(FAMILY)-Bold_acc.xgf: $(FAMILY)-Bold_.sfd inst_acc.py
	$(PYTHON) inst_acc.py -c -s skipautoinst.txt -i $(FAMILY)-Bold_.sfd  -o $(FAMILY)-Bold_acc.xgf

$(FAMILY)-BoldItalic_acc.xgf: $(FAMILY)-BoldItalic.gen.ttf inst_acc.py
	$(PYTHON) inst_acc.py -c -s skipautoinst.txt -i $(FAMILY)-BoldItalic_.sfd  -o $(FAMILY)-BoldItalic_acc.xgf

%_acc.xgf: %.gen.ttf inst_acc.py
	$(PYTHON) inst_acc.py -s skipautoinst.txt -i $*_.sfd  -o $*_acc.xgf

.SECONDARY : *.py *.xml *.xgf *.ttx

tex-support: all
	$(MKDIR) $(TEXPREFIX)
	-rm -rf ./texmf/*
	TEXMFVAR=$(TEXPREFIX) autoinst --encoding=$(TEXENC) -typeface=$(PKGNAME) \
	-vendor=public --extra="--no-updmap" \
	--sanserif -target=$(TEXPREFIX) \
	$(TTFFILES)
	$(MKDIR) $(TEXPREFIX)/fonts/type42/public/$(PKGNAME) $(TEXPREFIX)/fonts/type1/public/$(PKGNAME)
	for i in $(TTFFILES) ; do \
	 BASE=`basename $${i} .ttf`; \
	 ttftotype42 $${i} $(TEXPREFIX)/fonts/type42/public/$(PKGNAME)/$${BASE}.t42; \
	done
	$(INSTALL) $(PFBFILES) $(TEXPREFIX)/fonts/type1/public/$(PKGNAME)
	$(MKDIR) $(TEXPREFIX)/fonts/enc/dvips/$(PKGNAME)
	mv $(TEXPREFIX)/tex/latex/$(PKGNAME)/$(FAMILY).sty $(TEXPREFIX)/tex/latex/$(PKGNAME)/$(PKGNAME).sty
	mv $(TEXPREFIX)/fonts/map/dvips/$(PKGNAME)/$(FAMILY).map $(TEXPREFIX)/fonts/map/dvips/$(PKGNAME)/$(PKGNAME).map
	$(MKDIR) $(TEXPREFIX)/dvips/$(PKGNAME)
	echo "p +$(PKGNAME).map" > $(TEXPREFIX)/dvips/$(PKGNAME)/config.$(PKGNAME)
	$(MKDIR) $(TEXPREFIX)/doc/fonts/$(PKGNAME)
	$(INSTALL) $(DOCUMENTS) $(TEXPREFIX)/fonts/map/dvips/$(PKGNAME)/$(PKGNAME).map $(TEXPREFIX)/doc/fonts/$(PKGNAME)/
	sed -i -e "s/\.ttf/\.pfb/g" $(TEXPREFIX)/fonts/map/dvips/$(PKGNAME)/$(PKGNAME).map

dist-src:
	$(TARPREFIX) $(PKGNAME)-src-$(VERSION).tar $(SFDFILES) Makefile $(FFSCRIPTS) $(DOCUMENTS)  $(XGFFILES) $(DIFFFILES)
	$(COMPRESS) $(PKGNAME)-src-$(VERSION).tar

dist-ttf: all
	$(TARPREFIX) $(PKGNAME)-ttf-$(VERSION).tar \
	$(TTFFILES) $(DOCUMENTS)
	$(COMPRESS) $(PKGNAME)-ttf-$(VERSION).tar

dist-zip: all
	zip -9 $(PKGNAME)-ttf-$(VERSION).zip \
	$(TTFFILES) $(DOCUMENTS)

dist: TEXPREFIX=./texmf
dist-tex: tex-support
	( cd ./texmf ;\
	$(TAR) ../$(PKGNAME)-tex-$(VERSION).tar \
	doc dvips fonts tex )
	$(COMPRESS) $(PKGNAME)-tex-$(VERSION).tar

dist: dist-src dist-ttf

update-version:
	sed -e "s/^Version: .*$$/Version: $(VERSION)/" -i $(SFDFILES) \
	-e 's/"Version [0-9\.]*"/"Version $(VERSION)"/' -i $(SFDFILES)

clean :
	rm *.gen.ttx *.gen.xgf *.tmp.xgf *.gen.ttf 

distclean :
	-rm $(OTFFILES) $(TTFFILES) $(PFBFILES) $(AFMFILES) $(FAMILY)-*_.sfd $(FAMILY)-*_acc.xgf

install:
	$(MKDIR) $(DESTDIR)$(fontdir)
	$(INSTALL) -p --mode=644 $(TTFFILES) $(DESTDIR)$(fontdir)/
	$(MKDIR) $(DESTDIR)$(docdir)
	$(INSTALL) -p --mode=644 $(DOCUMENTS) $(DESTDIR)$(docdir)/

%.pe-dist: %.xml
	$(XGRIDFIT) --processor=libxslt -p 25 -G no -l ff -i $*.gen.ttf -o $*.ttf -S pe/$* $*.xml

OFLDOCS=TODO OFL.txt OFL-FAQ.txt FontLog.txt
# Only copyright holder can do this
ofl-ttf: all
	$(MKDIR) OFL
	-ln ChangeLog OFL/
	-ln TODO OFL/
	for f in $(TTFFILES) ; do fontforge -script gen_ofl.ff $$f OFL/$$f ; done
	cat README ChangeLog >OFL/FontLog.txt

dist-ofl-ttf: ofl-ttf
	(cd OFL ;\
	$(TARPREFIX) ../$(PKGNAME)-ofl-ttf-$(VERSION).tar \
	$(TTFFILES) $(OFLDOCS) )
	$(COMPRESS) $(PKGNAME)-ofl-ttf-$(VERSION).tar

dist-ofl-zip:
	(cd OFL ;\
	zip -9 ../$(PKGNAME)-ofl-ttf-$(VERSION).zip \
	$(TTFFILES) $(OFLDOCS) )

full-dist: dist dist-tex dist-zip dist-ofl-ttf dist-ofl-zip
