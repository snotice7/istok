VERSION:=$(shell date +"%Y%m%d")
FAMILY=Istok
PACKNAME=istok
SFDFILES=$(FAMILY)-Regular.sfd $(FAMILY)-Italic.sfd $(FAMILY)-Bold.sfd #$(FAMILY)-BoldItalic.sfd
DOCUMENTS=AUTHORS ChangeLog COPYING README
#OTFFILES=$(FAMILY)-Regular.otf $(FAMILY)-Italic.otf $(FAMILY)-Bold.otf $(FAMILY)-BoldItalic.otf
TTFFILES=$(FAMILY)-Regular.ttf $(FAMILY)-Italic.ttf $(FAMILY)-Bold.ttf #$(FAMILY)-BoldItalic.ttf
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

%.ttf: %.pe %.gen.ttf
	fontforge -lang=ff -script $*.pe

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

%.pe: %.xml
	xgridfit -p 25 -G no -i $*.gen.ttf -o $*.ttf $<

%.pe-dist:
	$(XGRIDFIT) -p 25 -G no -i $*.gen.ttf -o $*.ttf -S pe/$* $*.xml

.SECONDARY : *.pe *.xml *.xgf *.ttx


dist-src:
	tar -cvf $(PACKNAME)-src-$(VERSION).tar $(SFDFILES) Makefile $(FFSCRIPTS) $(DOCUMENTS)  $(XGFFILES) $(DIFFFILES)
	xz -9 $(PACKNAME)-src-$(VERSION).tar

dist-ttf: all
	tar -cvf $(PACKNAME)-ttf-$(VERSION).tar \
	$(TTFFILES) $(DOCUMENTS)
	xz -9 $(PACKNAME)-ttf-$(VERSION).tar

dist: dist-src dist-ttf

update-version:
	sed -e "s/^Version: .*$$/Version: $(VERSION)/" -i $(SFDFILES) \
	-e 's/"Version [0-9\.]*"/"Version $(VERSION)"/' -i $(SFDFILES)
