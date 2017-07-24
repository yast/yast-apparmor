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
  module ApparmorConfigComplainInclude
    def initialize_apparmor_config_complain(include_target)
      Yast.import "UI"
      textdomain "yast2-apparmor"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "Wizard"

      @modeHelp = _(
        "<p><b>Profile Mode Configuration</b><br>This tool allows \nyou to set AppArmor profiles to either complain or enforce mode.</p>"
      ) +
        _(
          "<p><b>Complain mode</b> is a profile training state that logs application \n" +
            "activity. All the violations of the AppArmor profile rules are logged \n" +
            "(into <i>/var/log/audit/audit.log</i> file), but still permitted, so \n" +
            "that application's behavior is not restricted.</p>"
        ) +
        _(
          "<p>With the profile in <b>enforce mode</b>, application is protected by \n" +
            "AppArmor. The profile rules are enforced and their violation is logged,\n" +
            "but not permitted (e.g. an application cannot access files, unless it is\n" +
            "permitted to do so by the profile).</p>"
        )

      @showAll = false # Button for showing active or all profiles
    end

    def updateComplain(id, profile, mode, showAll)
      id = deep_copy(id)
      error = false
      profCmd = {}

      if id == :allEnforce || id == :allComplain
        Ops.set(profCmd, "all", "1")
      elsif profile != ""
        Ops.set(profCmd, "profile", profile)
      else
        Popup.Error(Ops.add(_("Could not recognize profile name: "), profile))
        return
      end

      if id == :toggle && mode != ""
        # Reverse modes for toggling
        if mode == "enforce"
          Ops.set(profCmd, "mode", "complain")
        elsif mode == "complain"
          Ops.set(profCmd, "mode", "enforce")
        else
          error = true
          Popup.Error(Ops.add(_("Could not recognize mode: "), mode))
        end
      elsif id != :toggle
        Ops.set(profCmd, "mode", mode)
      end

      if showAll == true
        Ops.set(profCmd, "showall", "1")
      else
        Ops.set(profCmd, "showall", "0")
      end

      SCR.Write(path(".complain"), profCmd)

      nil
    end

    def updateRecordList(showAll)
      _Settings = {}
      Ops.set(_Settings, "list", "1")

      if showAll == true
        Ops.set(_Settings, "showall", "1")
      else
        Ops.set(_Settings, "showall", "0")
      end

      @recList = []
      key = 1

      # restarts ag_complain agent if necessary
      db = nil
      while db == nil
        db = Convert.convert(
          SCR.Read(path(".complain"), _Settings),
          :from => "any",
          :to   => "list <map>"
        )
      end

      Builtins.foreach(db) do |record|
        @recList = Builtins.add(
          @recList,
          Item(Id(key), Ops.get(record, "name"), record["mode"])
        )
        key = Ops.add(key, 1)
      end

      nil
    end

    def getProfModeForm(showAll)
      allBtn = PushButton(Id(:showAll), _("Show All Profiles"))
      allText = _("Configure Mode for Active Profiles")

      if showAll && showAll == true
        allBtn = PushButton(Id(:showAct), _("Show Active Profiles"))
        allText = _("Configure Mode for All Profiles")
      end

      translation_mapping = {
        # translators: string is value in table for mode of apparmor
        "enforce"  => _("enforce"),
        "complain" => _("complain"),
      }

      recListTranslated = (@recList || []).map do |record|
        Item(record.params[0], record.params[1],
          translation_mapping[record.params[2]] || record.params[2])
      end

      modeForm = Frame(
        Id(:changeMode),
        allText,
        #`Frame( `id(`changeMode), _("Configure Profile Mode"),
        VBox(
          VSpacing(2),
          HBox(
            VSpacing(10),
            Table(
              Id(:table),
              Opt(:notify),
              Header(_("Profile Name"), _("Mode")),
              recListTranslated
            )
          ),
          VSpacing(0.5),
          HBox(
            allBtn,
            PushButton(Id(:toggle), _("Toggle Mode")),
            PushButton(Id(:allEnforce), _("Set All to Enforce")),
            PushButton(Id(:allComplain), _("Set All to Complain"))
          )
        )
      )

      deep_copy(modeForm)
    end

    def updateModeConfigForm(showAll)
      updateRecordList(showAll)
      newModeForm = getProfModeForm(showAll)

      deep_copy(newModeForm)
    end

    # Profile Mode Configuration -- Sets Complain and Enforce Behavior
    def profileModeConfigForm
      updateRecordList(@showAll)
      modeForm = getProfModeForm(@showAll)
      Wizard.CreateDialog
      Wizard.SetContentsButtons(
        _("Profile Mode Configuration"),
        modeForm,
        @modeHelp,
        Label.BackButton,
        _("&Done")
      )

      event = {}
      id = nil
      modified = false

      while true
        event = UI.WaitForEvent

        id = Ops.get(event, "ID") # We'll need this often - cache it
        profile = nil
        mode = nil

        if id == :abort || id == :cancel || id == :back
          break
        elsif id == :next
          ret = -1
          if modified
            ret = Convert.to_integer(
              SCR.Execute(
                path(".target.bash"),
                "/sbin/rcapparmor reload > /dev/null 2>&1"
              )
            )
          else
            Builtins.y2milestone(
              "No change to Apparmor profile modes - nothing to do."
            )
            break
          end
          if ret == 0
            Builtins.y2milestone("Apparmor profiles reloaded succesfully.")
          else
            Builtins.y2error(
              "Reloading Apparmor profiles failed with exit code %1",
              ret
            )
          end

          break
        elsif id == :showAll
          @showAll = true
          Wizard.SetContentsButtons(
            _("Configure Profile Mode"),
            updateModeConfigForm(@showAll),
            @modeHelp,
            Label.BackButton,
            _("&Done")
          )
          next
        elsif id == :showAct
          @showAll = false
          Wizard.SetContentsButtons(
            _("Configure Profile Mode"),
            updateModeConfigForm(@showAll),
            @modeHelp,
            Label.BackButton,
            _("&Done")
          )
          next
        elsif id == :toggle
          itemselected = Convert.to_integer(
            UI.QueryWidget(Id(:table), :CurrentItem)
          )
          profile = Ops.get_string(
            Convert.to_term(
              UI.QueryWidget(Id(:table), term(:Item, itemselected))
            ),
            1,
            ""
          )
          mode = ""
          Builtins.foreach(@recList) do |record|
            if record.params[1] == profile
              mode = record.params[2]
            end
          end

          updateComplain(id, profile, mode, @showAll)
          modified = true
          Wizard.SetContentsButtons(
            _("Configure Profile Mode"),
            updateModeConfigForm(@showAll),
            @modeHelp,
            Label.BackButton,
            _("&Done")
          )
          next
        elsif id == :allEnforce || id == :allComplain
          profile = ""

          if id == :allEnforce
            mode = "enforce"
          else
            mode = "complain"
          end

          updateComplain(id, profile, mode, @showAll)
          modified = true
          Wizard.SetContentsButtons(
            _("Configure Profile Mode"),
            updateModeConfigForm(@showAll),
            @modeHelp,
            Label.BackButton,
            _("&Done")
          )
          next
        elsif id == :table
          Popup.Message(_("Select an action to perform."))
        else
          Builtins.y2error("Unexpected return code: %1", id)
          break
        end
      end

      Wizard.CloseDialog # new
      Convert.to_symbol(id)
    end
  end
end
