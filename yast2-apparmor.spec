#
# spec file for package yast2-apparmor (Version 2.1)
#
# Copyright (c) 2008 SUSE LINUX Products GmbH, Nuernberg, Germany.
# This file and all modifications and additions to the pristine
# package are under the same license as the package itself.
#
# Please submit bugfixes or comments via http://bugs.opensuse.org/
#

# norootforbuild

Name:           yast2-apparmor
Summary:        Yast2 plugins for AppArmor profile management
Version:        2.1
Release:        2.4
Group:          Productivity/Security
Source0:        %{name}-%{version}-977.tar.gz
License:        GPL v2 or later
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Url:            http://forge.novell.com/modules/xfmod/project/?apparmor
Requires:       yast2 perl-TimeDate
BuildArch:      noarch
Obsoletes:      yast2-subdomain
Provides:       yast2-subdomain
BuildRequires:  update-desktop-files
BuildRequires:  yast2 yast2-devtools
%if %{suse_version} > 1010 
BuildRequires:  yast2-theme-openSUSE
%define themedir /usr/share/YaST2/theme/openSUSE
%else
  %if %{suse_version} > 1000 
    %if 0%{?sles_version} > 9
BuildRequires:  yast2-theme-NLD
    %else
BuildRequires:  yast2-theme-SuSELinux
    %endif
  %endif
%define themedir /usr/share/YaST2/theme/SuSELinux
%endif

%description
Yast2 forms and components for the management of Novell AppArmor
profiles.

This package is part of a suite of tools that used to be named
SubDomain.



Authors:
--------
    ddrewelow@suse.de
    dreynolds@suse.de
    jmichael@suse.de

%prep
%setup -q

%build
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT
make DESTDIR=${RPM_BUILD_ROOT} DISTRO=%{distro}

