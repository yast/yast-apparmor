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
  module ApparmorApparmorYcpUtilsInclude
    def initialize_apparmor_apparmor_ycp_utils(include_target)
      Yast.import "UI"

      Yast.import "Label"
      Yast.import "Popup"
      Yast.import "AppArmorDialogs"
      textdomain "apparmor"

      @CMDS = {}
      Ops.set(@CMDS, "CMD_ALLOW", _("&Allow"))
      Ops.set(@CMDS, "CMD_DENY", _("&Deny"))
      Ops.set(@CMDS, "CMD_ABORT", _("Abo&rt"))
      Ops.set(@CMDS, "CMD_FINISHED", Label.FinishButton)
      Ops.set(@CMDS, "CMD_AUDIT_NEW", _("Audi&t"))
      Ops.set(@CMDS, "CMD_AUDIT_OFF", _("Audi&t off"))
      Ops.set(@CMDS, "CMD_AUDIT_FULL", _("Audit &All"))
      Ops.set(@CMDS, "CMD_OTHER", _("&Opts"))
      Ops.set(@CMDS, "CMD_USER_ON", _("&Owner Permissions on"))
      Ops.set(@CMDS, "CMD_USER_OFF", _("&Owner Permissions off"))
      Ops.set(@CMDS, "CMD_ix", _("&Inherit"))
      Ops.set(@CMDS, "CMD_px", _("&Profile"))
      Ops.set(@CMDS, "CMD_px_safe", _("&Profile Clean Exec"))
      Ops.set(@CMDS, "CMD_cx", _("&Child"))
      Ops.set(@CMDS, "CMD_cx_safe", _("&Child Clean Exec"))
      Ops.set(@CMDS, "CMD_nx", _("&Name"))
      Ops.set(@CMDS, "CMD_nx_safe", _("&Named Clean Exec"))
      Ops.set(@CMDS, "CMD_ux", _("&Unconfined"))
      Ops.set(@CMDS, "CMD_ux_safe", _("&Unconfined Clean Exec"))
      Ops.set(@CMDS, "CMD_pix", _("&Profile ix"))
      Ops.set(@CMDS, "CMD_pix_safe", _("&Profile ix Clean Exec"))
      Ops.set(@CMDS, "CMD_cix", _("&Child ix"))
      Ops.set(@CMDS, "CMD_cix_safe", _("&Child ix Cx Clean Exec"))
      Ops.set(@CMDS, "CMD_nix", _("&Name ix"))
      Ops.set(@CMDS, "CMD_nix_safe", _("&Name ix"))
      Ops.set(@CMDS, "CMD_EXEC_IX_ON", _("i&x fallback on"))
      Ops.set(@CMDS, "CMD_EXEC_IX_OFF", _("i&x fallback off"))
      Ops.set(@CMDS, "CMD_CONTINUE", _("&Continue Profiling"))
      Ops.set(@CMDS, "CMD_INHERIT", _("&Inherit"))
      Ops.set(@CMDS, "CMD_PROFILE", _("&Profile"))
      Ops.set(@CMDS, "CMD_UNCONFINED", _("&Unconfined"))
      Ops.set(@CMDS, "CMD_NEW", _("&Edit"))
      Ops.set(@CMDS, "CMD_GLOB", _("&Glob"))
      Ops.set(@CMDS, "CMD_GLOBEXT", _("Glob w/E&xt"))
      Ops.set(@CMDS, "CMD_ADDHAT", _("&Add Requested Hat"))
      Ops.set(@CMDS, "CMD_USEDEFAULT", _("&Use Default Hat"))
      Ops.set(@CMDS, "CMD_SCAN", _("&Scan system log for AppArmor events"))
      Ops.set(@CMDS, "CMD_VIEW_PROFILE", _("&View Profile"))
      Ops.set(@CMDS, "CMD_USE_PROFILE", _("&Use Profile"))
      Ops.set(@CMDS, "CMD_CREATE_PROFILE", _("&Create New Profile"))
      Ops.set(@CMDS, "CMD_UPDATE_PROFILE", _("&Update Profile"))
      Ops.set(@CMDS, "CMD_IGNORE_UPDATE", _("&Ignore Update"))
      Ops.set(@CMDS, "CMD_SAVE_CHANGES", _("&Save Changes"))
      Ops.set(@CMDS, "CMD_UPLOAD_CHANGES", _("&Upload Changes"))
      Ops.set(@CMDS, "CMD_VIEW_CHANGES", _("&View Changes"))
      Ops.set(@CMDS, "CMD_ENABLE_REPO", _("&Enable Repository"))
      Ops.set(@CMDS, "CMD_DISABLE_REPO", _("&Disable Repository"))
      Ops.set(@CMDS, "CMD_ASK_NEVER", _("&Never Ask Again"))
      Ops.set(@CMDS, "CMD_ASK_LATER", _("Ask Me &Later"))
      Ops.set(@CMDS, "CMD_YES", Label.YesButton)
      Ops.set(@CMDS, "CMD_NO", Label.NoButton)
    end

    def validEmailAddress(emailAddr, allowlocal)
      emailAddrLength = Builtins.size(emailAddr)
      isSafe = false

      if allowlocal && Builtins.regexpmatch(emailAddr, "^/var/mail/\\w+$")
        isSafe = true
      elsif (Builtins.regexpmatch(emailAddr, "\\w+(-\\w+?)@\\w+") ||
          Builtins.regexpmatch(emailAddr, "/^(\\w+.?)+\\w+@(\\w+.?)+\\w+$") ||
          Builtins.regexpmatch(emailAddr, "\\w+@\\w+") ||
          !Builtins.regexpmatch(emailAddr, "..+")) &&
          Ops.less_than(emailAddrLength, 129)
        isSafe = true
      end
      isSafe
    end

    def checkEmailAddress(emailAddr)
      if !validEmailAddress(emailAddr, false)
        err_email_format = _(
          "Email address format invalid.\n" +
            "Email address must be less than 129 characters \n" +
            " and of the format \"name@domain\". \n" +
            "Enter a valid address.\n"
        )
        Popup.Error(err_email_format)
        return false
      end
      true
    end


    # UI_RepositorySignInDialog
    # Dialog to allow users to signin or register with an external AppArmor
    # profile repository
    #
    # @param [Hash] agent_data - data from the backend
    #                [ repo_url - string ]
    # @return answers - map that contains:
    #                [   newuser     => 1|0 - registering a new user?         ]
    #                [   user        => username                              ]
    #                [   pass        => password                              ]
    #                [   email       => email address - if newuser = 1        ]
    #                [   save_config => true/false - save this information on ]
    #                [                  the system                            ]
    #
    #
    def UI_RepositorySignInDialog(agent_data)
      agent_data = deep_copy(agent_data)
      repo_url = Ops.get_string(agent_data, "repo_url", "MISSING_REPO_URL")
      dialog = VBox(
        VSpacing(1),
        Top(
          Label(
            Ops.add(_("AppArmor Profile Repository Setup") + "\n", repo_url)
          )
        ),
        VBox(ReplacePoint(Id(:replace), Empty())),
        VSpacing(1)
      )

      signin_box = VBox(
        HBox(
          HSpacing(1),
          Frame(
            Id(:signin_frame),
            _("Sign in to the repository"),
            HBox(
              HSpacing(0.5),
              VBox(
                TextEntry(Id(:username), _("Username")),
                Password(Id(:password), Label.Password),
                VSpacing(1),
                HBox(
                  CheckBox(
                    Id(:save_conf),
                    Opt(:notify),
                    _("S&ave configuration")
                  ),
                  HSpacing(0.5),
                  Left(PushButton(Id(:signin_submit), _("&Sign in"))),
                  Right(PushButton(Id(:signin_cancel), Label.CancelButton)),
                  HSpacing(0.5)
                )
              ),
              HSpacing(0.5)
            )
          ),
          HSpacing(1)
        ),
        VSpacing(1),
        PushButton(Id(:newuser), _("&Register new user..."))
      )

      registration_box = VBox(
        HBox(
          HSpacing(1),
          Frame(
            Id(:register_frame),
            _("Register New User"),
            HBox(
              HSpacing(0.5),
              VBox(
                TextEntry(Id(:register_username), _("Enter Username")),
                TextEntry(Id(:register_email), _("Enter Email Address")),
                Password(Id(:register_password), _("Enter Password")),
                Password(Id(:register_password2), _("Verify Password")),
                VSpacing(1),
                HBox(
                  HSpacing(0.2),
                  CheckBox(
                    Id(:save_conf_new),
                    Opt(:notify),
                    _("S&ave configuration")
                  ),
                  Left(PushButton(Id(:register_submit), _("&Register"))),
                  Right(PushButton(Id(:register_cancel), Label.CancelButton)),
                  HSpacing(0.2)
                )
              ),
              HSpacing(0.5)
            )
          ),
          HSpacing(1)
        ),
        VSpacing(1),
        PushButton(Id(:signin), _("&Sign in as existing user..."))
      )

      UI.OpenDialog(Opt(:decorated), dialog)
      UI.ReplaceWidget(:replace, signin_box)
      answers = {}
      input = nil
      begin
        input = UI.UserInput
        if input == :newreg
          new_registration = Convert.to_boolean(
            UI.QueryWidget(Id(:newreg), :Value)
          )
          if new_registration == true
            UI.ChangeWidget(Id(:register_frame), :Enabled, true)
            UI.ChangeWidget(Id(:signin_frame), :Enabled, false)
          else
            UI.ChangeWidget(Id(:register_frame), :Enabled, false)
            UI.ChangeWidget(Id(:signin_frame), :Enabled, true)
          end
        elsif input == :newuser
          UI.ReplaceWidget(:replace, registration_box)
          UI.ChangeWidget(Id(:register_email), :InputMaxLength, 129)
        elsif input == :signin
          UI.ReplaceWidget(:replace, signin_box)
          UI.ChangeWidget(Id(:register_email), :InputMaxLength, 129)
        elsif input == :signin_cancel || input == :register_cancel
          Ops.set(answers, "answer", "cancel")
        elsif input == :signin_submit
          username = Convert.to_string(UI.QueryWidget(Id(:username), :Value))
          password = Convert.to_string(UI.QueryWidget(Id(:password), :Value))
          save_config = Convert.to_boolean(
            UI.QueryWidget(Id(:save_conf), :Value)
          ) ? "y" : "n"

          if username == ""
            Popup.Error(_("Username is required"))
          elsif password == ""
            Popup.Error(_("Password is required"))
          else
            Builtins.y2milestone(
              Ops.add(
                Ops.add(
                  Ops.add(
                    Ops.add(
                      "APPARMOR : REPO - signon: \n\tusername [",
                      username
                    ),
                    "]\n\tpassword ["
                  ),
                  password
                ),
                "]"
              )
            )
            Ops.set(answers, "newuser", "n")
            Ops.set(answers, "user", username)
            Ops.set(answers, "pass", password)
            Ops.set(answers, "save_config", save_config)
            input = :done
          end
        elsif input == :register_submit
          username = Convert.to_string(
            UI.QueryWidget(Id(:register_username), :Value)
          )
          password = Convert.to_string(
            UI.QueryWidget(Id(:register_password), :Value)
          )
          password_verify = Convert.to_string(
            UI.QueryWidget(Id(:register_password2), :Value)
          )
          email = Convert.to_string(UI.QueryWidget(Id(:register_email), :Value))
          save_config = Convert.to_boolean(
            UI.QueryWidget(Id(:save_conf_new), :Value)
          ) ? "y" : "n"

          if username == ""
            Popup.Error(_("Username required for registration."))
          elsif email == ""
            Popup.Error(_("Email address required for registration."))
          elsif password == "" && password_verify == ""
            Popup.Error(_("Password is required for registration."))
          elsif password != password_verify
            Popup.Error(_("Passwords do not match. Please re-enter."))
          elsif !checkEmailAddress(email)
            dummy = nil
          else
            Builtins.y2milestone(
              Ops.add(
                Ops.add(
                  Ops.add(
                    Ops.add(
                      Ops.add(
                        Ops.add(
                          Ops.add(
                            Ops.add(
                              "APPARMOR : REPO - new registration: \n\tusername [",
                              username
                            ),
                            "]\n\tpassword ["
                          ),
                          password
                        ),
                        "]\n\temail ["
                      ),
                      email
                    ),
                    "]\n\tsave config ["
                  ),
                  save_config
                ),
                "]"
              )
            )
            Ops.set(answers, "newuser", "y")
            Ops.set(answers, "pass", password)
            Ops.set(answers, "user", username)
            Ops.set(answers, "email", email)
            Ops.set(answers, "save_config", save_config)
            input = :done
          end
        else
          Builtins.y2milestone(
            Ops.add(
              Ops.add(
                "APPARMOR : REPO - signon - no valid input[",
                Builtins.tostring(input)
              ),
              "]"
            )
          )
        end
      end until input == :done || input == :register_cancel || input == :signin_cancel
      Ops.set(answers, "cancelled", "y") if input != :done
      UI.CloseDialog
      deep_copy(answers)
    end


    # UI_RepositoryViewProfile
    # Dialog to allow users to view a profile from the repository
    # and display it in a small scrollable dialog
    #
    # @param [Hash] agent_data - map data from the backend
    #                 [ user         => string                              ]
    #                 [ profile      => string contiaining profile contents ]
    #                 [ profile_type => string INACTIVE_LOCAL|REPOSITORY    ]
    #
    # @return [void]
    #
    #

    def UI_RepositoryViewProfile(agent_data)
      agent_data = deep_copy(agent_data)
      user = Ops.get_string(agent_data, "user", "MISSING USER")
      profile = Ops.get_string(agent_data, "profile", "MISSING PROFILE")
      type = Ops.get_string(agent_data, "profile_type", "MISSING PROFILE")

      headline = ""
      if type == "INACTIVE_LOCAL"
        headline = _("Local inactive profile")
      elsif type == "REPOSITORY"
        headline = Ops.add(_("Profile created by user "), user)
      else
        headline = _("Local profile")
      end


      Popup.LongText(headline, RichText(Opt(:plainText), profile), 50, 20)

      nil
    end


    # UI_LongMessage
    # Basic message dialog that will scroll long text
    # @param [Hash] agent_data - map - data from backend
    #                 [ headline - string ]
    #                 [ message  - string ]
    #
    # @return [void]
    #

    def UI_LongMessage(agent_data)
      agent_data = deep_copy(agent_data)
      user = Ops.get(agent_data, "user")
      headline = Ops.get_string(agent_data, "headline", "MISSING HEADLINE")
      message = Ops.get_string(agent_data, "message", "MISSING MESSAGE")

      Popup.LongText(headline, RichText(Opt(:plainText), message), 60, 40)

      nil
    end


    # UI_ShortMessage
    # Basic message dialog - no scrollbars
    # @param [Hash] agent_data - map - data from backend
    #                 [ headline - string ]
    #                 [ message  - string ]
    #
    # @return [void]
    #

    def UI_ShortMessage(agent_data)
      agent_data = deep_copy(agent_data)
      user = Ops.get(agent_data, "user")
      headline = Ops.get_string(agent_data, "headline", "MISSING HEADLINE")
      message = Ops.get_string(agent_data, "message", "MISSING MESSAGE")

      Popup.AnyMessage(headline, message)

      nil
    end

    # UI_ChangeLog_Dialog
    # Takes a list of profiles and collects one or multiple changelog entries
    # and returns them
    #
    # @param [Hash] agent_data - data from the backend
    #           [ profiles - list of profile names                           ]
    #
    # @return   results    - map
    #           [ STATUS            -  string - ok/cancel                    ]
    #           [ SINGLE_CHANGELOG  -  string - set with changelog if user   ]
    #           [                               selects a single changelog   ]
    #
    #           [ profile 1 name    -  string - changelog 1                  ]
    #           [ profile 2 name    -  string - changelog 2                  ]
    #           ...
    #           [ profile n name    -  string - changelog n                  ]
    #
    #
    def UI_ChangeLog_Dialog(agent_data)
      agent_data = deep_copy(agent_data)
      results = {}
      main_label = _("Enter a changelog for the changes for ")
      main_label_single = _(" the selected profiles")
      checkbox_label = _("Individual changelogs per profile")
      profiles = Ops.get_list(agent_data, "profiles", [])

      dialog = VBox(
        TextEntry(
          Id(:stringfield),
          Ops.add(Ops.add(main_label, "\n"), main_label_single)
        ),
        CheckBox(Id(:individual_changelogs), Opt(:notify), checkbox_label),
        VSpacing(0.5),
        HBox(
          HWeight(
            1,
            PushButton(Id(:okay), Opt(:default, :key_F10), Label.OKButton)
          ),
          HSpacing(2),
          HWeight(1, PushButton(Id(:cancel), Opt(:key_F9), Label.CancelButton))
        )
      )
      Ops.set(results, "STATUS", "ok")
      single_changelog = true
      Builtins.foreach(profiles) do |profile_name|
        UI.OpenDialog(dialog)
        if !single_changelog
          UI.ChangeWidget(
            Id(:stringfield),
            :Label,
            Ops.add(Ops.add(main_label, "\n"), profile_name)
          )
          UI.ChangeWidget(Id(:individual_changelogs), :Value, true)
        end
        UI.SetFocus(Id(:stringfield))
        input = nil
        begin
          input = UI.UserInput
          if input == :cancel
            Ops.set(results, "STATUS", "cancel")
            UI.CloseDialog
            break
          elsif input == :okay
            if Convert.to_boolean(
                UI.QueryWidget(Id(:individual_changelogs), :Value)
              ) == false
              Ops.set(
                results,
                "SINGLE_CHANGELOG",
                Convert.to_string(UI.QueryWidget(Id(:stringfield), :Value))
              )
              UI.CloseDialog
            else
              Ops.set(
                results,
                profile_name,
                Convert.to_string(UI.QueryWidget(Id(:stringfield), :Value))
              )
              UI.CloseDialog
            end
          elsif input == :individual_changelogs
            if Convert.to_boolean(
                UI.QueryWidget(Id(:individual_changelogs), :Value)
              ) == true
              UI.ChangeWidget(
                Id(:stringfield),
                :Label,
                Ops.add(Ops.add(main_label, "\n"), profile_name)
              )
              single_changelog = false
            else
              UI.ChangeWidget(
                Id(:stringfield),
                :Label,
                Ops.add(Ops.add(main_label, "\n"), main_label_single)
              )
            end
          end
        end until input == :okay || :input == :cancel
        raise Break if single_changelog || input == :cancel
      end
      deep_copy(results)
    end

    # UI_MultiProfileSelectionDialog
    # Two pane dialog with a multi-selection box on the left
    # and a long text on the right. Allows a list of profiles
    # or profile changes to be viewed and selected for further
    # processing - for example  uploading to the repository
    #
    # @param [Hash] agent_data - map - data from backend
    #           [ title               - string - explanation of the forms use ]
    #           [ get_changelog       - string true/false - prompt user to    ]
    #           [                       supply changelogs                     ]
    #           [ never_ask_again     - string true/false - add widget to let ]
    #           [                       user select to never prompt again to  ]
    #           [                       upload unselected profiles to the     ]
    #           [                       repository                            ]
    #           [ default_select      - string true/false - default value for ]
    #           [                       profile selection                     ]
    #           [ profiles            - map<string,string>                    ]
    #
    # @return   results    - map
    #           [ STATUS           - string - ok/cancel                       ]
    #           [ PROFILES         - list[string] - list of selected profiles ]
    #           [ NEVER_ASK_AGAIN  - string - true/false - mark unselected    ]
    #           [                    profiles as local only and don't prompt  ]
    #           [                    to upload                                ]
    #           [ CHANGELOG        - map[string,string] - changelog data from ]
    #           [                    UI_ChangeLog_Dialog()                    ]
    #
    #

    def UI_MultiProfileSelectionDialog(agent_data)
      agent_data = deep_copy(agent_data)
      headline = Ops.get_string(agent_data, "title", "MISSING TITLE")
      explanation = Ops.get_string(
        agent_data,
        "explanation",
        "MISSING EXPLANATION"
      )
      default_select = Ops.get_boolean(agent_data, "default_select", false)
      get_changelog = Ops.get_boolean(agent_data, "get_changelog", true)
      disable_ask_upload = Ops.get_boolean(
        agent_data,
        "disable_ask_upload",
        false
      )
      profiles = Ops.get_map(agent_data, "profiles", {})
      results = {}

      profile_list = []
      Builtins.foreach(
        Convert.convert(profiles, :from => "map", :to => "map <string, string>")
      ) do |profile_name, profile_contents|
        profile_list = Builtins.add(
          profile_list,
          Item(Id(profile_name), profile_name, default_select)
        )
      end

      first_profile = Ops.get_term(profile_list, 0)
      first_profile_name = Ops.get_string(
        first_profile,
        1,
        "MISSING PROFILE NAME"
      )
      profile_rules = Ops.get_string(
        profiles,
        first_profile_name,
        "MISSING CONTENTS"
      )
      disable_ask_upload_str = _("&Do not ask again for unselected profiles")
      ui_capabilities = UI.GetDisplayInfo
      in_ncurses = Ops.get_boolean(ui_capabilities, "TextMode", true)
      profile_contents_text = nil
      explanation_text = nil

      if in_ncurses
        profile_contents_text = RichText(
          Id(:contents),
          Opt(:plainText),
          profile_rules
        )
      else
        profile_contents_text = VBox(
          VSpacing(1.25),
          RichText(Id(:contents), Opt(:plainText), profile_rules)
        )
      end
      control_widgets = nil
      if disable_ask_upload == true
        control_widgets = VBox(
          CheckBox(
            Id(:disable_ask_upload),
            Opt(:notify),
            disable_ask_upload_str
          ),
          VSpacing(0.5),
          HBox(
            HWeight(50, HCenter(PushButton(Id(:save), Label.OKButton))),
            HWeight(50, HCenter(PushButton(Id(:cancel), Label.CancelButton)))
          )
        )
      else
        if in_ncurses
          control_widgets = HBox(
            HWeight(50, HCenter(PushButton(Id(:save), Label.OKButton))),
            HWeight(50, HCenter(PushButton(Id(:cancel), Label.CancelButton)))
          )
        else
          control_widgets = VBox(
            VSpacing(0.5),
            HBox(
              HWeight(50, HCenter(PushButton(Id(:save), Label.OKButton))),
              HWeight(50, HCenter(PushButton(Id(:cancel), Label.CancelButton)))
            )
          )
        end
      end

      UI.OpenDialog(
        VBox(
          VSpacing(0.1),
          VWeight(15, Top(Label(Id(:explanation), explanation))),
          VSpacing(0.2),
          VWeight(
            70,
            HBox(
              VSpacing(1),
              HSpacing(0.5),
              Frame(
                Id(:select_profiles),
                headline,
                HBox(
                  HWeight(
                    40,
                    MinSize(
                      30,
                      15,
                      MultiSelectionBox(
                        Id(:profiles),
                        Opt(:notify),
                        _("Profiles"),
                        profile_list
                      )
                    )
                  ),
                  HWeight(60, profile_contents_text)
                )
              ),
              HSpacing(0.5)
            )
          ),
          VSpacing(0.2),
          VWeight(15, control_widgets),
          VSpacing(0.2)
        )
      )
      UI.ChangeWidget(Id(:profiles), :CurrentValue, first_profile_name)

      event2 = {}
      id2 = nil
      begin
        event2 = UI.WaitForEvent
        id2 = Ops.get(event2, "ID")
        if id2 == :profiles
          itemid = UI.QueryWidget(Id(:profiles), :CurrentItem)
          stritem = Builtins.tostring(itemid)
          contents = Ops.get_string(profiles, stritem, "MISSING CONTENTS")
          UI.ChangeWidget(Id(:contents), :Value, contents)
        end
      end until id2 == :save || id2 == :cancel

      selected_profiles = []
      if id2 == :save
        selected_items = Convert.to_list(
          UI.QueryWidget(Id(:profiles), :SelectedItems)
        )
        profile_index = 0
        Builtins.foreach(selected_items) do |p_name|
          Ops.set(selected_profiles, profile_index, Builtins.tostring(p_name))
          profile_index = Ops.add(profile_index, 1)
        end
        Ops.set(results, "STATUS", "ok")
        if get_changelog == true
          changelog_results = UI_ChangeLog_Dialog(
            { "profiles" => selected_profiles }
          )
          if Ops.get_string(changelog_results, "STATUS", "cancel") == "cancel"
            Ops.set(results, "STATUS", "cancel")
          else
            Ops.set(results, "CHANGELOG", changelog_results)
            Ops.set(results, "PROFILES", selected_profiles)
          end
        else
          Ops.set(results, "PROFILES", selected_profiles)
        end
        if disable_ask_upload == true &&
            Convert.to_boolean(UI.QueryWidget(Id(:disable_ask_upload), :Value)) == true
          Ops.set(results, "NEVER_ASK_AGAIN", "true")
        end
      elsif id2 == :cancel
        Ops.set(results, "STATUS", "cancel")
      end
      UI.CloseDialog
      deep_copy(results)
    end

    # Form_BusyFeedbackDialog
    #
    # @param    agent_data - map - data from backend
    #           [ title               - string - explanation of the forms use ]
    #
    # @return   results    - map
    #           [ STATUS           - string - ok/cancel                       ]
    #
    #

    def Form_BusyFeedbackDialog(message)
      #`MinSize( 10, 4, `Image(`opt(`animated), movie, "animation" ),
      #`Image(`opt(`animated), movie, "animation" ),
      movie = "/usr/share/YaST2/theme/current/animations/ticks-endless.gif"
      busy_dialog = HBox(
        #`MinSize( 10, 4, `Image(`opt(`animated), movie, "animation" ) ),
        Image(Opt(:animated), movie, "animation"),
        Label(message)
      )
      deep_copy(busy_dialog)
    end

    def UI_BusyFeedbackStart(agent_data)
      agent_data = deep_copy(agent_data)
      message = Ops.get_string(agent_data, "message", "MISSING MESSAGE")
      UI.CloseDialog if AppArmorDialogs.busy_dialog != nil
      AppArmorDialogs.busy_dialog = Form_BusyFeedbackDialog(message)
      UI.OpenDialog(AppArmorDialogs.busy_dialog)
      nil
    end

    def UI_BusyFeedbackStop
      if AppArmorDialogs.busy_dialog != nil
        UI.CloseDialog
        AppArmorDialogs.busy_dialog = nil
      end

      nil
    end
  end
end
