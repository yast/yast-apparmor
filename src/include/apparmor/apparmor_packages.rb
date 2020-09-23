# encoding: utf-8

# ***************************************************************************
#
# Copyright (c) 2002 - 2012 Novell, Inc.
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, contact Novell, Inc.
#
# To contact Novell about this file by physical or electronic mail,
# you may find current contact information at www.novell.com
#
# ***************************************************************************

# This should probably be more intelligent and query the user once
# whether they want optional packages like apparmor-docs, libapparmor,
# apache2-mod-apparmor and * (eventually) pam-apparmor installed.
module Yast
  module ApparmorApparmorPackagesInclude
    def initialize_apparmor_apparmor_packages(include_target)
      Yast.import "PackageSystem"

      @__needed_packages = [
        "apparmor-parser",
        "apparmor-utils",
        "apparmor-profiles"
      ]
    end

    def installAppArmorPackages
      PackageSystem.CheckAndInstallPackagesInteractive(@__needed_packages)
    end
  end
end