%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT
make install DESTDIR=${RPM_BUILD_ROOT} DISTRO=%{distro} THEMEDIR=%{themedir}
# Register as SuSE app
for f in `find $RPM_BUILD_ROOT/%{_prefix}/share/applications/YaST2/ -name "*.desktop"` ; do
    d=${f##*/}
    if [ "%{suse_version}" -lt 930 ] ; then
    	%suse_update_desktop_file ${d%.desktop}
    else
    	%suse_update_desktop_file -d ycc_${d%.desktop} ${d%.desktop}
    fi
done
# make icons available to GNOME control center (hicolor theme)
# (bug #212500)
#mkdir -p ${RPM_BUILD_ROOT}/usr/share/icons/hicolor/22x22/apps
#mkdir -p ${RPM_BUILD_ROOT}/usr/share/icons/hicolor/32x32/apps
#mkdir -p ${RPM_BUILD_ROOT}/usr/share/icons/hicolor/48x48/apps
#cd $RPM_BUILD_ROOT/%{themedir}/icons
#for dir in 22x22 32x32 48x48; do
#    cd $RPM_BUILD_ROOT/%{themedir}/icons/${dir}/apps
#    icons=$(ls *.png)
#    cd $RPM_BUILD_ROOT/usr/share/icons/hicolor/${dir}/apps
#    for icon in ${icons}; do
#	ln -s %{themedir}/icons/${dir}/apps/${icon} .
#    done
#done

%clean 
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT

%files 
%defattr(-,root,root)
/usr/bin/*
/usr/share/YaST2/clients
/usr/share/YaST2/include/subdomain
/usr/share/YaST2/include/apparmor-reports
/usr/share/YaST2/scrconf
/usr/share/YaST2/modules
/usr/share/applications/YaST2
/usr/share/applications/YaST2/groups
/usr/lib/YaST2/servers_non_y2
/usr/lib/perl5/vendor_perl/*
#%{themedir}/icons
#/usr/share/icons/hicolor/
%doc COPYING.LGPL
%dir %attr(-,root,root) /etc/apparmor
#%if 0%{?suse_version} <= 1010
# needed on sles
#%dir /usr/share/YaST2/theme/SuSELinux
#%endif
%config(noreplace) /etc/apparmor/reports.crontab
%config(noreplace) /etc/apparmor/reports.conf

%post
REPDIR='/var/log/apparmor/reports'
REPDIR2='/var/log/apparmor/reports-archived'
REPDIR3='/var/log/apparmor/reports-exported'
[ -e $REPDIR ] || mkdir -p $REPDIR
[ -e $REPDIR2 ] || mkdir -p $REPDIR2
[ -e $REPDIR3 ] || mkdir -p $REPDIR3

%preun

%changelog
* Mon Jan 28 2008 - jjohansen@suse.de
- Disable installation of icon's that conflict with sles's yast2-theme-NLD package
* Sun Sep 16 2007 - dreynolds@suse.de
- Fixes (#310454) to support new audit log format and new libapparmor1 - ddrewelow@suse.de
- Bug #305735 Add support for network toggles, append, and locking  to the YaST2
  EditProfile wizard.
- Bug 302588 - 1 CD KDE version fails to install apparmor-docs
* Tue Aug 21 2007 - dreynolds@suse.de
- Updated spec to set theme-dir based on dist (openSUSE/sles)
* Mon Aug 20 2007 - dreynolds@suse.de
- sbeattie@suse.de
  Fix for #212500 "y2controlcenter-gnome does not find AppArmor
  icons" and its duplicate #297243 "Missing YaST icon: All app armor
  icons".
* Sun Jul 29 2007 - dreynolds@suse.de
- Numerous fixes for repository integration
* Mon Jul 16 2007 - dreynolds@suse.de
- Add support for the AppArmor profile repository
  Fate: 300517
* Fri Nov 17 2006 - ddrewelow@suse.de
- Fixed an untranslated string
* Fri Nov 17 2006 - ddrewelow@suse.de
- Fixed usability and reporting bugs
  (bnc# 158599,171082,172624,173825)
* Tue Nov 14 2006 - ddrewelow@suse.de
- Added the missing complain.scr to fix:
  https://bugzilla.novell.com/show_bug.cgi?id=219898
* Mon Nov 13 2006 - ddrewelow@suse.de
- Fixes for notification bugs:
  - configuration of e-mail recipient not saved in YaST
  (bnc#177039)
  - AppArmour - Security event Notification - email address fails
  (bnc#190891)
  - AppArmor unable to enter ANY notification email address
  (bnc#198359)
* Fri Nov 03 2006 - ddrewelow@suse.de
- Add complain/enforce profile state toggle
  Fate: 300719
* Mon Oct 16 2006 - dreynolds@suse.de
- Add syntax checks for profiles and display error dialogs to user
  Fate: 300906
* Mon Sep 18 2006 - aj@suse.de
- Adjust for theming change.
* Mon Jun 05 2006 - dreynolds@suse.de
- Fixes for https://bugzilla.novell.com/show_bug.cgi?id=175388,
  https://bugzilla.novell.com/show_bug.cgi?id=172061. Added support
  for new profile syntax Px/Ux/m.
* Sun Apr 02 2006 - dreynolds@suse.de
- Pickup fix for typo regression in profile_dialogs.ycp (thanks rudi)
- Remove libapparmor as a dependency for all yast wizards (#160518)
* Sun Apr 02 2006 - ro@suse.de
- fix typo in subdomain/profile_dialogs.ycp
* Mon Mar 27 2006 - jmichael@suse.de
- Split aaeventd startup into its own init script so we don't start
  daemons while in the "boot" runlevel (#158613)
- Fix broken notification help localization.
* Mon Mar 13 2006 - dreynolds@suse.de
- Don't check for event DB intialization when running the audit report.
  (#155343)
- Remove localized text in apparmor.desktop - as the desktop translation
  is handled by the translation group.
  https://bugzilla.novell.com/show_bug.cgi?id=151509
- Changes the checks from /etc/subdomain.d to /etc/apparmor.d when
  validated manual selection of #includes in the "Edit Profile" wizard.
  (#152813)
- Replace yast2-devel build-requires with yast2 yast2-devtools
* Tue Feb 14 2006 - dreynolds@suse.de
- Fixed typo in SD_EditProfie.ycp that was causing a syntax error in the wizard
* Sun Feb 12 2006 - dreynolds@suse.de
- Include counter (and time) in ag_genprof logmark
- (sbeattie@suse.de) Install apparmor packages if not already installed (#137585)
- (sbeattie@suse.de) Remove direct dependency on apparmor packages
* Sun Feb 05 2006 - sbeattie@suse.de
- Fix non-wrapping error-dialog (#146435)
- Enable/start aaeventd if notification is enabled
- (jmichael) Remove dead code
* Sat Jan 28 2006 - sbeattie@suse.de
- Add svn repo number to tarball name
- (dreynolds) Removed AALite checks
- (dreynolds) Fix regex warning
- (dreynolds) Fix apparmor control panel to correctly tell if AA is
  enabled/disabled (#145955)
- disable autoyast support in aa configs (#116749)
* Wed Jan 25 2006 - mls@suse.de
- converted neededforbuild to BuildRequires
* Mon Jan 23 2006 - dreynolds@suse.de
-  Added code to process events from the audit system in addition to syslog
* Mon Jan 16 2006 - dreynolds@suse.de
- Remove references to message catalog files - now provided by yast2-trans
* Thu Dec 08 2005 - sbeattie@suse.de
- fix gettext/textdomain() calls to refer to new messages filename
- fix references to old package names within .po files
* Thu Dec 08 2005 - sbeattie@suse.de
- rename package to yast2-apparmor
- relicense to GPL and LGPL for open source release
- reset version to 2.0-1
