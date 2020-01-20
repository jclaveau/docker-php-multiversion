BIN ?= php
PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib
SHELL:=/bin/bash

.PHONY: all
all:
	# make test
	make install

.PHONY: install
install:
	cp -v -f -r ./* $(PREFIX)/lib/php
	ln -v -f -s $(PREFIX)/lib/php/bin/php $(PREFIX)/bin/php
	ln -v -f -s $(PREFIX)/lib/php/share/bash-completion/completions/php.bash \
				$(PREFIX)/share/bash-completion/completions/php.bash

.PHONY: install-dev
install-dev:
	ln -v -f -s $(shell pwd)/bin/php $(PREFIX)/bin/php
	ln -v -f -s $(PREFIX)/share/bash-completion/completions/php.bash \
				$(shell pwd)/share/bash-completion/completions/php.bash

.PHONY: uninstall
uninstall:
	rm -rf $(LIBDIR)/$(BIN) $(BINDIR)/$(BIN)
	rm $(PREFIX)/share/bash-competion/completions/php.bash

# package:
	# contrib/make_package_json.sh > package.json

# demo:
	# ttyrec -e "ghostplay contrib/demo.sh"
	# seq2gif -l 5000 -h 32 -w 139 -p win -i ttyrecord -o docs/demo.gif
	# gifsicle -i docs/demo.gif -O3 -o docs/demo.gif

test:
	contrib/test.sh
