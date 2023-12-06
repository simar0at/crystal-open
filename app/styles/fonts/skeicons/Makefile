skeicons.css skeicons.svg skeicons.ttf skeicons.woff: skeicons.json
	../svgs2ttf $<
	cp skeicons.css.tmpl skeicons.css
	./create_css.py $< >> skeicons.css
	mv skeicons.svg skeicons.ttf skeicons.woff fonts/
