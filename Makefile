BIN ?= php
PREFIX ?= /usr/local
BINDIR := $(PREFIX)/bin
LIBDIR := $(PREFIX)/lib

.PHONY: all
all:
	make test
	make install
	make check

.PHONY: install
install:
	install -d $(LIBDIR)/$(BIN)
	cp -r php lib $(LIBDIR)/$(BIN)
	install -D stub/php $(BINDIR)/$(BIN)

.PHONY: uninstall
uninstall:
	rm -rf $(LIBDIR)/$(BIN) $(BINDIR)/$(BIN)

# package:
	# contrib/make_package_json.sh > package.json

# demo:
	# ttyrec -e "ghostplay contrib/demo.sh"
	# seq2gif -l 5000 -h 32 -w 139 -p win -i ttyrecord -o docs/demo.gif
	# gifsicle -i docs/demo.gif -O3 -o docs/demo.gif

.PHONY: test
test:
	if [ ! -d 'shellspec' ]; then git clone https://github.com/shellspec/shellspec.git; fi
	./shellspec/shellspec

.PHONY: check
check:
	# CHECKING PHP 5.6
	php 5.6 -v
	# CHECKING PHP 7.4
	php 7.4 -v
	# EVERYTHING IS GOOD!
