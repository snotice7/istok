VERSION:=$(shell date +"%Y%m%d")
FAMILY=Istok
PKGNAME=istok
SFDFILES=$(FAMILY)-Regular.sfd $(FAMILY)-Italic.sfd $(FAMILY)-Bold.sfd $(FAMILY)-BoldItalic.sfd
DOCUMENTS=AUTHORS ChangeLog COPYING README
#OTFFILES=$(FAMILY)-Regular.otf $(FAMILY)-Italic.otf $(FAMILY)-Bold.otf $(FAMILY)-BoldItalic.otf
TTFFILES=$(FAMILY)-Regular.ttf $(FAMILY)-Italic.ttf $(FAMILY)-Bold.ttf $(FAMILY)-BoldItalic.ttf
#PFBFILES=$(FAMILY)-Regular.pfb $(FAMILY)-Italic.pfb $(FAMILY)-Bold.pfb $(FAMILY)-BoldItalic.pfb
#AFMFILES=$(FAMILY)-Regular.afm $(FAMILY)-Italic.afm $(FAMILY)-Bold.afm $(FAMILY)-BoldItalic.afm
FFSCRIPTS=generate.ff make_dup_vertshift.pe new_glyph.ff add_anchor_ext.ff \
	add_anchor_y.ff add_anchor_med.ff anchors.ff combining.ff make_comb.ff \
	dub_glyph.pe spaces_dashes.ff case_sub.ff add_ipa.ff hflip_glyph.ff \
	make_dup_rot.ff add_accented.ff dub_glyph_ch.ff same_cyrext.ff \
	make_cap_accent.ff make_superscript.ff dub_aligned.ff same_kern.ff \
	make_kern.ff cop_kern_left.ff cop_kern_right.ff cop_kern_acc.ff \
	cop_kern.ff cop_kern_mult.ff copy_anchors_acc.ff sc_sub.ff tab_sub.ff \
	liga_sub.ff alt_sub.ff
#DIFFFILES=$(FAMILY)-Regular.xgf.diff # $(FAMILY)-Italic.xgf.diff $(FAMILY)-Bold.xgf.diff $(FAMILY)-BoldItalic.xgf.diff
XGFFILES=upr_*.xgf $(FAMILY)-Regular.ed.xgf # it_*.xgf $(FAMILY)-Italic.ed.xgf $(FAMILY)-Bold.ed.xgf $(FAMILY)-BoldItalic.ed.xgf
XGRIDFIT=xgridfit
COMPRESS=xz -9
TEXENC=t1,t2a

INSTALL=install
DESTDIR=
prefix=/usr
fontdir=$(prefix)/share/fonts/TTF
docdir=$(prefix)/doc/$(PKGNAME)

all: $(TTFFILES)

