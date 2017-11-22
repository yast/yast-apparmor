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
module Yast
  module ApparmorApparmorProfileCheckInclude
    def initialize_apparmor_apparmor_profile_check(include_target)

      Yast.import "Popup"
      textdomain "apparmor"
    end

    def checkProfileSyntax
      args = {}
      errmsg = "<ul>"
      syntax_ok = true

      Ops.set(args, "profile-syntax-check", "1")
      errors = Convert.convert(
        SCR.Execute(path(".apparmor"), "profile-syntax-check"),
        :from => "any",
        :to   => "list <string>"
      )
      Builtins.foreach(errors) do |error|
        syntax_ok = false
        errmsg = Ops.add(Ops.add(Ops.add(errmsg, "<li>"), error), "</li>")
      end
      errmsg = Ops.add(errmsg, "</ul>")
      if syntax_ok == false
        headline = _("Errors found in AppArmor profiles")
        errmsg = Ops.add(
          Ops.add(
            Ops.add(
              Ops.add(
                Ops.add(
                  Ops.add(
                    Ops.add(
                      _(
                        "<p>These problems must be corrected before AppArmor can be started or the profile management tools can be used.</p> "
                      ) + "<p>",
                      errmsg
                    ),
                    "</p>"
                  ),
                  _(
                    "<p>Find a description of the AppArmor profile syntax by running "
                  )
                ),
                "<code>man apparmor.d</code></p>"
              ),
              _(
                "<p>Comprehensive documentation about AppArmor is available in the Administration guide located in the directory: "
              )
            ),
            "</p>"
          ),
          "<code>/usr/share/doc/manual/suselinux-manual_LANGUAGE</code>. "
        )
        Popup.LongText(headline, RichText(errmsg), 55, 15)
      end
      syntax_ok
    end
  end
end
