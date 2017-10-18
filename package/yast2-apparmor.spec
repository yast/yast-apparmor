#
# spec file for package yast2-apparmor
#
# Copyright (c) 2014 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-apparmor
Version:        3.3.2
Release:        0
Summary:        YaST2 - Plugins for AppArmor Profile Management
Url:            https://github.com/yast/yast-apparmor
License:        GPL-2.0
Group:          Productivity/Security
Source0:        %{name}-%{version}.tar.bz2
BuildRequires:  update-desktop-files
BuildRequires:  yast2
BuildRequires:  yast2-devtools >= 3.1.10
Requires:       yast2
Requires:       yast2-ruby-bindings >= 1.0.0
Obsoletes:      yast2-subdomain
Provides:       yast2-subdomain

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
BuildArch:      noarch

%description
Yast2 forms and components for the management of Novell AppArmor
profiles.

This package is part of a suite of tools that used to be named
SubDomain.

%prep
%setup -q

%build
%yast_build

%install
%yast_install


%files
%defattr(-,root,root)
%{yast_clientdir}
%{yast_yncludedir}/apparmor
%{yast_libdir}/apparmor
%{yast_moduledir}
%{yast_desktopdir}
%doc %{yast_docdir}

