# 	$Id: Makefile 4157 2005-03-29 23:02:21Z steve $
# ------------------------------------------------------------------
#
#    Copyright (C) 2002-2005 Novell/SUSE
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of version 2 of the GNU General Public 
#    License published by the Free Software Foundation.
#
# ------------------------------------------------------------------
all:

# As translations get added, they will automatically be included, unless
# the lang is explicitly added to DISABLED_LANGS; e.g. DISABLED_LANGS=en es

DISABLED_LANGS=

include ../../common/Make-po.rules

../../common/Make-po.rules:
	make -C ../.. common/Make.rules

# This definition has to come after the inclusion of Make.rules in order
# to override the definition of LOCALEDIR in it.
LOCALEDIR=/usr/share/locale
