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

include Make.rules

COMMONDIR_EXISTS=$(strip $(shell [ -d ${COMMONDIR} ] && echo true))
ifeq ($(COMMONDIR_EXISTS), true)
Make.rules: $(COMMONDIR)/Make.rules src/locale/Make.rules src/po/Make.rules
	ln -f $(COMMONDIR)/Make.rules .

src/po/Make.rules: $(COMMONDIR)/Make-po.rules
	make -C src/po Make.rules

src/locale/Make.rules: $(COMMONDIR)/Make-po.rules
	make -C src/locale Make.rules

endif

SUBDIRS		= clients include scrconf desktop agents perl icons bin 

.PHONY:	install
install:
	mkdir -p ${DESTDIR}/usr/share/YaST2/clients
	mkdir -p ${DESTDIR}/usr/share/YaST2/include/subdomain
	mkdir -p ${DESTDIR}/usr/share/YaST2/scrconf
	mkdir -p ${DESTDIR}/usr/share/applications/YaST2
	mkdir -p ${DESTDIR}/usr/share/applications/YaST2/groups
	mkdir -p ${DESTDIR}/usr/lib/YaST2/servers_non_y2
	mkdir -p ${DESTDIR}/usr/lib/perl5/vendor_perl/Immunix
	mkdir -p ${DESTDIR}/${THEMEDIR}/icons/48x48/apps/apparmor
	mkdir -p ${DESTDIR}/${THEMEDIR}/icons/32x32/apps/apparmor
	mkdir -p ${DESTDIR}/${THEMEDIR}/icons/22x22/apps/apparmor
	mkdir -p ${DESTDIR}/usr/bin
	mkdir -p ${DESTDIR}/etc/apparmor
	cp -a src/clients/* ${DESTDIR}/usr/share/YaST2/clients/
	cp -a src/include/* ${DESTDIR}/usr/share/YaST2/include/
	cp -a src/scrconf/* ${DESTDIR}/usr/share/YaST2/scrconf/
	cp -a src/desktop/* ${DESTDIR}/usr/share/applications/YaST2/
	cp -a src/desktop/groups/* ${DESTDIR}/usr/share/applications/YaST2/groups/
	cp -a src/perl/* ${DESTDIR}/usr/lib/perl5/vendor_perl/Immunix
	cp -a src/icons/48x48/* ${DESTDIR}/${THEMEDIR}/icons/48x48/apps/apparmor
	cp -a src/icons/32x32/* ${DESTDIR}/${THEMEDIR}/icons/32x32/apps/apparmor
	cp -a src/icons/22x22/* ${DESTDIR}/${THEMEDIR}/icons/22x22/apps/apparmor
	cp -a src/bin/* ${DESTDIR}/usr/bin
	cp -a src/apparmor/* ${DESTDIR}/etc/apparmor
	install -m 755 src/agents/* ${DESTDIR}/usr/lib/YaST2/servers_non_y2/
	

.PHONY: clean
clean:
	rm -f $(TARBALL) ${NAME}-${VERSION}-*.tar.gz