$(FAMILY)-Regular.gen.ttf: $(FAMILY)-Regular.sfd  $(FFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Regular

$(FAMILY)-Italic.gen.ttf: $(FAMILY)-Italic.sfd $(FFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Italic 

$(FAMILY)-Bold.gen.ttf: $(FAMILY)-Bold.sfd $(FFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-Bold 

$(FAMILY)-BoldItalic.gen.ttf: $(FAMILY)-BoldItalic.sfd $(FFSCRIPTS)
	fontforge -lang=ff -script generate.ff $(FAMILY)-BoldItalic 

%.pdf: %.ttf
	fntsample -f $< -o $@

# Temporarily. We don't want to change anything in autoinstructed following faces:
$(FAMILY)-Italic.ttf: $(FAMILY)-Italic.gen.ttf
	cp -p $(FAMILY)-Italic.gen.ttf $(FAMILY)-Italic.ttf

$(FAMILY)-Bold.ttf: $(FAMILY)-Bold.gen.ttf
	cp -p $(FAMILY)-Bold.gen.ttf $(FAMILY)-Bold.ttf

$(FAMILY)-BoldItalic.ttf: $(FAMILY)-BoldItalic.gen.ttf
	cp -p $(FAMILY)-BoldItalic.gen.ttf $(FAMILY)-BoldItalic.ttf

%.ttf: %.py %.gen.ttf
	fontforge -lang=py -script $*.py

%.gen.ttx: %.gen.ttf 
	-rm $*.gen.ttx
	ttx $*.gen.ttf

%.gen.xgf: %.gen.ttx
	-rm $*.xgf
	ttx2xgf $*.gen.ttx $*.gen.xgf
#	patch -l --no-backup-if-mismatch < $*.xgf.diff

%.tmp.xgf: %.ed.xgf upr_*.xgf
	xmllint --xinclude $*.ed.xgf > $*.tmp.xgf

%.xml: %.gen.xgf %.tmp.xgf
	xgfmerge -o $@ $^

%.py: %.xml
	xgridfit -p 25 -G no -i $*.gen.ttf -o $*.ttf $<

%.pe-dist:
	$(XGRIDFIT) -p 25 -G no -l ff -i $*.gen.ttf -o $*.ttf -S pe/$* $*.xml

.SECONDARY : *.py *.xml *.xgf *.ttx

tex-support: all
	mkdir -p texmf
	-rm -rf ./texmf/*
	mkdir -p texmf/fonts/truetype/public/$(PKGNAME)
	cp -a $(TTFFILES) texmf/fonts/truetype/public/$(PKGNAME)/
	TEXMFVAR=`pwd`/texmf autoinst --encoding=$(TEXENC) \
	--extra="--typeface=$(PKGNAME) --no-updmap  --vendor=public  --type42" \
	--sanserif \
	$(TTFFILES)
	mkdir -p texmf/fonts/enc/dvips/$(PKGNAME)
	mv texmf/fonts/enc/dvips/public/* texmf/fonts/enc/dvips/$(PKGNAME)/
	-rm -r texmf/fonts/enc/dvips/public
	mkdir -p texmf/tex/latex/$(PKGNAME)
	mkdir -p texmf/fonts/map/dvips/$(PKGNAME)
	mv *$(FAMILY)-TLF.fd texmf/tex/latex/$(PKGNAME)/
	mv $(FAMILY).sty texmf/tex/latex/$(PKGNAME)/$(PKGNAME).sty
	mv $(FAMILY).map texmf/fonts/map/dvips/$(PKGNAME)/$(PKGNAME).map
	mkdir -p texmf/dvips/$(PKGNAME)
	echo "p +$(PKGNAME).map" > texmf/dvips/$(PKGNAME)/config.$(PKGNAME)
	mkdir -p texmf/doc/fonts/$(PKGNAME)
	cp -p $(DOCUMENTS) texmf/doc/fonts/$(PKGNAME)/

dist-src:
	tar -cvf $(PKGNAME)-src-$(VERSION).tar $(SFDFILES) Makefile $(FFSCRIPTS) $(DOCUMENTS)  $(XGFFILES) $(DIFFFILES)
	$(COMPRESS) $(PKGNAME)-src-$(VERSION).tar

dist-ttf: all
	tar -cvf $(PKGNAME)-ttf-$(VERSION).tar \
	$(TTFFILES) $(DOCUMENTS)
	$(COMPRESS) $(PKGNAME)-ttf-$(VERSION).tar


dist-tex:
	( cd ./texmf ;\
	tar -cvf ../$(PKGNAME)-tex-$(VERSION).tar \
	doc dvips fonts tex )
	$(COMPRESS) $(PKGNAME)-tex-$(VERSION).tar

dist: dist-src dist-ttf

update-version:
	sed -e "s/^Version: .*$$/Version: $(VERSION)/" -i $(SFDFILES) \
	-e 's/"Version [0-9\.]*"/"Version $(VERSION)"/' -i $(SFDFILES)

clean :
	rm *.gen.ttx *.gen.xgf *.tmp.xgf *.gen.ttf 

distclean :
	-rm $(OTFFILES) $(TTFFILES) $(PFBFILES) $(AFMFILES) $(FAMILY)-*_.sfd

install:
	mkdir -p $(DESTDIR)$(fontdir)
	$(INSTALL) -p --mode=644 $(TTFFILES) $(DESTDIR)$(fontdir)/
	mkdir -p $(DESTDIR)$(docdir)
	$(INSTALL) -p --mode=644 $(DOCUMENTS) $(DESTDIR)$(docdir)/
