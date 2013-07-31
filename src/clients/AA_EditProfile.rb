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
  class AAEditProfileClient < Client
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

      # Globalz

      @profiles = nil



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

    def Reread
      @profiles = Convert.to_map(SCR.Read(path(".apparmor_profiles"), "all"))
      :next
    end


    def MainSequence
      #
      # Read the profiles from the SCR agent
      Reread()

      aliases = {
        "showProfile"   => lambda do
          DisplayProfileForm(
            Ops.get_string(@Settings, "CURRENT_PROFILE", ""),
            false
          )
        end,
        "showHat"       => lambda do
          DisplayProfileForm(Ops.get_string(@Settings, "CURRENT_HAT", ""), true)
        end,
        "chooseProfile" => lambda do
          SelectProfileForm(
            @profiles,
            _("Select a listed profile and press Next to edit it."),
            _("Edit Profile - Choose profile to edit"),
            "apparmor_edit_profile"
          )
        end,
        "reread"        => lambda { Reread() }
      }

      sequence = {
        "ws_start"      => "chooseProfile",
        "chooseProfile" => {
          :abort  => :abort,
          :edit   => "showProfile",
          :reread => "reread",
          :next   => :next
        },
        "showProfile"   => {
          :abort   => :abort,
          :next    => "reread",
          :showhat => "showHat",
          :finish  => :next
        },
        "reread"        => { :next => "chooseProfile" },
        "showHat"       => {
          :abort  => :abort,
          :next   => "showProfile",
          :finish => :next
        }
      }

      Wizard.CreateDialog
      Wizard.SetTitleIcon("apparmor_edit_profile")
      ret = Sequencer.Run(aliases, sequence)
      Wizard.CloseDialog
      @Settings = Builtins.remove(@Settings, "CURRENT_PROFILE")
      @Settings = Builtins.remove(@Settings, "PROFILE_MAP")
      deep_copy(ret)
    end
  end
end

Yast::AAEditProfileClient.new.main
