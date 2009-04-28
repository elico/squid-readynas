ROOT = /opt/squid
SQUID_VERSION = 2.7.STABLE6
PACKAGE_NAME = SquidCachingProxy
PACKAGE_SHORTNAME = SQUID
PACKAGE_VERSION = 2.7_2

FETCH = $(shell which wget)
PATCH = $(shell which patch)
PATCHES = $(shell cat patches/series-$(SQUID_VERSION))
DIST_FILE = squid-$(SQUID_VERSION).tar.gz
DIST_URL = http://www.squid-cache.org/Versions/v2/2.7/$(DIST_FILE)
SRC = build/sparc-linux
DST = addons_sdk/$(PACKAGE_SHORTNAME)/files/opt/squid
CONFIG_ARGS = \
	  --prefix=$(ROOT) \
	  --bindir=$(ROOT)/bin$(BITS) \
	  --sbindir=$(ROOT)/sbin$(BITS) \
	  --libexecdir=$(ROOT)/libexec$(BITS) \
	  --libdir=$(ROOT)/lib$(BITS) \
	  --datadir=$(ROOT)/share \
	  --sysconfdir=$(ROOT)/etc \
	  --sharedstatedir=$(ROOT)/var \
	  --localstatedir=/c/squid \
	  --includedir=$(ROOT)/include \
	  --infodir=$(ROOT)/info \
	  --mandir=$(ROOT)/man \
	  --with-maxfd=512 \
	  --with-large-files --enable-large-cache-files \
	  --disable-select --disable-poll --enable-epoll \
	  --enable-removal-policies=heap,lru \
	  --enable-storeio=null,ufs,coss,aufs \
	  --disable-wccp --disable-wccpv2 \
	  --disable-htcp --disable-cache-digests \
	  --disable-ident-lookups \
	  --disable-dependency-tracking \
	  --enable-cachemgr-hostname=localhost \
	  --build=sparc-linux

.PHONE: dist
dist: dist/$(PACKAGE_NAME)_$(PACKAGE_VERSION).bin

dist/$(PACKAGE_NAME)_$(PACKAGE_VERSION).bin: package
	cp addons_sdk/$(PACKAGE_SHORTNAME)/$(PACKAGE_NAME)_$(PACKAGE_VERSION).bin dist/

.PHONY: package
package: addons_sdk/$(PACKAGE_SHORTNAME)/$(PACKAGE_NAME)_$(PACKAGE_VERSION).bin

addons_sdk/$(PACKAGE_SHORTNAME)/$(PACKAGE_NAME)_$(PACKAGE_VERSION).bin: install
	cd addons_sdk/$(PACKAGE_SHORTNAME) && \
	../bin/build_addon

.PHONY: install
install: build
	mkdir -p $(DST)/sbin
	cp $(SRC)/src/squid $(DST)/sbin/
	mkdir -p $(DST)/libexec
	cp $(SRC)/src/unlinkd $(DST)/libexec/
	cp $(SRC)/src/logfile-daemon $(DST)/libexec/
	mkdir -p $(DST)/bin
	cp $(SRC)/tools/squidclient $(DST)/bin/
	mkdir -p $(DST)/etc
	cp $(SRC)/src/mime.conf.default $(DST)/etc/mime.conf
	cp $(SRC)/src/squid.conf.default $(DST)/etc/
	mkdir -p $(DST)/share/errors
	cp -R $(SRC)/errors/* $(DST)/share/errors/
	mkdir -p $(DST)/share/icons
	-rm -rf $(DST)/share/icons/*
	cp -R $(SRC)/icons/*.gif $(DST)/share/icons/
	cp $(SRC)/src/mib.txt $(DST)/share/
	chown -R root $(DST)

.PHONY: build
build: build/sparc-linux/src/squid

build/sparc-linux/src/squid: config
	export DEFAULT_LOG_PREFIX=/c/squid/logs & \
	export DEFAULT_SWAP_DIR=/c/squid/cache & \
	export DEFAULT_PID_FILE=/var/run/squid.pid & \
	cd build/sparc-linux/ && \
	make -e all

.PHONY: config
config: build/sparc-linux/config.status

build/sparc-linux/config.status: patch
	export DEFAULT_LOG_PREFIX=/c/squid/logs & \
	export DEFAULT_SWAP_DIR=/c/squid/cache & \
	export DEFAULT_PID_FILE=/var/run/squid.pid & \
	cd build/sparc-linux/ && \
	./configure $(CONFIG_ARGS)

.PHONY: patch
patch: build/patch

build/patch: squid-$(SQUID_VERSION)
	cd squid-$(SQUID_VERSION) && \
	for patchfile in $(PATCHES) ; do \
	    echo "* Patch: $${patchfile}"; \
	    $(PATCH) -p0 -l <../patches/$${patchfile}; \
	done
	cp -a squid-$(SQUID_VERSION) build/sparc-linux/
	touch build/patch

squid-$(SQUID_VERSION): $(DIST_FILE)
	tar -xzf $(DIST_FILE)
	mkdir -p build

$(DIST_FILE):
	$(FETCH) $(DIST_URL)

.PHONY: clean
clean: 
	-rm -rf squid-$(SQUID_VERSION)
	-rm -rf build/*
	-rm -rf $(DST)
	
	