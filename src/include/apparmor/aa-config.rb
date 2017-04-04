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
  module ApparmorAaConfigInclude
    def initialize_apparmor_aa_config(include_target)
      Yast.import "UI"
      Yast.include include_target, "apparmor/config_complain.rb"
      Yast.include include_target, "apparmor/helps.rb"
      Yast.include include_target, "apparmor/apparmor_ycp_utils.rb"
      textdomain "yast2-apparmor"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"
      Yast.import "Service"
    end

    def changeAppArmorState(aaEnabled)
      success = true
      if aaEnabled == true
        success = Yast::Service.start("apparmor") && Yast::Service.enable("apparmor")
      else
        success = Yast::Service.stop("apparmor") && Yast::Service.disable("apparmor")
      end

      if !success
        Yast::Report.Error(_('Failed to change apparmor service. Please use journal (journalctl -n -u apparmor) to diagnose'))
        aaEnabled = !aaEnabled
      end

      aaEnabled
    end

    def displayAppArmorConfig
      # AppArmor Status
      aaEnabled = Yast::Service.Enabled("apparmor")

      # Network dialog caption
      caption = _("AppArmor Configuration")
      help = _(
        "<p><b>AppArmor Status</b><br>This reports whether the AppArmor policy enforcement \nmodule is loaded and functioning.</p>"
      ) +
        _(
          "<p><b>Security Event Notification</b><br>Configure this tool if you want \nto be notified by email when access violations have occurred.</p>"
        ) +
        _(
          "<p><b>Profile Modes</b><br>Use this tool to change the way that AppArmor \nuses individual profiles.</p>"
        )

      contents = HVCenter(
        VBox(
          VSpacing(1),
          HSpacing(2),
          HBox(
            HSpacing(Opt(:hstretch), 2),
            VBox(
              Left(
                CheckBox(
                  Id(:aaState),
                  Opt(:notify),
                  _("&Enable AppArmor"),
                  aaEnabled
                )
              ),
              VSpacing(1),
              Frame(
                Id(:aaEnableFrame),
                _("Configure AppArmor"),
                HBox(
                  HSpacing(Opt(:hstretch), 4),
                  VBox(
                    VSpacing(1),
                    Frame(
                      _("Configure Profile Modes"),
                      HBox(
                        VSpacing(1),
                        HSpacing(1),
                        Left(
                          HVCenter(
                            Label(Id(:modesLabel), " " + _("Set profile modes"))
                          )
                        ),
                        PushButton(Id(:modeconf), _("Co&nfigure")),
                        VSpacing(1),
                        HSpacing(1)
                      )
                    ),
                    VSpacing(1)
                  ),
                  HSpacing(Opt(:hstretch), 4)
                )
              )
            ),
            HSpacing(Opt(:hstretch), 2)
          )
        )
      )

      # May want to replace Wizard() with UI()
      Wizard.CreateDialog
      Wizard.SetTitleIcon("apparmor/control_panel")
      Wizard.SetContentsButtons(
        caption,
        contents,
        help,
        Label.BackButton,
        _("&Done")
      )
      Wizard.DisableBackButton

      UI.ChangeWidget(Id(:aaEnableFrame), :Enabled, aaEnabled)

      while true
        ret = Convert.to_symbol(UI.UserInput)

        if ret == :abort || ret == :cancel || ret == :next
          break
        elsif ret == :aaState
          # Set AppArmor state: enabled|disabled
          requestedAaState = Convert.to_boolean(
            UI.QueryWidget(Id(:aaState), :Value)
          )

          aaEnabled = changeAppArmorState(requestedAaState)

          # These will match if the update was successful
          if aaEnabled == requestedAaState
            UI.ChangeWidget(Id(:aaEnableFrame), :Enabled, aaEnabled)
          end
        elsif ret == :modeconf
          profileModeConfigForm 

          #displayAppArmorConfig();
        else
          Builtins.y2error(
            Ops.add("Unexpected return code: ", Builtins.tostring(ret))
          )
        end
      end

      UI.CloseDialog
      nil
    end
  end
end
