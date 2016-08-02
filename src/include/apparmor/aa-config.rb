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

    def displayNotifyForm
      settings = Convert.to_map(
        SCR.Execute(path(".apparmor"), "aa-notify-settings")
      )

      terse = Ops.get_map(settings, "terse", {})
      summary = Ops.get_map(settings, "summary", {})
      verbose = Ops.get_map(settings, "verbose", {})

      t_freq = Ops.get_integer(terse, "terse_freq", 0)
      s_freq = Ops.get_integer(summary, "summary_freq", 0)
      v_freq = Ops.get_integer(verbose, "verbose_freq", 0)

      t_unknown = true
      a_t_poop = Ops.get_string(terse, "terse_unknown", "1")
      t_poop = Builtins.tostring(a_t_poop)
      t_unknown = false if t_poop == "0"

      s_unknown = true
      a_s_poop = Ops.get_string(terse, "summary_unknown", "1")
      s_poop = Builtins.tostring(a_s_poop)
      s_unknown = false if s_poop == "0"

      v_unknown = true
      a_v_poop = Ops.get_string(verbose, "verbose_unknown", "1")
      v_poop = Builtins.tostring(a_v_poop)
      v_unknown = false if v_poop == "0"

      terse_items = [
        Item(Id(0), _("Disabled"), t_freq == 0 ? true : false),
        Item(Id(60), _("1 minute"), t_freq == 60 ? true : false),
        Item(Id(300), _("5 minutes"), t_freq == 300 ? true : false),
        Item(Id(600), _("10 minutes"), t_freq == 600 ? true : false),
        Item(Id(900), _("15 minutes"), t_freq == 900 ? true : false),
        Item(Id(1800), _("30 minutes"), t_freq == 1800 ? true : false),
        Item(Id(3600), _("1 hour"), t_freq == 3600 ? true : false),
        Item(Id(86400), _("1 day"), t_freq == 86400 ? true : false),
        Item(Id(604800), _("1 week"), t_freq == 604800 ? true : false)
      ]

      summary_items = [
        Item(Id(0), _("Disabled"), s_freq == 0 ? true : false),
        Item(Id(60), _("1 minute"), s_freq == 60 ? true : false),
        Item(Id(300), _("5 minutes"), s_freq == 300 ? true : false),
        Item(Id(600), _("10 minutes"), s_freq == 600 ? true : false),
        Item(Id(900), _("15 minutes"), s_freq == 900 ? true : false),
        Item(Id(1800), _("30 minutes"), s_freq == 1800 ? true : false),
        Item(Id(3600), _("1 hour"), s_freq == 3600 ? true : false),
        Item(Id(86400), _("1 day"), s_freq == 86400 ? true : false),
        Item(Id(604800), _("1 week"), s_freq == 604800 ? true : false)
      ]

      verbose_items = [
        Item(Id(0), _("Disabled"), v_freq == 0 ? true : false),
        Item(Id(60), _("1 minute"), v_freq == 60 ? true : false),
        Item(Id(300), _("5 minutes"), v_freq == 300 ? true : false),
        Item(Id(600), _("10 minutes"), v_freq == 600 ? true : false),
        Item(Id(900), _("15 minutes"), v_freq == 900 ? true : false),
        Item(Id(1800), _("30 minutes"), v_freq == 1800 ? true : false),
        Item(Id(3600), _("1 hour"), v_freq == 3600 ? true : false),
        Item(Id(86400), _("1 day"), v_freq == 86400 ? true : false),
        Item(Id(604800), _("1 week"), v_freq == 604800 ? true : false)
      ]


      event_config = HVCenter(
        VBox(
          Opt(:vstretch),
          Frame(
            _("Security Event Notification"),
            HBox(
              HSpacing(1),
              VBox(
                Opt(:vstretch),
                VSpacing(1),
                Frame(
                  _("Terse Notification"),
                  VBox(
                    Opt(:vstretch),
                    HBox(
                      ComboBox(Id(:terse_freq), _("Frequency"), terse_items),
                      TextEntry(
                        Id(:terse_email),
                        _("Email Address"),
                        Ops.get_string(terse, "terse_email", "")
                      ),
                      IntField(
                        Id(:terse_level),
                        _("Severity"),
                        0,
                        10,
                        Ops.get_integer(terse, "terse_level", 0)
                      )
                    ),
                    HBox(
                      CheckBox(
                        Id(:terse_unknown),
                        _("Include Unknown Severity Events"),
                        t_unknown
                      )
                    )
                  )
                ),
                VSpacing(1),
                Frame(
                  _("Summary Notification"),
                  VBox(
                    Opt(:vstretch),
                    HBox(
                      ComboBox(Id(:summary_freq), _("Frequency"), summary_items),
                      TextEntry(
                        Id(:summary_email),
                        _("Email Address"),
                        Ops.get_string(summary, "summary_email", "")
                      ),
                      IntField(
                        Id(:summary_level),
                        _("Severity"),
                        0,
                        10,
                        Ops.get_integer(summary, "summary_level", 0)
                      )
                    ),
                    HBox(
                      CheckBox(
                        Id(:summary_unknown),
                        _("Include Unknown Severity Events"),
                        s_unknown
                      )
                    )
                  )
                ),
                VSpacing(1),
                Frame(
                  _("Verbose Notification"),
                  VBox(
                    Opt(:vstretch),
                    HBox(
                      ComboBox(Id(:verbose_freq), _("Frequency"), verbose_items),
                      TextEntry(
                        Id(:verbose_email),
                        _("Email Address"),
                        Ops.get_string(verbose, "verbose_email", "")
                      ),
                      IntField(
                        Id(:verbose_level),
                        _("Severity"),
                        0,
                        10,
                        Ops.get_integer(verbose, "verbose_level", 0)
                      )
                    ),
                    HBox(
                      CheckBox(
                        Id(:verbose_unknown),
                        _("Include Unknown Severity Events"),
                        v_unknown
                      )
                    )
                  )
                ),
                VSpacing(1)
              ),
              HSpacing(1)
            )
          )
        )
      )

      Wizard.CreateDialog
      Wizard.SetContentsButtons(
        _("Security Event Notification"),
        event_config,
        Ops.get_string(@helps, "EventNotifyHelpText", ""),
        Label.BackButton,
        Label.OKButton
      )
      Wizard.DisableBackButton

      ntInput = nil
      notifyLabelValue = ""

      while true
        ntInput = UI.UserInput

        if ntInput == :next
          answers = {}
          set_notify = {}
          summary2 = {}
          verbose2 = {}
          terse2 = {}

          t_freq = UI.QueryWidget(Id(:terse_freq), :Value)
          s_freq = UI.QueryWidget(Id(:summary_freq), :Value)
          v_freq = UI.QueryWidget(Id(:verbose_freq), :Value)

          Ops.set(set_notify, "aa-set-notify", "yes")
          Ops.set(terse2, "terse_freq", Builtins.tostring(t_freq))
          Ops.set(summary2, "summary_freq", Builtins.tostring(s_freq))
          Ops.set(verbose2, "verbose_freq", Builtins.tostring(v_freq))

          if t_freq != 0
            t_email = Convert.to_string(
              UI.QueryWidget(Id(:terse_email), :Value)
            )

            if t_email == nil || t_email == ""
              Popup.Error(
                _(
                  "An email address is required for each selected notification method."
                )
              )
              next
            elsif !checkEmailAddress(t_email)
              next
            end

            Ops.set(terse2, "enable_terse", "yes")
            Ops.set(
              terse2,
              "terse_email",
              Convert.to_string(UI.QueryWidget(Id(:terse_email), :Value))
            )
            Ops.set(
              terse2,
              "terse_level",
              Builtins.tostring(UI.QueryWidget(Id(:terse_level), :Value))
            )

            t_unknown2 = Convert.to_boolean(
              UI.QueryWidget(Id(:terse_unknown), :Value)
            )

            if t_unknown2 == true
              Ops.set(terse2, "terse_unknown", "1")
            else
              Ops.set(terse2, "terse_unknown", "0")
            end
          else
            Ops.set(terse2, "enable_terse", "no")
          end

          if s_freq != 0
            s_email = Convert.to_string(
              UI.QueryWidget(Id(:summary_email), :Value)
            )
            if s_email == nil || s_email == ""
              Popup.Error(
                _(
                  "An email address is required for each selected notification method."
                )
              )
              next
            elsif !checkEmailAddress(s_email)
              next
            end

            Ops.set(summary2, "enable_summary", "yes")
            Ops.set(
              summary2,
              "summary_email",
              Convert.to_string(UI.QueryWidget(Id(:summary_email), :Value))
            )
            Ops.set(
              summary2,
              "summary_level",
              Builtins.tostring(UI.QueryWidget(Id(:summary_level), :Value))
            )

            s_unknown2 = Convert.to_boolean(
              UI.QueryWidget(Id(:summary_unknown), :Value)
            )

            if s_unknown2 == true
              Ops.set(summary2, "summary_unknown", "1")
            else
              Ops.set(summary2, "summary_unknown", "0")
            end
          else
            Ops.set(summary2, "enable_summary", "no")
          end

          if v_freq != 0
            v_email = Convert.to_string(
              UI.QueryWidget(Id(:verbose_email), :Value)
            )
            if v_email == nil || v_email == ""
              Popup.Error(
                _(
                  "An email address is required for each selected notification method."
                )
              )
              next
            elsif !checkEmailAddress(v_email)
              next
            end

            Ops.set(verbose2, "enable_verbose", "yes")
            Ops.set(
              verbose2,
              "verbose_email",
              Convert.to_string(UI.QueryWidget(Id(:verbose_email), :Value))
            )
            Ops.set(
              verbose2,
              "verbose_level",
              Builtins.tostring(UI.QueryWidget(Id(:verbose_level), :Value))
            )

            v_unknown2 = Convert.to_boolean(
              UI.QueryWidget(Id(:verbose_unknown), :Value)
            )

            if v_unknown2 == true
              Ops.set(verbose2, "verbose_unknown", "1")
            else
              Ops.set(verbose2, "verbose_unknown", "0")
            end
          else
            Ops.set(verbose2, "enable_verbose", "no")
          end

          Ops.set(answers, "set_notify", set_notify)
          Ops.set(answers, "terse", terse2)
          Ops.set(answers, "summary", summary2)
          Ops.set(answers, "verbose", verbose2)

          result = Convert.to_string(SCR.Execute(path(".aaconf"), answers))

          if result != "success"
            Popup.Error(
              Ops.add(
                _("Configuration failed for the following operations: "),
                result
              )
            )
          end

          if t_freq != 0 || s_freq != 0 || v_freq != 0
            notifyLabelValue = _("Notification is enabled")
          else
            notifyLabelValue = _("Notification is disabled")
          end
        end

        Wizard.CloseDialog
        if ntInput == :ok || ntInput == :next
          UI.ChangeWidget(Id(:notifyLabel), :Value, notifyLabelValue)
        end
        break
      end

      nil
    end

    def displayAppArmorConfig
      # AppArmor Status
      ntIsEnabled = false
      aaEnabled = Yast::Service.Enabled("apparmor")

      # Notification Status
      evnotify = Convert.to_string(SCR.Execute(path(".apparmor"), "aa-notify"))
      evEnStr = _("Notification is disabled")
      if evnotify == "enabled"
        ntIsEnabled = true
        evEnStr = _("Notification is enabled")
      elsif evnotify == "notinstalled"
        evnotify = "disabled"
      end

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
                    # event notification disabled due to changes in AppArmor
                    # `Frame ( _("Security Event Notification"),
                    # 					            `HBox(
                    # 						            `VSpacing(1), `HSpacing(1),
                    # 						            `HVCenter( `Label( `id(`notifyLabel),  evEnStr )),
                    # 						            `PushButton( `id(`ntconf), _("C&onfigure")),
                    # 						            `VSpacing(1), `HSpacing(1)
                    # 					            )
                    # 					        ),
                    # 					        `VSpacing(1), `HSpacing(20),
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
        elsif ret == :ntconf
          displayNotifyForm
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
