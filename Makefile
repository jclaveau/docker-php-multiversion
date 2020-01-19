BIN ?= php
PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib

.PHONY: all
all:
	# make test
	make install

.PHONY: install
install:
	install -D stub/php $(BINDIR)/$(BIN)
	install -d $(LIBDIR)/$(BIN)
	cp -r php lib $(LIBDIR)/$(BIN)
	mkdir -p $(PREFIX)/share/bash-competion/completions/
	cp -r ./share $(PREFIX)/share

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

.PHONY: test
test:
	if [ ! -d 'shellspec' ]; then git clone https://github.com/shellspec/shellspec.git; fi
	./shellspec/shellspec --fail-fast

.PHONY: check
