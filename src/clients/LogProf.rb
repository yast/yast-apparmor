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
  class LogProfClient < Client
    def main
      Yast.import "UI"
      Yast.import "Label"
      Yast.import "Wizard"
      Yast.import "Popup"
      Yast.import "Sequencer"
      Yast.include self, "apparmor/apparmor_packages.rb"
      Yast.include self, "apparmor/apparmor_profile_check.rb"
      Yast.include self, "apparmor/apparmor_ycp_utils.rb"
      Yast.include self, "apparmor/helps.rb"
      textdomain "yast2-apparmor"

      @done = false
      @type = ""
      @status = ""

      # no command line support #269891
      if Ops.greater_than(Builtins.size(WFM.Args), 0)
        Yast.import "CommandLine"
        CommandLine.Init({}, WFM.Args)
        return
      end

      return if !installAppArmorPackages
      return if !checkProfileSyntax

      # initiate the handshake with the backend agent
      @agent_data = Convert.to_map(SCR.Read(path(".logprof")))

      # is the backend just starting up?
      @type = Ops.get_string(@agent_data, "type", "handshake_error")
      @status = Ops.get_string(@agent_data, "status", "handshake_error")
      if @type != "initial_handshake" || @status != "backend_starting"
        Popup.Error(_("Synchronization error between frontend and backend."))
        @done = true
        return
      end

      # tell the backend tht we're just starting also...
      Ops.set(@agent_data, "status", "frontend_starting")
      SCR.Write(path(".logprof"), @agent_data)

      # open up the initial form window...
      Wizard.CreateDialog
      begin
        @agent_data = Convert.to_map(SCR.Read(path(".logprof")))

        @type2 = Ops.get_string(@agent_data, "type", "error")
        if @type2 == "initial_handshake"
          Popup.Error(_("Synchronization error between frontend and backend."))
          @done = true
          return
        end

        if @type2 == "wizard"
          @command = "CMD_ABORT"

          @title = Ops.get_locale(
            @agent_data,
            "title",
            _("AppArmor Profile Wizard")
          )
          @helptext = Ops.get_string(
            @agent_data,
            "helptext",
            Ops.get_string(@helps, "profileWizard", "")
          )
          @headers = Ops.get_list(@agent_data, "headers", [])
          @options = Ops.get_list(@agent_data, "options", [])
          @functions = Convert.convert(
            Ops.get(@agent_data, "functions") { ["CMD_ABORT"] },
            :from => "any",
            :to   => "list <string>"
          )
          @explanation = Ops.get_string(@agent_data, "explanation", "")
          @default_button = Ops.get_string(@agent_data, "default", "NO_DEFAULT")
          @selected = Ops.get_integer(@agent_data, "selected", 0)

          @idx = 0

          # build up the list of headers
          @ui_headers = VBox(VSpacing(0.5))
          while Ops.less_than(@idx, Builtins.size(@headers))
            @field = Ops.get(@headers, @idx, "MISSING FIELD")
            @value = Builtins.tostring(
              Ops.get(@headers, Ops.add(@idx, 1), "MISSING VALUE")
            )
            @ui_headers = Builtins.add(
              @ui_headers,
              Left(
                HBox(Heading(@field), HSpacing(0.5), HWeight(75, Label(@value)))
              )
            )
            @idx = Ops.add(@idx, 2)
          end
          @ui_headers = Builtins.add(@ui_headers, VSpacing(0.5))

          # build up the option list if we have one
          @idx = 0
          @ui_options = VBox(VSpacing(0.5))
          Builtins.foreach(@options) do |option|
            @ui_options = Builtins.add(
              @ui_options,
              Left(RadioButton(Id(@idx), option))
            )
            @idx = Ops.add(@idx, 1)
          end
          @ui_options = Builtins.add(@ui_options, VSpacing(0.5))

          # build up the set of buttons for the different actions we support
          @ui_functions = HBox(HSpacing(Opt(:hstretch), 0.1))
          Builtins.foreach(@functions) do |function|
            if function != "CMD_ABORT" && function != "CMD_FINISHED"
              buttontext = Ops.get_string(
                @CMDS,
                function,
                "MISSING BUTTON TEXT"
              )
              @ui_functions = Builtins.add(
                @ui_functions,
                HCenter(PushButton(Id(function), buttontext))
              )
            end
          end
          @ui_functions = Builtins.add(
            @ui_functions,
            HSpacing(Opt(:hstretch), 0.1)
          )

          # throw it all together
          @contents = VBox(
            Top(
              VBox(
                @ui_headers,
                Label(@explanation),
                RadioButtonGroup(@ui_options),
                VSpacing(Opt(:vstretch), 1),
                @ui_functions
              )
            )
          )

          # update the ui to reflect our new form state...
          Wizard.SetContents(@title, @contents, @helptext, false, true)
          # fix up the label on the next/finish button
          Wizard.SetNextButton(:next, Label.FinishButton)

          # select and enable to correct buttons
          @idx = 0
          Builtins.foreach(@options) do |option|
            UI.ChangeWidget(Id(@idx), :Value, @selected == @idx)
            @idx = Ops.add(@idx, 1)
          end

          # set the focus to be the default action, if we have one
          UI.SetFocus(Id(@default_button)) if @default_button != "NO_DEFAULT"

          # wait for user input
          @ret = Wizard.UserInput

          @answers = {}

          # figure out which button they pressed
          if @ret == :abort
            Ops.set(@answers, "selection", "CMD_ABORT")
          elsif @ret == :next
            Ops.set(@answers, "selection", "CMD_FINISHED")
          else
            Builtins.foreach(@functions) do |function|
              Ops.set(@answers, "selection", function) if @ret == function
            end
          end

          # figure out which option was selected
          @idx = 0
          Builtins.foreach(@options) do |option|
            if UI.QueryWidget(Id(@idx), :Value) == true
              Ops.set(@answers, "selected", @idx)
            end
            @idx = Ops.add(@idx, 1)
          end

          # tell the backend what they did
          SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "dialog-repo-sign-in"
          @answers = UI_RepositorySignInDialog(@agent_data)
          SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "dialog-view-profile"
          @answers = {}
          UI_RepositoryViewProfile(@agent_data)
          Ops.set(@answers, "answer", "okay")
          SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "dialog-select-profiles"
          @answers = UI_MultiProfileSelectionDialog(@agent_data)
          SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "dialog-busy-start"
          @answers = {}
          UI_BusyFeedbackStart(@agent_data)
          Ops.set(@answers, "answer", "okay")
          SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "dialog-busy-stop"
          @answers = {}
          UI_BusyFeedbackStop()
          Ops.set(@answers, "answer", "okay")
          SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "long-dialog-message"
          @answers = {}
          UI_LongMessage(@agent_data)
          Ops.set(@answers, "answer", "okay")
          SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "short-dialog-message"
          @answers = {}
          UI_ShortMessage(@agent_data)
          Ops.set(@answers, "answer", "okay")
          SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "dialog-yesno"
          @question = Ops.get_string(
            @agent_data,
            "question",
            "MISSING QUESTION"
          )
          @default_ans = Ops.get_string(@agent_data, "default", "n")

          @focus = :focus_no
          @focus = :focus_yes if @default_ans == "y"

          @answers = {}
          if Popup.AnyQuestion(
              Popup.NoHeadline,
              @question,
              Label.YesButton,
              Label.NoButton,
              @focus
            )
            Ops.set(@answers, "answer", "y")
          else
            Ops.set(@answers, "answer", "n")
          end

          # write the answers for the last dialog
          @written = SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "dialog-getstring"
          @label = Ops.get_string(@agent_data, "label", "MISSING LABEL")
          @default_value = Ops.get_string(
            @agent_data,
            "default",
            "MISSING DEFAULT"
          )

          @dialog = VBox(
            TextEntry(Id(:stringfield), @label, @default_value),
            HBox(
              HWeight(
                1,
                PushButton(Id(:okay), Opt(:default, :key_F10), Label.OKButton)
              ),
              HSpacing(2),
              HWeight(
                1,
                PushButton(Id(:cancel), Opt(:key_F9), Label.CancelButton)
              )
            )
          )


          UI.OpenDialog(@dialog)
          UI.SetFocus(Id(:stringfield))

          @poo = UI.UserInput

          @answers = {}
          if @poo == :okay
            Ops.set(
              @answers,
              "string",
              Convert.to_string(UI.QueryWidget(Id(:stringfield), :Value))
            )
          else
            Ops.set(@answers, "string", "")
          end

          UI.CloseDialog

          # write the answers for the last dialog
          @written = SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "dialog-getfile"
          @description = Ops.get_string(
            @agent_data,
            "description",
            "GETFILE: MISSING DESCRIPTION"
          )
          @file_label = Ops.get_string(
            @agent_data,
            "file_label",
            "GETFILE: MISSING FILE:LABEL"
          )
          @okay_label = Ops.get_string(
            @agent_data,
            "okay_label",
            "GETFILE: MISSING OKAY_LABEL"
          )
          @cancel_label = Ops.get_string(
            @agent_data,
            "cancel_label",
            "GETFILE: MISSING CANCEL_LABEL"
          )
          @browse_desc = Ops.get_string(
            @agent_data,
            "browse_desc",
            "GETFILE: MISSING BROWSE_DESC"
          )

          @dialog = VBox(
            Top(
              VBox(
                VSpacing(1),
                Left(Label(@description)),
                VSpacing(0.5),
                Left(TextEntry(Id(:filename), @file_label, "")),
                VSpacing(Opt(:vstretch), 0.25)
              )
            ),
            HBox(HCenter(PushButton(Id(:browse), _("&Browse")))),
            HBox(
              HSpacing(Opt(:hstretch), 0.1),
              HCenter(PushButton(Id(:okay), Opt(:default), @okay_label)),
              HCenter(PushButton(Id(:cancel), @cancel_label)),
              HSpacing(Opt(:hstretch), 0.1),
              VSpacing(1)
            )
          )


          UI.OpenDialog(@dialog)

          @answers = {}
          @poo = false
          begin
            UI.SetFocus(Id(:filename))

            @poo = UI.UserInput
            if @poo == :okay
              Ops.set(@answers, "answer", "okay")
              Ops.set(
                @answers,
                "filename",
                Convert.to_string(UI.QueryWidget(Id(:filename), :Value))
              )
            elsif @poo == :cancel
              Ops.set(@answers, "answer", "cancel")
            elsif @poo == :browse
              @selectfilename = UI.AskForExistingFile("/", "", @browse_desc)
              UI.ChangeWidget(Id(:filename), :Value, @selectfilename)
            end
          end until @poo == :okay || @poo == :cancel

          UI.CloseDialog

          # tell the backend what they picked
          @written = SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "dialog-error"
          @message = Ops.get_string(@agent_data, "message", "MISSING QUESTION")

          Popup.Error(@message)

          @answers = {}
          Ops.set(@answers, "answer", "okay")

          # tell the backend that the user has acknowledged the error
          @written = SCR.Write(path(".logprof"), @answers)
        elsif @type2 == "final_shutdown"
          @done = true

          @answers = {}
          Ops.set(@answers, "type", "shutdown_acknowledge")
          Ops.set(@answers, "status", "shutting_down")

          # tell the backend that we're shutting down also
          @written = SCR.Write(path(".logprof"), @answers)
        else
          @errortext = Ops.add(
            Builtins.sformat(
              _("AppArmor backend terminated unexpectedly: %1"),
              @type2
            ),
            _(
              "This is worth reporting bug in Novell Bugzilla:\nhttps://bugzilla.novell.com"
            )
          )
          Popup.Error(@errortext)
          @done = true
        end
      end until @done == true

      Wizard.CloseDialog

      nil
    end
  end
end

Yast::LogProfClient.new.main
