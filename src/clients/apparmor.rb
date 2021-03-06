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
  class ApparmorClient < Client
    def main
      Yast.import "UI"
      textdomain "apparmor"
      Yast.import "Wizard"
      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Sequencer"
      Yast.include self, "apparmor/apparmor_packages.rb"

      @ret = nil
      # no command line support #269891
      if Ops.greater_than(Builtins.size(WFM.Args), 0)
        Yast.import "CommandLine"
        CommandLine.Init({}, WFM.Args)
        return deep_copy(@ret)
      end

      return unless installAppArmorPackages
      @ret = startDialog
      deep_copy(@ret)
    end

    def startDialog
      # AppArmor dialog caption
      caption = _("AppArmor Configuration")

      # AppArmor dialog help
      help = _(
        "<p>Choose one of the available AppArmor modules to configure\n the corresponding action and press <b>Launch</b>.</p>\n"
      )

      # AppArmor dialog contents
      contents = HBox(
        HSpacing(8),
        # Frame label
        #`Frame(_("Available apparmor modules:"), `HBox(`HSpacing(2),
        VBox(
          VSpacing(3),
          # Selection box label
          SelectionBox(
            Id(:modules),
            Opt(:notify),
            _("&Available AppArmor Modules:"), #,
            [
              # Selection box items
              Item(Id("aa-settings"), _("Settings"), true),
	      Item(Id("aa-logprof"), _("Scan Audit logs")),
              Item(Id("aa-genprof"), _("Manually Add Profile"))
            ]
          ),
          VSpacing(3)
        ),
        #`HSpacing(2))),
        HSpacing(8)
      )

      Wizard.CreateDialog
      Wizard.SetDesktopTitleAndIcon("org.opensuse.yast.Apparmor")
      Wizard.SetContentsButtons(
        caption,
        contents,
        help,
        Label.BackButton, # Label::FinishButton()
        _("&Launch")
      )

      UI.SetFocus(Id(:modules))

      ret = nil
      while true
        event = UI.WaitForEvent
        ret = event["ID"]
        Builtins.y2milestone("Input event: %1", event)

        # abort?
        if ret == :abort || ret == :cancel
          break
        # next or selecting an item,
        # differ between changing the current item and activating it
        elsif ret == :next || (ret == :modules && event["EventReason"] == "Activated")
          # check_*
          ret = :next
          break
        # back
        elsif ret == :back
          break
        elsif ret != :modules
          Builtins.y2error("unexpected retcode: %1", ret)
        end
      end

      launch = "apparmor"
      if ret == :next
        launch = Convert.to_string(UI.QueryWidget(Id(:modules), :CurrentItem))
        Builtins.y2debug("launch=%1", launch)
      end

      if ret == :next
        ret = WFM.CallFunction(launch, WFM.Args)
      else
        ret = :back
      end

      UI.CloseDialog
      deep_copy(ret)
    end
  end
end

Yast::ApparmorClient.new.main
