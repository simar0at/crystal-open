export PATH := `pwd`/node-v10.17.0-linux-x64/bin/:$(PATH)
build: bundle.js

bundle.js:
	#wget https://nodejs.org/dist/v10.17.0/node-v10.17.0-linux-x64.tar.xz -O - | xz - -d| tar -x
	tar xf node-v10.17.0-linux-x64.tar.xz 
	export PATH=$(PATH) && npm install
	export PATH=$(PATH) && node ./node_modules/.bin/webpack --config webpack.prod.js --output-filename bundle.js --output-path .

install: bundle.js
	mkdir -p $(DESTDIR)/var/www/crystal
	cp -r bundle.js app/{index.html,config.js,favicon.ico,images,libs,locale,styles,texts} $(DESTDIR)/var/www/crystal/
	sed -i "s/@VERSION@/$(VERSION)/" $(DESTDIR)/var/www/crystal/index.html
	echo $(VERSION) > $(DESTDIR)/var/www/crystal/version.txt

