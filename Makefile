# ------------------------------------------------------------------
#
#    Copyright (C) 2002-2005 Novell/SUSE
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of version 2 of the GNU General Public 
#    License published by the Free Software Foundation.
#
# ------------------------------------------------------------------

#
# Makefile for YaST2 Plugins for SD
#
NAME=yast2-apparmor
all:
COMMONDIR=../../common/
THEMEDIR=
MODULES= src/modules/AppArmorDialogs.ybc
include common/Make.rules

COMMONDIR_EXISTS=$(strip $(shell [ -d ${COMMONDIR} ] && echo true))
ifeq ($(COMMONDIR_EXISTS), true)
common/Make.rules: $(COMMONDIR)/Make.rules
	ln -sf $(COMMONDIR) .
endif

SUBDIRS		= clients include scrconf desktop agents perl icons bin modules

.PHONY:	install
install: $(MODULES)
	mkdir -p ${DESTDIR}/usr/share/YaST2/clients
	mkdir -p ${DESTDIR}/usr/share/YaST2/include/subdomain
	mkdir -p ${DESTDIR}/usr/share/YaST2/scrconf
	mkdir -p ${DESTDIR}/usr/share/YaST2/modules
	mkdir -p ${DESTDIR}/usr/share/applications/YaST2
	mkdir -p ${DESTDIR}/usr/share/applications/YaST2/groups
	mkdir -p ${DESTDIR}/usr/lib/YaST2/servers_non_y2
	mkdir -p ${DESTDIR}/usr/lib/perl5/vendor_perl/Immunix
	mkdir -p ${DESTDIR}/${THEMEDIR}/icons/48x48/apps
	mkdir -p ${DESTDIR}/${THEMEDIR}/icons/32x32/apps
	mkdir -p ${DESTDIR}/${THEMEDIR}/icons/22x22/apps
	mkdir -p ${DESTDIR}/usr/bin
	mkdir -p ${DESTDIR}/etc/apparmor
	cp -a src/modules/* ${DESTDIR}/usr/share/YaST2/modules/
	cp -a src/clients/* ${DESTDIR}/usr/share/YaST2/clients/
	cp -a src/include/* ${DESTDIR}/usr/share/YaST2/include/
	cp -a src/scrconf/* ${DESTDIR}/usr/share/YaST2/scrconf/
	cp -a src/desktop/* ${DESTDIR}/usr/share/applications/YaST2/
	cp -a src/desktop/groups/* ${DESTDIR}/usr/share/applications/YaST2/groups/
	cp -a src/perl/* ${DESTDIR}/usr/lib/perl5/vendor_perl/Immunix
	cp -a src/icons/48x48/* ${DESTDIR}/${THEMEDIR}/icons/48x48/apps
	cp -a src/icons/32x32/* ${DESTDIR}/${THEMEDIR}/icons/32x32/apps
	cp -a src/icons/22x22/* ${DESTDIR}/${THEMEDIR}/icons/22x22/apps
	cp -a src/bin/* ${DESTDIR}/usr/bin
	cp -a src/apparmor/* ${DESTDIR}/etc/apparmor
	install -m 755 src/agents/* ${DESTDIR}/usr/lib/YaST2/servers_non_y2/

all: $(MODULES)
   	
src/modules/AppArmorDialogs.ybc:  src/modules/AppArmorDialogs.ycp
	ycpc -c src/modules/AppArmorDialogs.ycp

src/modules/AppArmorReports.ybc:  src/modules/AppArmorReports.ycp
	ycpc -c src/modules/AppArmorReports.ycp

.PHONY: clean
clean:
	rm -f $(TARBALL) ${NAME}-${VERSION}-*.tar.gz Make.rules
