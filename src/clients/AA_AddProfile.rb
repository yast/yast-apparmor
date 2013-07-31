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
  class AAAddProfileClient < Client
    def main
      Yast.import "UI"
      Yast.import "Wizard"
      Yast.import "Popup"
      Yast.import "Label"
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
      return deep_copy(@ret) if !checkProfileSyntax
      @ret = MainSequence()
      deep_copy(@ret)
    end

    # Globalz

    def CreateNewProfile
      selectfilename = ""
      while true
        selectfilename = UI.AskForExistingFile(
          "/",
          "",
          _("Select File to Generate a Profile for")
        )
        # Check for cancel in the file choose dialog
        return false if selectfilename == nil
        Ops.set(@Settings, "CURRENT_PROFILE", selectfilename)
        profile = Convert.to_boolean(
          SCR.Read(path(".apparmor_profiles.new"), selectfilename)
        )
        if profile == false &&
            Popup.YesNoHeadline(
              Ops.add(
                Ops.add(_("Profile for "), selectfilename),
                _(" already exists.")
              ),
              _("Would you like to open this profile in editing mode?")
            )
          return true
        end
        Ops.set(@Settings, "NEW_PROFILE", selectfilename)
        return true
      end

      nil
    end



    #
    # Setup and run the Wizard
    #
    def MainSequence
      profiles = nil
      aliases = { "showprofile" => lambda do
        DisplayProfileForm(
          Ops.get_string(@Settings, "CURRENT_PROFILE", ""),
          false
        )
      end, "showHat" => lambda(
      ) do
        DisplayProfileForm(Ops.get_string(@Settings, "CURRENT_HAT", ""), true)
      end }

      sequence = {
        "ws_start"    => "showprofile",
        "showprofile" => {
          :abort   => :abort,
          :next    => :finish,
          :showhat => "showHat",
          :finish  => :finish
        },
        "showHat"     => {
          :abort  => :abort,
          :next   => "showprofile",
          :finish => :next
        }
      }

      created_new_profile = CreateNewProfile()
      if created_new_profile == false
        Builtins.remove(@Settings, "NEW_PROFILE")
        Builtins.remove(@Settings, "CURRENT_PROFILE")
        return :abort
      end
      new_profile = Convert.to_map(
        SCR.Read(
          path(".apparmor_profiles"),
          Ops.get_string(@Settings, "CURRENT_PROFILE", "")
        )
      )
      Ops.set(@Settings, "PROFILE_MAP", new_profile)
      Wizard.CreateDialog
      Wizard.SetTitleIcon("apparmor_add_profile")
      ret = Sequencer.Run(aliases, sequence)
      Wizard.CloseDialog
      if ret == :abort
        profile_name = Ops.get_string(@Settings, "NEW_PROFILE", "")
        result = SCR.Write(path(".apparmor_profiles.delete"), profile_name)
      end
      @Settings = Builtins.remove(@Settings, "NEW_PROFILE")
      @Settings = Builtins.remove(@Settings, "CURRENT_PROFILE")
      deep_copy(ret)
    end
  end
end

Yast::AAAddProfileClient.new.main
