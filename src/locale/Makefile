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

# As translations get added, add them to the LANGS variable to get
# made/installed.
LANGS=de_DE es_ES fr_FR hu_HU it_IT ja_JP nb_NO pt_BR pt_PT zh_CN zh_TW

include ../../common/Make-po.rules

../../common/Make-po.rules:
	make -C ../.. common/Make.rules

# This definition has to come after the inclusion of Make.rules in order
# to override the definition of LOCALEDIR in it.
LOCALEDIR=/usr/share/YaST2/locale
