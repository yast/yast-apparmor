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
  class ApparmorSettingsClient < Client
    def main
      Yast.import "UI"

      textdomain "yast2-apparmor"

      # The main ()
      Builtins.y2milestone("----------------------------------------")
      Builtins.y2milestone("AppArmor module started")

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"

      Yast.include self, "apparmor/apparmor_packages.rb"
      Yast.include self, "apparmor/aa-config.rb"

      # no command line support #269891
      if Ops.greater_than(Builtins.size(WFM.Args), 0)
        Yast.import "CommandLine"
        CommandLine.Init({}, WFM.Args)
        return
      end

      return if !installAppArmorPackages

      @config_steps = [
        { "id" => "apparmor", "label" => _("Enable AppArmor Functions") }
      ]

      @steps = Builtins.flatten([@config_steps])

      @current_step = 0
      @button = displayPage(@current_step)

      # Finish
      Builtins.y2milestone("AppArmor module finished")
      Builtins.y2milestone("----------------------------------------") 

      # EOF

      nil
    end

    def displayPage(no)
      current_id = Ops.get_string(Ops.get(@steps, no), "id", "")
      button = nil

      UI.WizardCommand(term(:SetCurrentStep, current_id))

      if current_id == "apparmor"
        #button = displayAppArmorConfig();
        button = displayAppArmorConfig
      end



      button
    end
  end
end

Yast::ApparmorSettingsClient.new.main
