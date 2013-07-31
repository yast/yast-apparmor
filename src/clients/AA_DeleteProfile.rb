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
  class AADeleteProfileClient < Client
    def main
      Yast.import "UI"
      Yast.import "Wizard"
      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Sequencer"
      Yast.include self, "apparmor/apparmor_packages.rb"
      Yast.include self, "apparmor/apparmor_profile_check.rb"
      Yast.include self, "apparmor/profile_dialogs.rb"
      textdomain "yast2-apparmor"



      #
      # YEAH BABY RUN BABY RUN
      #
      @ret = nil

      # no command line support #269891
      if Ops.greater_than(Builtins.size(WFM.Args), 0)
        Yast.import "CommandLine"
        CommandLine.Init({}, WFM.Args)
        return deep_copy(@ret)
      end

      return deep_copy(@ret) if !installAppArmorPackages

      return true if !checkProfileSyntax

      @ret = MainSequence()
      deep_copy(@ret)
    end

    # Globalz

    def DeleteProfileConfirmation
      profilename = Ops.get_string(@Settings, "CURRENT_PROFILE", "")
      if Popup.YesNoHeadline(
          _("Delete profile confirmation"),
          Ops.add(
            Ops.add(
              _("Are you sure you want to delete the profile "),
              profilename
            ),
            _(
              " ?\nAfter this operation the AppArmor module will reload the profile set."
            )
          )
        )
        Builtins.y2milestone(Ops.add("Deleted ", profilename))
        result = SCR.Write(path(".apparmor_profiles.delete"), profilename)
        result2 = SCR.Write(path(".apparmor_profiles.reload"), "-")
      end
      :finish
    end

    def MainSequence
      #
      # Read the profiles from the SCR agent
      profiles = Convert.to_map(SCR.Read(path(".apparmor_profiles"), "all"))

      aliases = { "chooseprofile" => lambda do
        SelectProfileForm(
          profiles,
          _(
            "Make a selection from the listed profiles and press Next to delete the profile."
          ),
          _("Delete Profile - Choose profile to delete"),
          "apparmor/delete_profile"
        )
      end, "deleteprofile" => lambda(
      ) do
        DeleteProfileConfirmation()
      end }

      sequence = {
        "ws_start"      => "chooseprofile",
        "chooseprofile" => {
          :abort  => :abort,
          :next   => "deleteprofile",
          :finish => :next
        }
      }

      Wizard.CreateDialog
      Wizard.SetTitleIcon("apparmor_delete_profile")
      ret = Sequencer.Run(aliases, sequence)
      Wizard.CloseDialog
      @Settings = Builtins.remove(@Settings, "CURRENT_PROFILE")
      @Settings = Builtins.remove(@Settings, "PROFILE_MAP")
      deep_copy(ret)
    end
  end
end

Yast::AADeleteProfileClient.new.main
