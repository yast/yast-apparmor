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
  module ApparmorReportingArchivedDialogsInclude
    def initialize_apparmor_reporting_archived_dialogs(include_target)
      Yast.import "UI"

      Yast.import "Wizard"
      Yast.import "Popup"
      Yast.import "Label"
      Yast.include include_target, "apparmor/report_helptext.rb"
      Yast.include include_target, "apparmor/reporting_utils.rb"
      textdomain "yast2-apparmor"

      # Global
      @timeout_millisec = 20 * 1000
    end

    #define term turnReportPage (integer curPage) {
    def turnArchReportPage(curPage, lastPage)
      _Settings = {}
      reportList = []

      currentPage = Builtins.tostring(curPage)
      slastPage = Builtins.tostring(lastPage)
      Ops.set(_Settings, "page", currentPage)
      Ops.set(_Settings, "turnArch", "1")
      Ops.set(_Settings, "turnPage", "1")

      reportList = getReportList("sir", _Settings)

      # poor i18n
      myLabel = Ops.add(
        Ops.add(
          Ops.add(_("Archived Security Incident Report - Page "), currentPage),
          _(" of ")
        ),
        slastPage
      )

      odForm = Frame(
        Id(:odframe),
        myLabel,
        VBox(
          HBox(VSpacing(10), makeSirTable(reportList), VSpacing(0.5)),
          HSpacing(Opt(:hstretch), 1.0),
          VSpacing(0.5),
          HBox(
            PushButton(Id(:first), _("F&irst")),
            PushButton(Id(:prev), _("&Previous")),
            PushButton(Id(:psort), _("&Sort")),
            PushButton(Id(:fwd), _("&Forward")),
            PushButton(Id(:last), _("&Last"))
          ),
          VSpacing(1)
        )
      )

      deep_copy(odForm)
    end

    def filterArchForm
      expPath = "/var/log/apparmor/reports-exported"

      arForm = Top(
        VBox(
          Left(CheckBox(Id(:bydate), Opt(:notify), _("Filter By Date Range"))),
          Frame(
            Id(:bydate_frame),
            _(" Select Date Range "),
            VBox(
              Label(_("Enter Starting Date/Time")),
              HBox(
                HSpacing(Opt(:hstretch), 1),
                IntField(Id(:startHours), _("Hours"), 0, 23, 0),
                IntField(Id(:startMins), _("Minutes"), 0, 59, 0),
                IntField(Id(:startDay), _("Day"), 1, 31, 1),
                IntField(Id(:startMonth), _("Month"), 1, 12, 1),
                IntField(Id(:startYear), _("Year"), 2005, 2020, 2005)
              ),
              VSpacing(1.0),
              Label(_("Enter Ending Date")),
              HBox(
                HSpacing(Opt(:hstretch), 1),
                IntField(Id(:endHours), _("Hours"), 0, 23, 0),
                IntField(Id(:endMins), _("Minutes"), 0, 59, 0),
                IntField(Id(:endDay), _("Day"), 1, 31, 1),
                IntField(Id(:endMonth), _("Month"), 1, 12, 1),
                IntField(Id(:endYear), _("Year"), 2005, 2020, 2005)
              ),
              VSpacing(1.0)
            )
          ),
          VSpacing(1.0),
          HBox(
            HWeight(4, TextEntry(Id(:prog), _("Program name"))),
            HWeight(4, TextEntry(Id(:prof), _("Profile name"))),
            HWeight(3, TextEntry(Id(:pid), _("PID number"))),
            HWeight(
              2,
              ComboBox(
                Id(:sev),
                _("Severity"),
                [
                  _("All"),
                  _("U"),
                  "00",
                  "01",
                  "02",
                  "03",
                  "04",
                  "05",
                  "06",
                  "07",
                  "08",
                  "09",
                  "10"
                ]
              )
            ),
            HSpacing(Opt(:hstretch), 5)
          ),
          HBox(
            HWeight(3, TextEntry(Id(:res), _("Detail"))),
            HWeight(
              3,
              ReplacePoint(
                Id(:replace_aamode),
                PushButton(Id(:aamode), _("Access Type: R"))
              )
            ),
            HWeight(
              3,
              ReplacePoint(
                Id(:replace_mode),
                PushButton(Id(:mode), _("Mode: All"))
              )
            ),
            HSpacing(Opt(:hstretch), 5)
          ),
          VSpacing(0.5),
          HBox(
            VSpacing(0.5),
            ComboBox(
              Id(:expType),
              Opt(:notify, :immediate),
              _("Export Type"),
              [_("None"), _("csv"), _("html"), _("Both")]
            ),
            TextEntry(Id(:expPath), _("Location to store log."), expPath),
            Bottom(VWeight(1, PushButton(Id(:accept), Label.AcceptButton))),
            Bottom(VWeight(1, PushButton(Id(:browse), _("&Browse"))))
          )
        )
      )

      deep_copy(arForm)
    end

    def setArchFilter
      _Settings = {}

      archForm = filterArchForm
      Wizard.SetContentsButtons(
        _("Report Configuration Dialog"),
        archForm,
        @setArchHelp,
        Label.BackButton,
        Label.NextButton
      )

      UI.ChangeWidget(Id(:bydate_frame), :Enabled, false)

      mode = "All"
      aamode = "R"

      event = {}
      id = nil

      while true
        event = UI.WaitForEvent(@timeout_millisec)
        id = Ops.get(event, "ID") # We'll need this often - cache it

        if id == :bydate
          UI.ChangeWidget(Id(:bydate_frame), :Enabled, true)
        elsif id == :next || id == :save
          bydate = Convert.to_boolean(UI.QueryWidget(Id(:bydate), :Value))

          if bydate == true
            startDay = Convert.to_integer(UI.QueryWidget(Id(:startDay), :Value))
            startMonth = Convert.to_integer(
              UI.QueryWidget(Id(:startMonth), :Value)
            )
            startYear = Convert.to_integer(
              UI.QueryWidget(Id(:startYear), :Value)
            )
            startHours = Convert.to_integer(
              UI.QueryWidget(Id(:startHours), :Value)
            )
            startMins = Convert.to_integer(
              UI.QueryWidget(Id(:startMins), :Value)
            )
            endDay = Convert.to_integer(UI.QueryWidget(Id(:endDay), :Value))
            endMonth = Convert.to_integer(UI.QueryWidget(Id(:endMonth), :Value))
            endYear = Convert.to_integer(UI.QueryWidget(Id(:endYear), :Value))
            endHours = Convert.to_integer(UI.QueryWidget(Id(:endHours), :Value))
            endMins = Convert.to_integer(UI.QueryWidget(Id(:endMins), :Value))

            # start_day & start_month are mutually exclusive
            if id == :startDay
              UI.ChangeWidget(Id(:startMonth), :Value, 0)
            elsif id == :startMonth
              UI.ChangeWidget(Id(:startDay), :Value, 0)
            end

            # start_day & start_month are mutually exclusive
            if id == :endDay
              UI.ChangeWidget(Id(:endMonth), :Value, 0)
            elsif id == :endMonth
              UI.ChangeWidget(Id(:endDay), :Value, 0)
            end

            if CheckDate(startDay, startMonth, startYear) == false
              Popup.Error(_("Illegal start date entered. Retry."))
              next
            end

            if CheckDate(endDay, endMonth, endYear) == false
              Popup.Error(_("Illegal end date entered. Retry."))
              next
            end
            #//////////////////////////////////////////////////////////

            startday = Builtins.tostring(startDay)
            startmonth = Builtins.tostring(startMonth)
            startyear = Builtins.tostring(startYear)
            starthours = Builtins.tostring(startHours)
            startmins = Builtins.tostring(startMins)
            endday = Builtins.tostring(endDay)
            endmonth = Builtins.tostring(endMonth)
            endyear = Builtins.tostring(endYear)
            endhours = Builtins.tostring(endHours)
            endmins = Builtins.tostring(endMins)

            Ops.set(_Settings, "startday", startday)
            Ops.set(_Settings, "startmonth", startmonth)
            Ops.set(_Settings, "startyear", startyear)
            Ops.set(_Settings, "endday", endday)
            Ops.set(_Settings, "endmonth", endmonth)
            Ops.set(_Settings, "endyear", endyear)
            Ops.set(
              _Settings,
              "starttime",
              Ops.add(Ops.add(starthours, ":"), startmins)
            )
            Ops.set(
              _Settings,
              "endtime",
              Ops.add(Ops.add(endhours, ":"), endmins)
            )
          end

          expType = Convert.to_string(UI.QueryWidget(Id(:exportType), :Value))
          expPath = Convert.to_string(UI.QueryWidget(Id(:exportPath), :Value))

          if expType != "" && expType != "None"
            if expType == "csv"
              Ops.set(_Settings, "exporttext", "true")
            elsif expType == "html"
              Ops.set(_Settings, "exporthtml", "true")
            elsif expType == "both"
              Ops.set(_Settings, "exporttext", "true")
              Ops.set(_Settings, "exporthtml", "true")
            end
          end

          program_name = Convert.to_string(UI.QueryWidget(Id(:prog), :Value))
          profile = Convert.to_string(UI.QueryWidget(Id(:prof), :Value))
          pid = Convert.to_string(UI.QueryWidget(Id(:pid), :Value))
          sev = Convert.to_string(UI.QueryWidget(Id(:sev), :Value))
          res = Convert.to_string(UI.QueryWidget(Id(:res), :Value))
          aamode2 = Convert.to_string(UI.QueryWidget(Id(:aamode), :Label))
          mode2 = Convert.to_string(UI.QueryWidget(Id(:mode), :Label))
          exppath = Convert.to_string(UI.QueryWidget(Id(:expPath), :Value))

          aamode2 = "All" if aamode2 == "-"
          mode2 = "All" if mode2 == "-"

          Ops.set(_Settings, "prog", program_name) if program_name != ""
          Ops.set(_Settings, "profile", profile) if profile != ""
          Ops.set(_Settings, "pid", pid) if pid != ""
          Ops.set(_Settings, "severity", sev) if sev != "" && sev != "All"
          Ops.set(_Settings, "resource", res) if res != ""
          Ops.set(_Settings, "aamode", aamode2) if aamode2 != ""
          Ops.set(_Settings, "mode", mode2) if mode2 != ""
          Ops.set(_Settings, "exportPath", exppath) if exppath != ""

          id = nil
          break
        elsif id == :aamode
          aamode = popUpSdMode
          Ops.set(_Settings, "aamode", aamode)
          UI.ReplaceWidget(
            Id(:replace_aamode),
            PushButton(Id(:aamode), Ops.add(_("Access Type: "), aamode))
          )
        elsif id == :mode
          mode = popUpMode
          Ops.set(_Settings, "mode", mode)
          UI.ReplaceWidget(
            Id(:replace_mode),
            PushButton(Id(:mode), Ops.add(_("Mode: "), mode))
          )
        elsif id == :abort || id == :cancel || id == :done
          Ops.set(_Settings, "break", "abort")
          break
        elsif id == :close || id == :back
          Ops.set(_Settings, "break", "back")
          break
        end
      end

      deep_copy(_Settings)
    end

    def viewArchForm(tab, logFile, _Settings)
      _Settings = deep_copy(_Settings)
      Ops.set(_Settings, "archRep", "1")
      Ops.set(_Settings, "logFile", logFile)
      Ops.set(_Settings, "type", "archRep")

      curPage = 1
      currentPage = "1"
      Ops.set(_Settings, "currentPage", currentPage)

      isingle = Ops.get_integer(_Settings, "single", 1)
      single = "1"
      single = Builtins.tostring(isingle) if isingle != nil
      Ops.set(_Settings, "single", single)

      # mark - new
      junk = SCR.Read(path(".logparse"), _Settings)

      lastPage = getLastPage("sirRep", _Settings, "")
      myPage = turnArchReportPage(curPage, lastPage)

      deep_copy(myPage)
    end
  end
end
