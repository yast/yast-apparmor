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
  module ApparmorReportingDialoguesInclude
    def initialize_apparmor_reporting_dialogues(include_target)
      Yast.import "UI"

      Yast.import "Wizard"
      Yast.import "Popup"
      Yast.import "Label"
      Yast.include include_target, "apparmor/reporting_utils.rb"
      Yast.include include_target, "apparmor/report_helptext.rb"
      Yast.include include_target, "apparmor/reporting_archived_dialogs.rb"
      textdomain "yast2-apparmor"

      # Globalz
      #integer timeout_millisec = 20 * 1000;
      @Settings = {}
      @defExpPath = "/var/log/apparmor/reports-exported"
      @oldExpPath = "/var/log/apparmor/reports-exported"
      @expPath = @oldExpPath

      # This map is to pull the string to send back to the backend agent on save
      @md_map = {
        :md_00 => _("All"),
        :md_01 => "1",
        :md_02 => "2",
        :md_03 => "3",
        :md_04 => "4",
        :md_05 => "5",
        :md_06 => "6",
        :md_07 => "7",
        :md_08 => "8",
        :md_09 => "9",
        :md_10 => "10",
        :md_11 => "11",
        :md_12 => "12",
        :md_13 => "13",
        :md_14 => "14",
        :md_15 => "15",
        :md_16 => "16",
        :md_17 => "17",
        :md_18 => "18",
        :md_19 => "19",
        :md_20 => "20",
        :md_21 => "21",
        :md_22 => "22",
        :md_23 => "23",
        :md_24 => "24",
        :md_25 => "25",
        :md_26 => "26",
        :md_27 => "27",
        :md_28 => "28",
        :md_29 => "29",
        :md_30 => "30",
        :md_31 => "31"
      }

      @schedFilterForm = VBox(
        VSpacing(0.5),
        HBox(
          HWeight(5, TextEntry(Id(:prog), _("Program name"))),
          HWeight(5, TextEntry(Id(:prof), _("Profile name"))),
          HSpacing(Opt(:hstretch), 1)
        ),
        VSpacing(0.5),
        HBox(
          HWeight(5, TextEntry(Id(:pid), _("PID number"))),
          HWeight(5, TextEntry(Id(:res), _("Detail"))),
          HSpacing(Opt(:hstretch), 1)
        ),
        VSpacing(0.5),
        HBox(
          HWeight(
            2,
            ComboBox(
              Id(:sev),
              _("Severity"),
              [
                _("All"),
                "U",
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
          VBox(
            Label(_("Access Type: ")),
            ReplacePoint(Id(:replace_aamode), PushButton(Id(:aamode), "R"))
          ),
          VBox(
            Label(_("Mode: ")),
            ReplacePoint(Id(:replace_mode), PushButton(Id(:mode), _("All")))
          ),
          #`HWeight( 4, `ReplacePoint(`id(`replace_aamode), `PushButton(`id(`aamode), _("Access Type: R") ))),
          #`HWeight( 4, `ReplacePoint(`id(`replace_mode), `PushButton(`id(`mode), _("Mode: All")  ))),
          HSpacing(Opt(:hstretch), 1)
        ),
        VSpacing(1),
        HBox(
          PushButton(Id(:cancel), Label.CancelButton),
          PushButton(Id(:save), Label.SaveButton)
        )
      )

      @filterForm = VBox(
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
            VBox(
              Label(_("Access Type: ")),
              ReplacePoint(Id(:replace_aamode), PushButton(Id(:aamode), "R"))
            ),
            VBox(
              Label(_("Mode: ")),
              ReplacePoint(Id(:replace_mode), PushButton(Id(:mode), _("All")))
            ),
            #`HWeight( 3, `ReplacePoint(`id(`replace_aamode), `PushButton(`id(`aamode), _("Access Type: R") ))),
            #`HWeight( 3, `ReplacePoint(`id(`replace_mode), `PushButton(`id(`mode), _("Mode: All")  ))),
            HSpacing(Opt(:hstretch), 5)
          ),
          VSpacing(0.5),
          HBox(
            VSpacing(0.5),
            # DWR MOD `ComboBox(`id(`expType), `opt(`notify, `immediate), _("Export Type"),  [
            ComboBox(
              Id(:expType),
              Opt(:notify),
              _("Export Type"),
              [_("None"), _("csv"), _("html"), _("Both")]
            ),
            TextEntry(Id(:expPath), _("Location to store log."), @expPath),
            Bottom(VWeight(1, PushButton(Id(:browse), _("&Browse"))))
          )
        )
      )
    end

    def modeToHumanString(mode)
      mode == "All" ? _("All") : mode
    end

    def humanStringToMode(hs)
      hs == _("All") ? "All" : hs
    end

    def typeToHumanString(type)
      ret = ""

      case type
        when "Security.Incident.Report"
          ret = _("Security Incident Report")
        when "Applications.Audit"
          ret = _("Applications Audit Report")
        when "Executive.Security.Summary"
          ret = _("Executive Security Summary")
        else
          ret = type
      end

      ret
    end

    def humanStringToType(hs)
      ret = ""

      if hs == _("Security Incident Report")
        ret = "Security.Incident.Report"
      elsif hs == _("Applications Audit Report")
        ret = "Applications.Audit"
      elsif hs == _("Executive Security Summary")
        ret = "Executive.Security.Summary"
      else
        ret = hs
      end

      ret
    end

    # Grey out inappropriate paging buttons
    def setPageButtons(curPage, lastPage)
      if Ops.less_or_equal(lastPage, 1)
        UI.ChangeWidget(Id(:first), :Enabled, false)
        UI.ChangeWidget(Id(:last), :Enabled, false)
        UI.ChangeWidget(Id(:prev), :Enabled, false)
        UI.ChangeWidget(Id(:fwd), :Enabled, false)
        UI.ChangeWidget(Id(:goto), :Enabled, false)
      elsif Ops.less_or_equal(curPage, 1)
        UI.ChangeWidget(Id(:first), :Enabled, false)
        UI.ChangeWidget(Id(:prev), :Enabled, false)
      elsif Ops.greater_or_equal(curPage, lastPage)
        UI.ChangeWidget(Id(:last), :Enabled, false)
        UI.ChangeWidget(Id(:fwd), :Enabled, false)
      else
        UI.SetFocus(Id(:goto))
      end

      nil
    end

    # return input from edit scheduled forms as map of strings
    def getSchedSettings(_Settings)
      _Settings = deep_copy(_Settings)
      name = Convert.to_string(UI.QueryWidget(Id(:name), :Value))
      #integer iMonthdate = (integer) UI::QueryWidget(`id(`monthdate), `Value);
      md = UI.QueryWidget(Id(:monthdate), :Value)
      monthdate = Ops.get_locale(@md_map, md, _("All"))
      weekday = Convert.to_string(UI.QueryWidget(Id(:weekday), :Value))
      iHours = UI.QueryWidget(Id(:hour), :Value)
      iMins = UI.QueryWidget(Id(:mins), :Value)
      expType = Convert.to_string(UI.QueryWidget(Id(:expType), :Value))
      email1 = Convert.to_string(UI.QueryWidget(Id(:email1), :Value))
      email2 = Convert.to_string(UI.QueryWidget(Id(:email2), :Value))
      email3 = Convert.to_string(UI.QueryWidget(Id(:email3), :Value))

      #string monthdate = tostring( iMonthdate );
      hour = Builtins.tostring(iHours)
      mins = Builtins.tostring(iMins)

      weekday = "-" if weekday == _("All")
      monthdate = "-" if monthdate == _("All")

      # de-i18n
      weekday = "Mon" if weekday == _("Mon")
      weekday = "Tue" if weekday == _("Tue")
      weekday = "Weds" if weekday == _("Wed")
      weekday = "Thu" if weekday == _("Thu")
      weekday = "Fri" if weekday == _("Fri")
      weekday = "Sat" if weekday == _("Sat")
      weekday = "Sun" if weekday == _("Sun")

      Ops.set(_Settings, "getconf", "")
      Ops.set(_Settings, "setconf", "1")
      Ops.set(_Settings, "name", name)
      Ops.set(_Settings, "monthdate", monthdate)

      Ops.set(_Settings, "weekday", weekday)
      Ops.set(_Settings, "hour", hour)
      Ops.set(_Settings, "mins", mins)
      if expType == _("csv") || expType == _("Both")
        Ops.set(_Settings, "csv", "1")
      else
        Ops.set(_Settings, "csv", "0")
      end

      if expType == _("html") || expType == _("Both")
        Ops.set(_Settings, "html", "1")
      else
        Ops.set(_Settings, "html", "0")
      end

      Ops.set(_Settings, "email1", email1)
      Ops.set(_Settings, "email2", email2)
      Ops.set(_Settings, "email3", email3)

      deep_copy(_Settings)
    end

    # Gets list of archived reports based on 'type'
    def getArrayList(type, repPath)
      _Settings = {}
      readSched = "1"
      Ops.set(_Settings, "readSched", readSched)
      Ops.set(_Settings, "type", type)

      Ops.set(_Settings, "repPath", repPath) if repPath != ""

      itemList = []

      key = 1

      if type == "sirRep" || type == "essRep" || type == "audRep"
        db = Convert.convert(
          SCR.Read(path(".reports_parse"), _Settings),
          :from => "any",
          :to   => "list <map>"
        )

        Builtins.foreach(db) do |record|
          strName = Ops.get(record, "name")
          strTime = Ops.get(record, "time")
          name = Builtins.tostring(strName)
          mytime = Builtins.tostring(strTime)
          itemList = Builtins.add(
            itemList,
            Item(Id(key), Ops.get(record, "name"), Ops.get(record, "time"))
          )
          key = Ops.add(key, 1)
        end
      elsif type == "schedRep"
        Ops.set(_Settings, "getcron", "1")

        db = Convert.convert(
          SCR.Read(path(".reports_sched"), _Settings),
          :from => "any",
          :to   => "list <map>"
        )

        Builtins.foreach(db) do |record|
          itemList = Builtins.add(
            itemList,
            Item(
              Id(key),
              Ops.get(record, "name"),
              Ops.get(record, "hour"),
              Ops.get(record, "mins"),
              Ops.get(record, "wday"),
              Ops.get(record, "mday")
            )
          )
          key = Ops.add(key, 1)
        end
      else
        Popup.Error(_("Unrecognized form request."))
      end

      deep_copy(itemList)
    end


    # Filter form for editing scheduled reports
    def editFilterForm(_Settings)
      _Settings = deep_copy(_Settings)
      # debug
      prog = Ops.get_string(_Settings, "prog", "")
      prof = Ops.get_string(_Settings, "prof", "")
      pid = Ops.get_string(_Settings, "pid", "")
      res = Ops.get_string(_Settings, "res", "")
      aamode = Ops.get_string(_Settings, "aamode", "R")
      mode = Ops.get_string(_Settings, "mode", "All")
      sev = Ops.get_string(_Settings, "sev", "All")

      eForm = VBox(
        VSpacing(0.5),
        HBox(
          HWeight(5, TextEntry(Id(:prog), _("Program name"), prog)),
          HWeight(5, TextEntry(Id(:prof), _("Profile name"), prof)),
          HSpacing(Opt(:hstretch), 1)
        ),
        VSpacing(0.5),
        HBox(
          HWeight(5, TextEntry(Id(:pid), _("PID number"), pid)),
          HWeight(5, TextEntry(Id(:res), _("Detail"), res)),
          HSpacing(Opt(:hstretch), 1)
        ),
        VSpacing(0.5),
        HBox(
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
          VBox(
            Label(_("Access Type: ")),
            Bottom(
              HWeight(
                4,
                ReplacePoint(
                  Id(:replace_aamode),
                  PushButton(Id(:aamode), modeToHumanString(aamode))
                )
              )
            )
          ),
          VBox(
            Label(_("Mode: ")),
            Bottom(
              HWeight(
                4,
                ReplacePoint(
                  Id(:replace_mode),
                  PushButton(Id(:mode), modeToHumanString(mode))
                )
              )
            )
          ),
          HSpacing(Opt(:hstretch), 1)
        ),
        VSpacing(1),
        HBox(
          PushButton(Id(:cancel), Label.CancelButton),
          PushButton(Id(:save), Label.SaveButton)
        )
      )

      deep_copy(eForm)
    end

    # filter-defining form
    def filterForm2(name, preFilters)
      preFilters = deep_copy(preFilters)
      aprog = Ops.get(preFilters, "prog")
      aprof = Ops.get(preFilters, "profile")
      apid = Ops.get(preFilters, "pid")
      ares = Ops.get(preFilters, "resource")
      amode = Ops.get_string(preFilters, "mode", "All")
      aaamode = Ops.get_string(preFilters, "aamode", "All")

      prog = ""
      prof = ""
      pid = ""
      res = ""
      mode = ""
      aamode = ""

      prog = Builtins.tostring(aprog) if aprog != nil
      prof = Builtins.tostring(aprof) if aprof != nil
      pid = Builtins.tostring(apid) if apid != nil
      res = Builtins.tostring(ares) if ares != nil
      mode = Builtins.tostring(amode) if amode != nil
      aamode = Builtins.tostring(aaamode) if aaamode != nil
      aamode = "All" if aamode == "-"
      mode = "All" if mode == "-"

      ff2 = Top(
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
            HWeight(4, TextEntry(Id(:prog), _("Program name"), prog)),
            HWeight(4, TextEntry(Id(:prof), _("Profile name"), prof)),
            HWeight(3, TextEntry(Id(:pid), _("PID number"), pid)),
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
            VSpacing(0.5),
            TextEntry(Id(:res), _("Detail"), res),
            VBox(
              Label(_("Access Type: ")),
              ReplacePoint(
                Id(:replace_aamode),
                PushButton(Id(:aamode), modeToHumanString(aamode))
              )
            ),
            VBox(
              Label(_("Mode: ")),
              ReplacePoint(
                Id(:replace_mode),
                PushButton(Id(:mode), modeToHumanString(mode))
              )
            )
          ),
          VSpacing(0.5),
          HBox(
            VSpacing(0.5),
            ComboBox(
              Id(:expType),
              Opt(:notify),
              _("Export Type"),
              [_("None"), _("csv"), _("html"), _("Both")]
            ),
            TextEntry(Id(:expPath), _("Location to store log."), @expPath),
            Bottom(VWeight(1, PushButton(Id(:browse), _("&Browse"))))
          )
        )
      )

      deep_copy(ff2)
    end

    # Gets data for next or previous page of current report
    def turnReportPage(name, curPage, slastPage, _Settings)
      _Settings = deep_copy(_Settings)
      #map<string,string> Settings = $[ ];  - 07-07
      reportList = []

      currentPage = Builtins.tostring(curPage)
      Ops.set(_Settings, "name", name)
      Ops.set(_Settings, "page", currentPage)
      Ops.set(_Settings, "turnPage", "1")

      reportList = getReportList("sir", _Settings)

      # New map is a list, not a hash

      # Old aa-eventd
      #     list <map> db = (list <map>) SCR::Read (.logparse, Settings);
      #     integer key = 1;
      #     foreach ( map record, db, {
      #         reportList = add( reportList, `item( `id(key), record["host"]:nil,
      # 	record["date"]:nil, record["prog"]:nil, record["profile"]:nil,
      # 	record["pid"]:nil, record["severity"]:nil, record["mode"]:nil,
      # 	record["resource"]:nil, record["aamode"]:nil ));
      #         key = key + 1;
      #     });

      myLabel = Ops.add(
        Ops.add(
          Ops.add(_("On Demand Event Report - Page "), currentPage),
          _(" of ")
        ),
        slastPage
      )

      odForm = Frame(
        Id(:odpage),
        myLabel,
        VBox(
          #`Label("AppArmor Event Report Data " + currentPage ),
          #`Label(myLabel),
          HBox(
            VSpacing(10),
            # New aa-eventd
            makeSirTable(reportList),
            # Old aa-eventd
            # `Table(`id(`table), `opt(`keepSorting, `immediate ), `header( _("Host"), _("Date"), _("Program"),
            # 	_("Profile"), _("PID"), _("Severity"), _("Mode"), _("Detail"), _("Access Type") ), reportList),
            VSpacing(0.5)
          ),
          HSpacing(Opt(:hstretch), 1.0),
          VSpacing(0.5),
          HBox(
            PushButton(Id(:first), _("F&irst Page")),
            PushButton(Id(:prev), _("&Previous")),
            PushButton(Id(:psort), _("&Sort")),
            PushButton(Id(:fwd), _("&Forward")),
            PushButton(Id(:last), _("&Last Page")),
            PushButton(Id(:goto), _("&Go to Page"))
          ),
          VSpacing(1)
        )
      )

      deep_copy(odForm)
    end

    def reportConfigForm
      contents_report_config_form = VBox(
        VSpacing(1),
        Left(CheckBox(Id(:bydate), Opt(:notify), _("Filter By Date Range"))),
        Frame(
          Id(:bydate_frame),
          _(" Select Date Range "),
          VBox(
            Label(_("Enter Starting Date/Time")),
            HBox(
              HSpacing(Opt(:hstretch), 1),
              HWeight(1, TextEntry(Id(:start_time), _("Time"))),
              HSpacing(Opt(:hstretch), 1),
              HWeight(1, TextEntry(Id(:start_day), _("Day"))),
              HSpacing(Opt(:hstretch), 1),
              HWeight(1, TextEntry(Id(:start_month), _("Month"))),
              HSpacing(Opt(:hstretch), 1),
              HWeight(1, TextEntry(Id(:start_year), _("Year"))),
              HSpacing(Opt(:hstretch), 1)
            ),
            VSpacing(1.0),
            Label(_("Enter Ending Date")),
            HBox(
              HSpacing(Opt(:hstretch), 1),
              HWeight(1, TextEntry(Id(:end_time), _("Time"))),
              HSpacing(Opt(:hstretch), 1),
              HWeight(1, TextEntry(Id(:end_day), _("Day"))),
              HSpacing(Opt(:hstretch), 1),
              HWeight(1, TextEntry(Id(:end_month), _("Month"))),
              HSpacing(Opt(:hstretch), 1),
              HWeight(1, TextEntry(Id(:end_year), _("Year"))),
              HSpacing(Opt(:hstretch), 1),
              VSpacing(Opt(:vstretch), 2)
            )
          )
        ),
        VSpacing(0.5),
        Left(CheckBox(Id(:byprog), Opt(:notify), _("Filter By Program Name"))),
        HBox(
          Id(:pbox),
          Left(TextEntry(Id(:prog), _("Program name"))),
          HSpacing(Opt(:hstretch), 45)
        ),
        VSpacing(0.5),
        Left(CheckBox(Id(:expLog), Opt(:notify), _("Export Report"))),
        HBox(
          Id(:ebox),
          Left(TextEntry(Id(:exportName), _("Export File Location"))),
          Label(_("Select Export Format")),
          Left(CheckBox(Id(:exportText), _("CSV"), false)),
          Left(CheckBox(Id(:exportHtml), _("HTML"), true))
        )
      )
      Wizard.SetContentsButtons(
        _("Report Configuration Dialog"),
        contents_report_config_form,
        @repConfHelp,
        Label.BackButton,
        Label.NextButton
      )

      @Settings = {}
      event = {}
      id = nil
      UI.ChangeWidget(Id(:pbox), :Enabled, false)
      UI.ChangeWidget(Id(:ebox), :Enabled, false)
      UI.ChangeWidget(Id(:bydate_frame), :Enabled, false)
      UI.ChangeWidget(Id(:exportName), :Value, "/tmp/export.log")

      while true
        event = UI.WaitForEvent(@timeout_millisec)
        id = Ops.get(event, "ID") # We'll need this often - cache it

        start_day = Convert.to_integer(UI.QueryWidget(Id(:start_day), :Value))
        start_month = Convert.to_integer(
          UI.QueryWidget(Id(:start_month), :Value)
        )
        start_year = Convert.to_integer(UI.QueryWidget(Id(:start_year), :Value))
        end_day = Convert.to_integer(UI.QueryWidget(Id(:end_day), :Value))
        end_month = Convert.to_integer(UI.QueryWidget(Id(:end_month), :Value))
        end_year = Convert.to_integer(UI.QueryWidget(Id(:end_year), :Value))

        if id == :byprog
          val = Convert.to_boolean(UI.QueryWidget(Id(:byprog), :Value))
          if val == true
            UI.ChangeWidget(Id(:pbox), :Enabled, true)
            UI.ChangeWidget(Id(:allevents), :Value, false)
          else
            UI.ChangeWidget(Id(:pbox), :Enabled, false)
          end
        elsif id == :bydate
          val = Convert.to_boolean(UI.QueryWidget(Id(:bydate), :Value))
          if val == true
            UI.ChangeWidget(Id(:bydate_frame), :Enabled, true)
            UI.ChangeWidget(Id(:allevents), :Value, false)
          else
            UI.ChangeWidget(Id(:bydate_frame), :Enabled, false)
          end
        elsif id == :expLog
          val = Convert.to_boolean(UI.QueryWidget(Id(:expLog), :Value))
          if val == true
            UI.ChangeWidget(Id(:ebox), :Enabled, true) 
            #UI::ChangeWidget(`id(`allevents), `Value, false);
          else
            UI.ChangeWidget(Id(:ebox), :Enabled, false)
          end
        elsif id == :next
          # Setup the data structures.
          bydate = Convert.to_boolean(UI.QueryWidget(Id(:bydate), :Value))
          byprog = Convert.to_boolean(UI.QueryWidget(Id(:byprog), :Value))
          allevents = Convert.to_boolean(UI.QueryWidget(Id(:allevents), :Value))
          expLog = Convert.to_boolean(UI.QueryWidget(Id(:expLog), :Value))

          if expLog
            exportName = Convert.to_string(
              UI.QueryWidget(Id(:exportName), :Value)
            )
            expText = Convert.to_boolean(
              UI.QueryWidget(Id(:exportText), :Value)
            )
            expHtml = Convert.to_boolean(
              UI.QueryWidget(Id(:exportHtml), :Value)
            )
            exportText = Builtins.tostring(expText)
            exportHtml = Builtins.tostring(expHtml)
            Ops.set(@Settings, "exportname", exportName)
            Ops.set(@Settings, "exporttext", exportText)
            Ops.set(@Settings, "exporthtml", exportHtml)
          end

          if byprog
            program_name = Convert.to_string(UI.QueryWidget(Id(:prog), :Value))
            Ops.set(@Settings, "prog", program_name)
          end

          if bydate
            start_hour = Convert.to_integer(
              UI.QueryWidget(Id(:startHour), :Value)
            )
            start_min = Convert.to_integer(
              UI.QueryWidget(Id(:startMin), :Value)
            )
            startDay = Convert.to_integer(UI.QueryWidget(Id(:startDay), :Value))
            startMonth = Convert.to_integer(
              UI.QueryWidget(Id(:startMonth), :Value)
            )
            startYear = Convert.to_integer(
              UI.QueryWidget(Id(:startYear), :Value)
            )
            end_hour = Convert.to_integer(UI.QueryWidget(Id(:endHour), :Value))
            end_min = Convert.to_integer(UI.QueryWidget(Id(:endMin), :Value))
            endDay = Convert.to_integer(UI.QueryWidget(Id(:endDay), :Value))
            endMonth = Convert.to_integer(UI.QueryWidget(Id(:endMonth), :Value))
            endYear = Convert.to_integer(UI.QueryWidget(Id(:endYear), :Value))
            start_time = Ops.add(
              Ops.add(Builtins.tostring(start_hour), ":"),
              Builtins.tostring(start_min)
            )
            end_time = Ops.add(
              Ops.add(Builtins.tostring(end_hour), ":"),
              Builtins.tostring(end_min)
            )

            if CheckDate(startDay, startMonth, startYear) == false
              Popup.Error(_("Illegal start date entered. Retry."))
              next
            end

            if CheckDate(endDay, endMonth, endYear) == false
              Popup.Error(_("Illegal end date entered. Retry."))
              next
            end

            Ops.set(@Settings, "startday", Builtins.tostring(startDay))
            Ops.set(@Settings, "startmonth", Builtins.tostring(startMonth))
            Ops.set(@Settings, "startyear", Builtins.tostring(startYear))
            Ops.set(@Settings, "endday", Builtins.tostring(endDay))
            Ops.set(@Settings, "endmonth", Builtins.tostring(endMonth))
            Ops.set(@Settings, "endyear", Builtins.tostring(endYear))
            Ops.set(@Settings, "starttime", start_time)
            Ops.set(@Settings, "endtime", end_time)
          end
        elsif id == :abort || id == :back || id == :done
          Popup.Message(_("Abort or Back"))
          break
        end 

        #break;
      end
      Convert.to_symbol(id)
    end

    # Main Report Form
    def mainArchivedReportForm
      reportdata = nil
      reportdata = Convert.to_map(SCR.Read(path(".logparse"), @Settings))
      reportlist = []

      Builtins.foreach(
        Convert.convert(reportdata, :from => "map", :to => "map <integer, map>")
      ) do |key, repdata|
        reportlist = Builtins.add(
          reportlist,
          Item(
            Id(key),
            Ops.get(repdata, "date"),
            Ops.get(repdata, "prof"),
            Ops.get(repdata, "pid"),
            Ops.get(repdata, "mesg")
          )
        )
      end

      help1 = _(
        "<b>AppArmor Security Events</b><p>\nThis table displays the events that match your search criteria.\n"
      )


      # DBG y2milestone("in MainReportForm");
      contents_main_prof_form = VBox(
        Label(_("AppArmor Event Report Data")),
        HBox(
          VSpacing(10),
          Table(
            Id(:table),
            Opt(:notify, :immediate),
            Header(_("Date"), _("Profile"), _("PID"), _("AppArmor Message")),
            reportlist
          ),
          VSpacing(0.5)
        )
      )
      Wizard.SetContentsButtons(
        _("AppArmor Security Event Report"),
        contents_main_prof_form,
        help1,
        Label.BackButton,
        _("&Done")
      )


      event = {}
      id = nil
      while true
        event = UI.WaitForEvent(@timeout_millisec)
        id = Ops.get(event, "ID") # We'll need this often - cache it

        if id == :table
          if Ops.get(event, "EventReason") == "Activated"
            # Widget activated in the table
            itemselected = Convert.to_integer(
              UI.QueryWidget(Id(:table), :CurrentItem)
            )
          end
        elsif id == :abort || id == :cancel || id == :done
          break
        elsif id == :back || id == :next
          break
        else
          Builtins.y2error("Unexpected return code: %1", id)
          next
        end
      end
      Convert.to_symbol(id)
    end

    # This is the first and base reporting form
    def mainReportForm
      mainForm = VBox(
        Label(_("AppArmor Reporting")),
        VSpacing(2),
        VBox(
          Left(
            CheckBox(Id(:schedrep), Opt(:notify), _("Schedule Reports"), true)
          ),
          Left(CheckBox(Id(:viewrep), Opt(:notify), _("View Archived Reports"))),
          Left(CheckBox(Id(:runrep), Opt(:notify), _("Run Reports")))
        ),
        VSpacing(0.5)
      )

      Wizard.SetContentsButtons(
        _("AppArmor Security Event Report"),
        mainForm,
        @mainHelp,
        Label.BackButton,
        Label.NextButton
      )

      event = {}
      id = nil
      while true
        event = UI.WaitForEvent(@timeout_millisec)
        id = Ops.get(event, "ID") # We'll need this often - cache it

        if id == :schedrep
          UI.ChangeWidget(Id(:viewrep), :Value, false)
          UI.ChangeWidget(Id(:runrep), :Value, false)
        elsif id == :viewrep
          UI.ChangeWidget(Id(:schedrep), :Value, false)
          UI.ChangeWidget(Id(:runrep), :Value, false)
        elsif id == :runrep
          UI.ChangeWidget(Id(:schedrep), :Value, false)
          UI.ChangeWidget(Id(:viewrep), :Value, false)
        elsif id == :abort || id == :cancel || id == :done
          break
        elsif id == :back
          break
        elsif id == :next
          if UI.QueryWidget(Id(:schedrep), :Value) == true
            id = :schedrep
          elsif UI.QueryWidget(Id(:viewrep), :Value) == true
            id = :viewrep
          elsif UI.QueryWidget(Id(:runrep), :Value) == true
            id = :runrep
          end

          break
        else
          Builtins.y2error("Unexpected return code: %1", id)
          next
        end
      end

      Convert.to_symbol(id)
    end

    # Form used to select the type of archived report to list
    def viewForm(archType, itemList, repPath)
      archType = deep_copy(archType)
      itemList = deep_copy(itemList)
      sirRep = Ops.get_boolean(archType, "sirRep", false)
      audRep = Ops.get_boolean(archType, "audRep", false)
      essRep = Ops.get_boolean(archType, "essRep", false)

      if repPath == "" || repPath == nil
        repPath = "/var/log/apparmor/reports-archived/"
      end

      sirRep = true if audRep == false && essRep == false

      vForm = ReplacePoint(
        Id(:viewform),
        VBox(
          Label(_("View Archived Reports")),
          HSpacing(60), # make the table and thus the dialog wide enough
          VSpacing(1),
          HBox(
            Frame(
              Id(:radioSelect),
              _("Choose a Report Type"),
              RadioButtonGroup(
                Id(:chooseRep),
                HBox(
                  HStretch(),
                  RadioButton(
                    Id(:sirRep),
                    Opt(:notify, :immediate),
                    _("SIR"),
                    sirRep
                  ),
                  HSpacing(1),
                  RadioButton(
                    Id(:audRep),
                    Opt(:notify, :immediate),
                    _("App Aud"),
                    audRep
                  ),
                  HSpacing(1),
                  RadioButton(
                    Id(:essRep),
                    Opt(:notify, :immediate),
                    _("ESS"),
                    essRep
                  ),
                  HSpacing(1),
                  HStretch()
                )
              )
            )
          ),
          VSpacing(1),
          Frame(
            Id(:repFrame),
            _("Location of Archived Reports"),
            HBox(
              Left(Label(repPath)),
              HSpacing(1),
              Left(PushButton(Id(:browse), _("&Browse"))),
              HStretch()
            )
          ),
          VSpacing(0.5),
          VWeight(
            10,
            HBox(
              VSpacing(1),
              Table(
                Id(:table),
                Opt(:notify, :immediate),
                Header(_("Report"), _("Date")),
                itemList
              )
            )
          ),
          VSpacing(1),
          HBox(
            VSpacing(1),
            PushButton(Id(:view), _("&View")),
            PushButton(Id(:viewall), _("View &All"))
          )
        )
      )

      deep_copy(vForm)
    end

    def filterConfigForm(name)
      # Cheating way to set filters
      opts = {}
      Ops.set(opts, "getSirFilters", "1")
      Ops.set(opts, "name", name)
      Ops.set(opts, "gui", "1")
      preFilters = {}
      preFilters = Convert.to_map(SCR.Read(path(".logparse"), opts))

      asev = Ops.get(preFilters, "severity")
      sev = ""
      sev = Builtins.tostring(asev) if asev != nil
      sev = _("All") if sev == "-"

      Wizard.SetContentsButtons(
        _("Report Configuration Dialog"),
        filterForm2(name, preFilters),
        @filterCfHelp1,
        Label.BackButton,
        Label.NextButton
      )

      if sev != "" && sev != _("All")
        if sev != "U"
          isev = Builtins.tointeger(sev)
          sev = Ops.add("0", sev) if Ops.less_than(isev, 10)
        end

        UI.ChangeWidget(Id(:sev), :Value, sev)
      end

      mode = "All"
      aamode = "R"

      @Settings = {}
      event = {}
      id = nil
      UI.ChangeWidget(Id(:bydate_frame), :Enabled, false)

      while true
        event = UI.WaitForEvent(@timeout_millisec)
        id = Ops.get(event, "ID")

        if id == :bydate
          val = Convert.to_boolean(UI.QueryWidget(Id(:bydate), :Value))
          if val == true
            UI.ChangeWidget(Id(:bydate_frame), :Enabled, true)
          else
            UI.ChangeWidget(Id(:bydate_frame), :Enabled, false)
          end
        elsif id == :abort || id == :done || id == :cancel
          Ops.set(@Settings, "break", "abort")
          break
        elsif id == :back
          Ops.set(@Settings, "break", "back")
          break
        elsif id == :aamode
          aamode = popUpSdMode

          if aamode != ""
            Ops.set(@Settings, "aamode", aamode)
            UI.ReplaceWidget(
              Id(:replace_aamode),
              PushButton(Id(:aamode), modeToHumanString(aamode))
            )
          end
        elsif id == :mode
          mode = popUpMode

          if mode != ""
            Ops.set(@Settings, "mode", mode)
            UI.ReplaceWidget(
              Id(:replace_mode),
              PushButton(Id(:mode), modeToHumanString(mode))
            )
          end
        elsif id == :browse
          selectFile = ""
          selectFile = UI.AskForExistingDirectory("/", _("Select Directory"))

          UI.ChangeWidget(Id(:expPath), :Value, selectFile) if selectFile != nil

          Ops.set(@Settings, "expPath", @expPath)
        elsif id == :save || id == :next
          # Setup the data structures.
          bydate = Convert.to_boolean(UI.QueryWidget(Id(:bydate), :Value))
          expText = false
          expHtml = false

          if UI.QueryWidget(Id(:expLog), :Enabled) == true
            expText = Convert.to_boolean(
              UI.QueryWidget(Id(:exportText), :Value)
            )
            expHtml = Convert.to_boolean(
              UI.QueryWidget(Id(:exportHtml), :Value)
            )
          end

          Ops.set(@Settings, "exporttext", "true") if expText == true
          Ops.set(@Settings, "exporthtml", "true") if expHtml == true

          program_name = Convert.to_string(UI.QueryWidget(Id(:prog), :Value))
          profile = Convert.to_string(UI.QueryWidget(Id(:prof), :Value))
          pid = Convert.to_string(UI.QueryWidget(Id(:pid), :Value))
          sev2 = Convert.to_string(UI.QueryWidget(Id(:sev), :Value))
          res = Convert.to_string(UI.QueryWidget(Id(:res), :Value))
          aamode2 = Convert.to_string(UI.QueryWidget(Id(:aamode), :Label))
          mode2 = Convert.to_string(UI.QueryWidget(Id(:mode), :Label))
          exppath = Convert.to_string(UI.QueryWidget(Id(:expPath), :Value))

          # de-i18n
          sev2 = "All" if sev2 == _("All")
          sev2 = "U" if sev2 == _("U")

          Ops.set(@Settings, "exportPath", expPath) if exppath != ""
          Ops.set(@Settings, "prog", program_name) if program_name != ""
          Ops.set(@Settings, "profile", profile) if profile != ""
          Ops.set(@Settings, "pid", pid) if pid != ""
          Ops.set(@Settings, "severity", sev2) if sev2 != "" && sev2 != "All"
          Ops.set(@Settings, "resource", res) if res != ""
          if aamode2 != ""
            Ops.set(@Settings, "aamode", humanStringToMode(aamode2))
          end
          Ops.set(@Settings, "mode", humanStringToMode(mode2)) if mode2 != ""

          if bydate == true
            start_hour = Convert.to_integer(
              UI.QueryWidget(Id(:startHour), :Value)
            )
            start_min = Convert.to_integer(
              UI.QueryWidget(Id(:startMin), :Value)
            )
            startDay = Convert.to_integer(UI.QueryWidget(Id(:startDay), :Value))
            startMonth = Convert.to_integer(
              UI.QueryWidget(Id(:startMonth), :Value)
            )
            startYear = Convert.to_integer(
              UI.QueryWidget(Id(:startYear), :Value)
            )
            end_hour = Convert.to_integer(UI.QueryWidget(Id(:endHour), :Value))
            end_min = Convert.to_integer(UI.QueryWidget(Id(:endMin), :Value))
            endDay = Convert.to_integer(UI.QueryWidget(Id(:endDay), :Value))
            endMonth = Convert.to_integer(UI.QueryWidget(Id(:endMonth), :Value))
            endYear = Convert.to_integer(UI.QueryWidget(Id(:endYear), :Value))

            start_time = Ops.add(
              Ops.add(Builtins.tostring(start_hour), ":"),
              Builtins.tostring(start_min)
            )
            end_time = Ops.add(
              Ops.add(Builtins.tostring(end_hour), ":"),
              Builtins.tostring(end_min)
            )

            if CheckDate(startDay, startMonth, startYear) == false
              Popup.Error(_("Illegal start date entered. Retry."))
              next
            end

            if CheckDate(endDay, endMonth, endYear) == false
              Popup.Error(_("Illegal end date entered. Retry."))
              next
            end

            start_day = Builtins.tostring(startDay)
            start_month = Builtins.tostring(startMonth)
            start_year = Builtins.tostring(startYear)
            end_day = Builtins.tostring(endDay)
            end_month = Builtins.tostring(endMonth)
            end_year = Builtins.tostring(endYear)

            Ops.set(@Settings, "startday", Builtins.tostring(start_day))
            Ops.set(@Settings, "startmonth", Builtins.tostring(start_month))
            Ops.set(@Settings, "startyear", Builtins.tostring(start_year))
            Ops.set(@Settings, "endday", Builtins.tostring(end_day))
            Ops.set(@Settings, "endmonth", Builtins.tostring(end_month))
            Ops.set(@Settings, "endyear", Builtins.tostring(end_year))
            Ops.set(@Settings, "starttime", start_time)
            Ops.set(@Settings, "endtime", end_time)
          end

          expType = Convert.to_string(UI.QueryWidget(Id(:expType), :Value))
          expPath = Convert.to_string(UI.QueryWidget(Id(:expPath), :Value))

          if expType == _("csv")
            Ops.set(@Settings, "exporttext", "1")
          elsif expType == _("html")
            Ops.set(@Settings, "exporthtml", "1")
          elsif expType == _("Both")
            Ops.set(@Settings, "exporttext", "1")
            Ops.set(@Settings, "exporthtml", "1")
          end

          Ops.set(@Settings, "exportPath", expPath)

          break
        end
      end

      deep_copy(@Settings)
    end

    def displayEmptyRep(type)
      myLabel = ""
      myInfo = ""

      if type == "noDb"
        myLabel = _("Events DB Not Initialized.")
        myInfo = _(
          "The events database has not been populated.  No records exist."
        )
      elsif type == "noList"
        myLabel = _("Query Returned Empty List.")
        myInfo = _(
          "The events database has no records that match the search query."
        )
      end

      newPage = Frame(
        Id(:newpage),
        myLabel,
        VBox(
          #`Label(myLabel),
          HBox(VSpacing(10), Label(myInfo), VSpacing(0.5)),
          HSpacing(Opt(:hstretch), 1.0),
          VSpacing(1)
        )
      )


      deep_copy(newPage)
    end

    def displayRep(type, curPage, slastPage, reportList)
      reportList = deep_copy(reportList)
      myLabel = ""
      currentPage = Builtins.tostring(curPage)
      myTable = nil

      if type == "onDemand" || type == "sir"
        # Very poor i18n here
        myLabel = Ops.add(
          Ops.add(
            Ops.add(_("On Demand Event Report - Page "), currentPage),
            _(" of ")
          ),
          slastPage
        )
        myTable = makeSirTable(reportList)
      elsif type == "archRep"
        myLabel = Ops.add(
          Ops.add(
            Ops.add(_("Archived Event Report - Page "), currentPage),
            _(" of ")
          ),
          slastPage
        )
        myTable = makeSirTable(reportList)
      elsif type == "aud" || type == "audRep"
        myLabel = _("Applications Audit Report")
        myTable = Table(
          Id(:table),
          Opt(:notify, :immediate),
          Header(
            _("Host"),
            _("Date"),
            _("Program"),
            _("Profile"),
            _("PID"),
            _("State"),
            _("Type")
          ),
          reportList
        )
      elsif type == "ess" || type == "essRep"
        if reportList == nil
          myLabel = _("Executive Security Summary")
          myTable = Table(
            Id(:table),
            Opt(:notify),
            Header(_("Query Results")),
            _("No event information exists.")
          )
        else
          myLabel = _("Executive Security Summary")
          myTable = Table(
            Id(:table),
            Opt(:notify, :immediate),
            Header(
              _("Host"),
              _("Start Date"),
              _("End Date"),
              _("Num Rejects"),
              _("Num Events"),
              _("Ave. Sev"),
              _("High Sev")
            ),
            reportList
          )
        end
      end

      newPage = Frame(
        Id(:newpage),
        myLabel,
        VBox(
          HBox(VSpacing(10), myTable, VSpacing(0.5)),
          HSpacing(Opt(:hstretch), 1.0),
          VSpacing(0.5),
          HBox(
            PushButton(Id(:first), _("F&irst Page")),
            PushButton(Id(:prev), _("&Previous")),
            PushButton(Id(:psort), _("&Sort")),
            PushButton(Id(:fwd), _("&Forward")),
            PushButton(Id(:last), _("&Last Page")),
            PushButton(Id(:goto), _("&Go to Page"))
          ),
          VSpacing(1)
        )
      )

      deep_copy(newPage)
    end


    # View Archived Reports
    def displayArchForm
      archType = {}
      Ops.set(archType, "sirRep", true)
      Ops.set(archType, "audRep", false)
      Ops.set(archType, "essRep", false)

      _Settings = {}
      readSched = "1"
      Ops.set(_Settings, "getcron", "0")
      Ops.set(_Settings, "readSched", "1")
      Ops.set(_Settings, "type", "sirRep")
      type = Ops.get(_Settings, "type")

      itemList = []
      itemList = getArrayList(type, "")

      Wizard.SetContentsButtons(
        _("AppArmor Security Event Report"),
        viewForm(archType, itemList, ""),
        @archHelpText,
        Label.BackButton,
        _("&Done")
      )

      event = {}
      archId = nil

      repPath = ""
      lastPage = 1
      curPage = 1

      formHelp = @runHelp


      while true
        event = UI.WaitForEvent

        archId = Ops.get(event, "ID") # We'll need this often - cache it

        if archId == :back || archId == :abort || archId == :done
          break
        elsif archId == :close || archId == :cancel || archId == :next
          break
        elsif archId == :repPath
          repPath = Convert.to_string(UI.QueryWidget(Id(:repPath), :Value))
          Ops.set(_Settings, "repPath", repPath)
          itemList = getArrayList(type, repPath)
          Wizard.SetContentsButtons(
            _("AppArmor Security Event Report"),
            viewForm(archType, itemList, repPath),
            @archHelpText,
            Label.BackButton,
            _("&Done")
          )
        elsif archId == :browse
          selectFile = ""
          selectFile = UI.AskForExistingDirectory("/", _("Select Directory"))

          if selectFile != nil
            UI.ChangeWidget(Id(:repPath), :Value, selectFile)
            # set new reppath
            repPath = selectFile
            Ops.set(_Settings, "repPath", repPath)
            itemList = getArrayList(type, repPath)
            Wizard.SetContentsButtons(
              _("AppArmor Security Event Report"),
              viewForm(archType, itemList, repPath),
              @archHelpText,
              Label.BackButton,
              _("&Done")
            )
          end
        elsif archId == :sirRep
          formHelp = @sirHelp
          Ops.set(archType, "sirRep", true)
          Ops.set(archType, "audRep", false)
          Ops.set(archType, "essRep", false)
          Ops.set(_Settings, "type", "sirRep")
          type = Ops.get(_Settings, "type")

          itemList = getArrayList(type, repPath)

          Wizard.SetContentsButtons(
            _("View Archived SIR Report"),
            viewForm(archType, itemList, ""),
            formHelp,
            Label.BackButton,
            _("&Done")
          )
        elsif archId == :audRep
          formHelp = @audHelp
          Ops.set(archType, "sirRep", false)
          Ops.set(archType, "audRep", true)
          Ops.set(archType, "essRep", false)
          Ops.set(_Settings, "type", "audRep")
          type = Ops.get(_Settings, "type")

          itemList = getArrayList(type, "")
          Wizard.SetContentsButtons(
            _("View Archived AUD Report"),
            viewForm(archType, itemList, ""),
            formHelp,
            Label.BackButton,
            _("&Done")
          )
        elsif archId == :essRep
          formHelp = @essHelp
          Ops.set(archType, "sirRep", false)
          Ops.set(archType, "audRep", false)
          Ops.set(archType, "essRep", true)
          Ops.set(_Settings, "type", "essRep")
          type = Ops.get(_Settings, "type")

          itemList = getArrayList(type, "")
          Wizard.SetContentsButtons(
            _("View Archived ESS Report"),
            viewForm(archType, itemList, ""),
            formHelp,
            Label.BackButton,
            _("&Done")
          )
        elsif archId == :view || archId == :viewall || archId == :table
          if archId == :viewall
            Ops.set(_Settings, "single", "0")
          else
            Ops.set(_Settings, "single", "1")
          end

          itemselected = Convert.to_integer(
            UI.QueryWidget(Id(:table), :CurrentItem)
          )
          logFile = Ops.get_string(
            Convert.to_term(
              UI.QueryWidget(Id(:table), term(:Item, itemselected))
            ),
            1,
            ""
          )
          logPath = Convert.to_string(UI.QueryWidget(Id(:repPath), :Value))
          splitPath = Builtins.splitstring(logPath, "/")
          checkPath = Ops.get_string(
            splitPath,
            Ops.subtract(Builtins.size(splitPath), 1),
            ""
          )

          longLogName = ""


          # Cat strings & check for trailing "/" in path
          if logPath != ""
            if checkPath != ""
              longLogName = Ops.add(Ops.add(logPath, "/"), logFile)
            else
              longLogName = Ops.add(logPath, logFile)
            end
          end

          if type == "sirRep"
            formHelp = @sirHelp
            sirSettings = nil
            sirSettings = setArchFilter
            Ops.set(sirSettings, "single", 0) if archId == :viewall

            # Force an exit if appropriate
            breakCheck = Ops.get(sirSettings, "break")

            if breakCheck == "abort"
              myBreak = :abort
              return myBreak
            elsif breakCheck == "back"
              myBreak = :back
              return myBreak
            end

            Ops.set(sirSettings, "repPath", repPath) if repPath != ""

            Wizard.SetContentsButtons(
              _("Security Incident Report"),
              viewArchForm(type, logFile, sirSettings),
              @sirHelp,
              Label.BackButton,
              _("&Done")
            )

            lastPage = getLastPage(type, _Settings, "") # check 'name'
            setPageButtons(curPage, lastPage)
          elsif type == "audRep"
            formHelp = @audHelp
            reportList = []
            key = 1
            Ops.set(_Settings, "page", "1")
            Ops.set(_Settings, "audArch", "1")
            Ops.set(_Settings, "turnPage", "1")
            Ops.set(_Settings, "file", logFile)

            db = Convert.convert(
              SCR.Read(path(".reports_confined"), _Settings),
              :from => "any",
              :to   => "list <map>"
            )

            Builtins.foreach(db) do |repdata|
              reportList = Builtins.add(
                reportList,
                Item(
                  Id(key),
                  Ops.get(repdata, "host"),
                  Ops.get(repdata, "date"),
                  Ops.get(repdata, "prog"),
                  Ops.get(repdata, "prof"),
                  Ops.get(repdata, "pid"),
                  Ops.get(repdata, "state"),
                  Ops.get(repdata, "type")
                )
              )
              key = Ops.add(key, 1)
            end

            lastPage = getLastPage(type, _Settings, "")
            slastPage = Builtins.tostring(lastPage)

            Wizard.SetContentsButtons(
              _("Applications Audit Report"),
              displayRep(type, curPage, slastPage, reportList),
              formHelp,
              Label.BackButton,
              _("&Done")
            )
            setPageButtons(curPage, lastPage)
          elsif type == "essRep"
            formHelp = @essHelp
            reportList = []
            key = 1
            Ops.set(_Settings, "file", logFile)
            Ops.set(_Settings, "essArch", "1")

            db = Convert.convert(
              SCR.Read(path(".reports_ess"), _Settings),
              :from => "any",
              :to   => "list <map>"
            )

            Builtins.foreach(db) do |repdata|
              reportList = Builtins.add(
                reportList,
                Item(
                  Id(key),
                  Ops.get(repdata, "host"),
                  Ops.get(repdata, "startdate"),
                  Ops.get(repdata, "enddate"),
                  Ops.get(repdata, "numRejects"),
                  Ops.get(repdata, "numEvents"),
                  Ops.get(repdata, "sevMean"),
                  Ops.get(repdata, "sevHi")
                )
              )
              key = Ops.add(key, 1)
            end

            lastPage = getLastPage(type, _Settings, "")
            slastPage = Builtins.tostring(lastPage)

            Wizard.SetContentsButtons(
              _("Executive Security Summary Report"),
              displayRep(type, curPage, slastPage, reportList),
              formHelp,
              Label.BackButton,
              _("&Done")
            )
            setPageButtons(curPage, lastPage)
          else
            Popup.Error(_("No recognized report type selected.  Try again."))
            next
          end
        elsif archId == :goto
          newPage = popUpGoto(lastPage)

          if Ops.greater_than(newPage, 0) &&
              Ops.less_or_equal(newPage, lastPage) &&
              newPage != curPage
            curPage = newPage

            fwdForm = turnArchReportPage(curPage, lastPage)
            Wizard.SetContentsButtons(
              _("AppArmor Report"),
              fwdForm,
              @runHelp,
              Label.BackButton,
              _("&Done")
            )
            setPageButtons(curPage, lastPage)
          end
        elsif archId == :psort
          sortKey = popUpSort(type)

          if sortKey != nil && sortKey != ""
            curPage = 1
            sortCmd = {}
            Ops.set(sortCmd, "sortKey", sortKey)
            Ops.set(sortCmd, "sort", "1")
            junk = SCR.Write(path(".logparse"), sortCmd)
            fwdForm = turnArchReportPage(curPage, lastPage)
            Wizard.SetContentsButtons(
              _("AppArmor Report"),
              fwdForm,
              @runHelp,
              Label.BackButton,
              _("&Done")
            )
            setPageButtons(curPage, lastPage)
          end
        elsif archId == :fwd
          curPage = Ops.add(curPage, 1)
          fwdForm = turnArchReportPage(curPage, lastPage)
          Wizard.SetContentsButtons(
            _("AppArmor Report"),
            fwdForm,
            formHelp,
            Label.BackButton,
            _("&Done")
          )

          setPageButtons(curPage, lastPage)
        elsif archId == :prev
          curPage = Ops.subtract(curPage, 1) if Ops.greater_than(curPage, 0)
          prevForm = turnArchReportPage(curPage, lastPage)
          Wizard.SetContentsButtons(
            _("AppArmor Report"),
            prevForm,
            formHelp,
            Label.BackButton,
            _("&Done")
          )

          setPageButtons(curPage, lastPage)
        elsif archId == :first
          curPage = 1
          firstForm = turnArchReportPage(curPage, lastPage)
          Wizard.SetContentsButtons(
            _("AppArmor Report"),
            firstForm,
            formHelp,
            Label.BackButton,
            _("&Done")
          )
          setPageButtons(curPage, lastPage)
        elsif archId == :last
          curPage = lastPage
          lastForm = turnArchReportPage(curPage, lastPage)
          Wizard.SetContentsButtons(
            _("AppArmor Report"),
            lastForm,
            formHelp,
            Label.BackButton,
            _("&Done")
          )
          setPageButtons(curPage, lastPage)
        else
          Builtins.y2error("Unexpected return code: %1", archId)
          next
        end 
        #break;
      end

      archId = :back if archId != :back && archId != :abort && archId != :done

      Convert.to_symbol(archId)
    end

    # The main form for On-Demand reports, executed from the wizard by selecting 'Run Now'
    def displayRunForm
      itemselected = Convert.to_integer(
        UI.QueryWidget(Id(:table), :CurrentItem)
      )
      name = humanStringToType(
        Ops.get_string(
          Convert.to_term(UI.QueryWidget(Id(:table), term(:Item, itemselected))),
          1,
          ""
        )
      )

      type = ""

      if name == "Security.Incident.Report"
        type = "sir"
      elsif name == "Applications.Audit"
        type = "aud"
      elsif name == "Executive.Security.Summary"
        type = "ess"
      else
        type = "sir" # All added reports are SIRs
      end

      if type != "aud"
        dbActivated = checkEventDb
        type = "noDb" if dbActivated == false
      end

      reportList = []
      _Settings = {}
      curPage = 1
      lastPage = 1
      slastPage = "1"

      formHelp = @runHelp
      reportdata = nil

      if type == "sir"
        _Settings = filterConfigForm(name)

        # Force an exit if appropriate
        breakCheck = Ops.get(_Settings, "break")

        if breakCheck == "abort"
          myBreak = :abort
          return myBreak
        elsif breakCheck == "back"
          myBreak = :back
          return myBreak
        end

        formHelp = @sirHelp
        Ops.set(_Settings, "type", "onDemand")
        Ops.set(_Settings, "turnPage", "0")

        reportList = getReportList("sir", _Settings)
        listSize = Builtins.size(reportList)
        type = "noList" if Ops.less_than(listSize, 1)
      elsif type == "aud"
        formHelp = @audHelp
        Ops.set(_Settings, "type", "onDemand")
        Ops.set(_Settings, "turnPage", "0")

        db = Convert.convert(
          SCR.Read(path(".reports_confined"), _Settings),
          :from => "any",
          :to   => "list <map>"
        )

        key = 1

        Builtins.foreach(db) do |repdata|
          reportList = Builtins.add(
            reportList,
            Item(
              Id(key),
              Ops.get(repdata, "host"),
              Ops.get(repdata, "date"),
              Ops.get(repdata, "prog"),
              Ops.get(repdata, "prof"),
              Ops.get(repdata, "pid"),
              Ops.get(repdata, "state"),
              Ops.get(repdata, "type")
            )
          )
          key = Ops.add(key, 1)
        end
      elsif type == "ess"
        formHelp = @essHelp
        Ops.set(_Settings, "type", "onDemand")
        Ops.set(_Settings, "turnPage", "0")
        db = Convert.convert(
          SCR.Read(path(".reports_ess"), _Settings),
          :from => "any",
          :to   => "list <map>"
        )

        if db != nil
          key = 1

          Builtins.foreach(db) do |repdata|
            reportList = Builtins.add(
              reportList,
              Item(
                Id(key),
                Ops.get(repdata, "host"),
                Ops.get(repdata, "startdate"),
                Ops.get(repdata, "enddate"),
                Ops.get(repdata, "numRejects"),
                Ops.get(repdata, "numEvents"),
                Ops.get(repdata, "sevMean"),
                Ops.get(repdata, "sevHi")
              )
            )
            key = Ops.add(key, 1)
          end
        end
      end

      if type == "noDb"
        Wizard.SetContentsButtons(
          _("AppArmor On-Demand Report"),
          displayEmptyRep(type),
          formHelp,
          Label.BackButton,
          _("&Done")
        )
      elsif type == "noList"
        Wizard.SetContentsButtons(
          _("AppArmor On-Demand Report"),
          displayEmptyRep(type),
          formHelp,
          Label.BackButton,
          _("&Done")
        )
      else
        lastPage = getLastPage(type, _Settings, name)
        slastPage = Builtins.tostring(lastPage)

        Wizard.SetContentsButtons(
          _("AppArmor On-Demand Report"),
          displayRep(type, curPage, slastPage, reportList),
          formHelp,
          Label.BackButton,
          _("&Done")
        )
        setPageButtons(curPage, lastPage)
      end

      event = {}
      id = nil

      while true
        # Grey out inappropriate paging buttons
        if Ops.less_or_equal(curPage, 1)
          UI.ChangeWidget(Id(:prev), :Enabled, false)
        elsif Ops.greater_or_equal(curPage, lastPage)
          UI.ChangeWidget(Id(:fwd), :Enabled, false)
        end

        event = UI.WaitForEvent(@timeout_millisec)
        id = Ops.get(event, "ID") # We'll need this often - cache it

        # REDO
        if id == :schedrep
          break
        elsif id == :abort || id == :cancel || id == :back || id == :done
          break
        elsif id == :next
          break
        elsif id == :goto
          newPage = popUpGoto(lastPage)

          if Ops.greater_than(newPage, 0) &&
              Ops.less_or_equal(newPage, lastPage) &&
              newPage != curPage
            curPage = newPage

            goForm = turnReportPage(name, curPage, slastPage, _Settings)
            Wizard.SetContentsButtons(
              _("AppArmor - Run Reports"),
              goForm,
              formHelp,
              Label.BackButton,
              _("&Done")
            )
            setPageButtons(curPage, lastPage)
          end
        elsif id == :psort
          sortKey = popUpSort(type)

          if sortKey != nil && sortKey != ""
            # branch added 08.01.2005
            curPage = 1
            Ops.set(_Settings, "type", "onDemand")
            Ops.set(_Settings, "turnPage", "0")
            Ops.set(_Settings, "sortKey", sortKey)

            reportList = getReportList(type, _Settings)

            Wizard.SetContentsButtons(
              _("AppArmor On-Demand Report"),
              displayRep(type, curPage, slastPage, reportList),
              formHelp,
              Label.BackButton,
              _("&Done")
            )
            setPageButtons(curPage, lastPage)
          end
        elsif id == :prev
          curPage = Ops.subtract(curPage, 1) if Ops.greater_than(curPage, 0)
          prevForm = turnReportPage(name, curPage, slastPage, _Settings)
          Wizard.SetContentsButtons(
            _("AppArmor - Run Reports"),
            prevForm,
            formHelp,
            Label.BackButton,
            _("&Done")
          )
          setPageButtons(curPage, lastPage)
        elsif id == :fwd
          curPage = Ops.add(curPage, 1)
          fwdForm = turnReportPage(name, curPage, slastPage, _Settings)
          Wizard.SetContentsButtons(
            _("AppArmor - Run Reports"),
            fwdForm,
            formHelp,
            Label.BackButton,
            _("&Done")
          )
          setPageButtons(curPage, lastPage)
        elsif id == :first
          curPage = 1
          slastPage = Builtins.tostring(lastPage)
          firstForm = turnReportPage(name, curPage, slastPage, _Settings)
          Wizard.SetContentsButtons(
            _("AppArmor - Run Reports"),
            firstForm,
            formHelp,
            Label.BackButton,
            _("&Done")
          )
          setPageButtons(curPage, lastPage)
        elsif id == :last
          curPage = lastPage
          slastPage = Builtins.tostring(lastPage)
          lastForm = turnReportPage(name, curPage, slastPage, _Settings)
          Wizard.SetContentsButtons(
            _("AppArmor - Run Reports"),
            lastForm,
            formHelp,
            Label.BackButton,
            _("&Done")
          )
          setPageButtons(curPage, lastPage)
        else
          Builtins.y2error("Unexpected return code: %1", id)
          next
        end
      end

      type = ""
      Convert.to_symbol(id)
    end

    def addSchedForm
      _Settings = {}
      readSched = "1"
      Ops.set(_Settings, "getcron", "1")
      Ops.set(_Settings, "readSched", "1")
      Ops.set(_Settings, "type", "schedRep")

      expPath = "/var/log/apparmor/reports-exported"

      UI.OpenDialog(
        ReplacePoint(
          Id(:addSchedRep),
          VBox(
            Label(_("Add Scheduled SIR")),
            VSpacing(1),
            TextEntry(Id(:name), _("Report Name")),
            VSpacing(1),
            HBox(
              ComboBox(
                Id(:monthdate),
                Opt(:notify),
                _("Day of Month"),
                [
                  Item(Id(:md_00), _("All")),
                  Item(Id(:md_01), "1"),
                  Item(Id(:md_02), "2"),
                  Item(Id(:md_03), "3"),
                  Item(Id(:md_04), "4"),
                  Item(Id(:md_05), "5"),
                  Item(Id(:md_06), "6"),
                  Item(Id(:md_07), "7"),
                  Item(Id(:md_08), "8"),
                  Item(Id(:md_09), "9"),
                  Item(Id(:md_10), "10"),
                  Item(Id(:md_11), "9"),
                  Item(Id(:md_12), "12"),
                  Item(Id(:md_13), "13"),
                  Item(Id(:md_14), "14"),
                  Item(Id(:md_15), "15"),
                  Item(Id(:md_16), "16"),
                  Item(Id(:md_17), "17"),
                  Item(Id(:md_18), "18"),
                  Item(Id(:md_19), "19"),
                  Item(Id(:md_20), "20"),
                  Item(Id(:md_21), "21"),
                  Item(Id(:md_22), "22"),
                  Item(Id(:md_23), "23"),
                  Item(Id(:md_24), "24"),
                  Item(Id(:md_25), "25"),
                  Item(Id(:md_26), "26"),
                  Item(Id(:md_27), "27"),
                  Item(Id(:md_28), "28"),
                  Item(Id(:md_29), "29"),
                  Item(Id(:md_30), "30"),
                  Item(Id(:md_31), "31")
                ]
              ),
              ComboBox(
                Id(:weekday),
                Opt(:notify),
                _("Day of Week"),
                [
                  _("All"),
                  _("Sun"),
                  _("Mon"),
                  _("Tue"),
                  _("Wed"),
                  _("Thu"),
                  _("Fri"),
                  _("Sat")
                ]
              ),
              IntField(Id(:hour), _("Hour"), 0, 23, 0),
              IntField(Id(:mins), _("Minute"), 0, 59, 0)
            ),
            VSpacing(1),
            HBox(
              VSpacing(1),
              TextEntry(Id(:email1), Opt(:notify), _("Email Target 1"), ""),
              TextEntry(Id(:email2), Opt(:notify), _("Email Target 2"), ""),
              TextEntry(Id(:email3), Opt(:notify), _("Email Target 3"), "")
            ),
            VSpacing(1),
            HBox(
              VSpacing(0.5),
              ComboBox(
                Id(:expType),
                Opt(:notify),
                _("Export Type"),
                [_("None"), _("csv"), _("html"), _("Both")]
              ),
              TextEntry(Id(:expPath), _("Location to store log."), expPath),
              Bottom(VWeight(1, PushButton(Id(:browse), _("&Browse"))))
            ),
            VSpacing(1),
            HBox(
              PushButton(Id(:cancel), Label.CancelButton),
              PushButton(Id(:next), Label.NextButton)
            )
          )
        )
      )

      mode = "All"
      aamode = "R"
      timeout_millisec = 20 * 1000
      event = {}
      addInput = nil

      while true
        event = UI.WaitForEvent(timeout_millisec)
        addInput = Ops.get(event, "ID") # We'll need this often - cache it


        if addInput == :monthdate && addInput != 0
          UI.ChangeWidget(Id(:weekday), :Value, _("All"))
        elsif addInput == :weekday && addInput != _("All")
          UI.ChangeWidget(Id(:monthdate), :Value, _("All"))
        end

        if addInput == :next
          # Check for valid path
          expPath = Convert.to_string(UI.QueryWidget(Id(:expPath), :Value))
          fileTest = {}
          Ops.set(fileTest, "checkFile", "1")
          Ops.set(fileTest, "file", expPath)

          pathExists = SCR.Read(path(".reports_parse"), fileTest)
          spath = Builtins.tostring(pathExists)

          if spath != "1"
            Popup.Error(_("The specified directory does not exist."))
            UI.ChangeWidget(Id(:expPath), :Value, @oldExpPath)
          else
            Ops.set(_Settings, "expPath", expPath)
            UI.ChangeWidget(Id(:expPath), :Value, expPath)

            name = Convert.to_string(UI.QueryWidget(Id(:name), :Value))
            monthdate = Convert.to_string(
              UI.QueryWidget(Id(:monthdate), :Value)
            )
            weekday = Convert.to_string(UI.QueryWidget(Id(:weekday), :Value))
            iHours = UI.QueryWidget(Id(:hour), :Value)
            iMins = UI.QueryWidget(Id(:mins), :Value)
            email1 = Convert.to_string(UI.QueryWidget(Id(:email1), :Value))
            email2 = Convert.to_string(UI.QueryWidget(Id(:email2), :Value))
            email3 = Convert.to_string(UI.QueryWidget(Id(:email3), :Value))

            #string monthdate = tostring( iMonthdate );
            hour = Builtins.tostring(iHours)
            mins = Builtins.tostring(iMins)

            expType = Convert.to_string(UI.QueryWidget(Id(:expType), :Value))

            if expType == _("csv") || expType == _("Both")
              Ops.set(_Settings, "csv", "1")
            end

            if expType == _("html") || expType == _("Both")
              Ops.set(_Settings, "html", "1")
            end

            weekday = "-" if weekday == _("All")
            monthdate = "-" if monthdate == _("All")

            # de-i18n
            weekday = "Mon" if weekday == _("Mon")
            weekday = "Tue" if weekday == _("Tue")
            weekday = "Weds" if weekday == _("Wed")
            weekday = "Thu" if weekday == _("Thu")
            weekday = "Fri" if weekday == _("Fri")
            weekday = "Sat" if weekday == _("Sat")
            weekday = "Sun" if weekday == _("Sun")

            Ops.set(_Settings, "add", "1")
            Ops.set(_Settings, "name", name)
            Ops.set(_Settings, "monthdate", monthdate)
            Ops.set(_Settings, "weekday", weekday)
            Ops.set(_Settings, "hour", hour)
            Ops.set(_Settings, "mins", mins)
            Ops.set(_Settings, "email1", email1)
            Ops.set(_Settings, "email2", email2)
            Ops.set(_Settings, "email3", email3)

            # Confirm reasonable input on report names
            checkName = Builtins.filterchars(
              name,
              "`~!@\#$%^&*()[{]};:'\",<>?/|"
            )
            nameLength = Builtins.size(name)

            if Builtins.regexpmatch(name, "  ") == true
              Popup.Error(
                _("Only one contiguous space allowed in report names.")
              )
            elsif checkName != ""
              Popup.Error(
                _(
                  "These characters are not allowed in report names:\n\t\t\t\t\t\"`~!@\#$%^&*()[{]};:'\",<>?/|\""
                )
              )
            elsif Ops.greater_than(nameLength, 128)
              Popup.Error(_("Only 128 characters are allowed in report names."))
            else
              uniqueName = findDupe(name)
              if uniqueName == true
                UI.ReplaceWidget(:addSchedRep, @schedFilterForm)
              else
                Popup.Error(_("Each report name should be unique."))
              end
            end
          end
        elsif addInput == :aamode
          aamode = popUpSdMode

          if aamode != ""
            Ops.set(_Settings, "aamode", aamode)
            UI.ReplaceWidget(
              Id(:replace_aamode),
              PushButton(Id(:aamode), modeToHumanString(aamode))
            )
          end
        elsif addInput == :mode
          mode = popUpMode

          if mode != ""
            Ops.set(_Settings, "mode", mode)
            UI.ReplaceWidget(
              Id(:replace_mode),
              PushButton(Id(:mode), modeToHumanString(mode))
            )
          end
        elsif addInput == :save
          prog = Convert.to_string(UI.QueryWidget(Id(:prog), :Value))
          prof = Convert.to_string(UI.QueryWidget(Id(:prof), :Value))
          pid = Convert.to_string(UI.QueryWidget(Id(:pid), :Value))
          res = Convert.to_string(UI.QueryWidget(Id(:res), :Value))
          aamode2 = Convert.to_string(UI.QueryWidget(Id(:aamode), :Label))
          mode2 = Convert.to_string(UI.QueryWidget(Id(:mode), :Label))
          sev = Convert.to_string(UI.QueryWidget(Id(:sev), :Value))
          expType = Convert.to_string(UI.QueryWidget(Id(:expType), :Value))

          if expType == "csv"
            Ops.set(_Settings, "exporttext", "1")
          elsif expType == "html"
            Ops.set(_Settings, "exporthtml", "1")
          elsif expType == "both"
            Ops.set(_Settings, "exporttext", "1")
            Ops.set(_Settings, "exporthtml", "1")
          end

          sev = "-" if sev == _("All")

          Ops.set(_Settings, "getcron", "")
          Ops.set(_Settings, "prog", prog)
          Ops.set(_Settings, "prof", prof)
          Ops.set(_Settings, "pid", pid)
          Ops.set(_Settings, "sev", sev)
          Ops.set(_Settings, "res", res)
          Ops.set(_Settings, "aamode", humanStringToMode(aamode2))
          Ops.set(_Settings, "mode", humanStringToMode(mode2))

          error = SCR.Write(path(".reports_sched"), _Settings)

          if Ops.is_string?(error)
            erStr = Builtins.tostring(error)
            Popup.Error(Ops.add("Error: ", erStr))
          end

          addInput = :close
          break
        elsif addInput == :accept
          expPath = Convert.to_string(UI.QueryWidget(Id(:expPath), :Value))
          fileTest = {}
          Ops.set(fileTest, "checkFile", "1")
          Ops.set(fileTest, "file", expPath)

          pathExists = SCR.Read(path(".reports_parse"), fileTest)
          spath = Builtins.tostring(pathExists)

          if spath == "1"
            Ops.set(_Settings, "expPath", expPath)
            UI.ChangeWidget(Id(:expPath), :Value, expPath)
          else
            Popup.Error(_("The specified directory does not exist."))
          end
        elsif addInput == :browse
          selectFile = ""
          selectFile = UI.AskForExistingDirectory("/", _("Select Directory"))

          UI.ChangeWidget(Id(:expPath), :Value, selectFile) if selectFile != nil

          Ops.set(_Settings, "expPath", expPath)
        elsif addInput == :cancel || addInput == :close
          addInput = :close
          break
        end
      end

      UI.CloseDialog

      nil
    end

    def editSchedForm
      itemselected = Convert.to_integer(
        UI.QueryWidget(Id(:table), :CurrentItem)
      )
      name = humanStringToType(
        Ops.get_string(
          Convert.to_term(UI.QueryWidget(Id(:table), term(:Item, itemselected))),
          1,
          ""
        )
      )

      _Settings = {}
      readSched = "1"
      Ops.set(_Settings, "name", name)
      Ops.set(_Settings, "getcron", "")
      Ops.set(_Settings, "getrep", "1")
      Ops.set(_Settings, "readSched", "1")
      Ops.set(_Settings, "type", "schedRep")

      itemList = []
      key = 1

      db = nil
      db = Convert.to_map(SCR.Read(path(".reports_sched"), _Settings))
      sname = name # Don't know why this was pulled from db instead of name above
      amday = Ops.get(db, "mday")
      wday = Ops.get(db, "wday")
      shour = Ops.get(db, "hour")
      smins = Ops.get(db, "mins")

      oldRepName = sname
      swday = "All"
      monthdate = "All"

      monthdate = Builtins.tostring(amday) if amday != nil
      swday = Builtins.tostring(wday) if wday != nil

      ihour = 23
      imins = 59
      ihour = Builtins.tointeger(shour) if shour != nil
      imins = Builtins.tointeger(smins) if smins != nil

      # Get reports.conf info
      Ops.set(_Settings, "getrep", "")
      Ops.set(_Settings, "getconf", "1")
      db2 = nil
      db2 = Convert.to_map(SCR.Read(path(".reports_sched"), _Settings))

      aemail1 = Ops.get(db2, "addr1")
      aemail2 = Ops.get(db2, "addr2")
      aemail3 = Ops.get(db2, "addr3")
      tmpPath = Ops.get(db2, "exportpath")

      email1 = ""
      email2 = ""
      email3 = ""

      expType = ""
      expPath = "/var/log/apparmor/reports-exported"
      if tmpPath != nil
        @oldExpPath = Builtins.tostring(tmpPath)
        expPath = @oldExpPath
      else
        @oldExpPath = @defExpPath
        expPath = @oldExpPath
      end

      email1 = Builtins.tostring(aemail1) if aemail1 != nil
      email2 = Builtins.tostring(aemail2) if aemail2 != nil
      email3 = Builtins.tostring(aemail3) if aemail3 != nil

      # Get Filtering Info for Report
      aprog = Ops.get(db2, "prog")
      aprof = Ops.get(db2, "prof")
      apid = Ops.get(db2, "pid")
      ares = Ops.get(db2, "res")
      asev = Ops.get(db2, "severity")
      aaamode = Ops.get(db2, "aamode")
      amode = Ops.get(db2, "mode")
      acsv = Ops.get(db2, "csv")
      ahtml = Ops.get(db2, "html")

      # debug
      Ops.set(_Settings, "prog", Builtins.tostring(aprog)) if aprog != nil
      Ops.set(_Settings, "prof", Builtins.tostring(aprof)) if aprof != nil
      Ops.set(_Settings, "pid", Builtins.tostring(apid)) if apid != nil
      Ops.set(_Settings, "res", Builtins.tostring(ares)) if ares != nil
      Ops.set(_Settings, "sev", Builtins.tostring(asev)) if asev != nil
      Ops.set(_Settings, "aamode", Builtins.tostring(aaamode)) if aaamode != nil
      Ops.set(_Settings, "aamode", "All") if aaamode == nil || aaamode == "-"
      Ops.set(_Settings, "mode", Builtins.tostring(amode)) if amode != nil

      if acsv != nil && ahtml != nil
        expType = "Both"
        Ops.set(_Settings, "csv", "1")
        Ops.set(_Settings, "html", "1")
      elsif acsv != nil && ahtml == nil
        expType = "csv"
        Ops.set(_Settings, "csv", "1")
        Ops.set(_Settings, "html", "")
      elsif acsv == nil && ahtml != nil
        expType = "html"
        Ops.set(_Settings, "csv", "")
        Ops.set(_Settings, "html", "1")
      elsif acsv == nil && ahtml == nil
        expType = "None"
        Ops.set(_Settings, "csv", "")
        Ops.set(_Settings, "html", "")
      end

      # Special handling for sev
      formatSev = ""
      formatSev = Builtins.tostring(asev) if asev != nil
      if formatSev != "" && formatSev != "U" && formatSev != "All" &&
          formatSev != nil
        formatSev = Ops.add("0", formatSev)
      end

      continueBtns = HBox(
        PushButton(Id(:cancel), Label.CancelButton),
        PushButton(Id(:fwd), _("N&ext"))
      )


      # We need secondary filters for SIR reports only
      if sname == "Executive.Security.Summary" || sname == "Applications.Audit"
        continueBtns = HBox(
          PushButton(Id(:cancel), Label.CancelButton),
          PushButton(Id(:save), Label.SaveButton)
        )
      end

      edLabel = Ops.add(
        _("Edit Report Schedule for "),
        typeToHumanString(sname)
      )

      UI.OpenDialog(
        ReplacePoint(
          Id(:editSchedRep),
          VBox(
            HBox(Label(Id(:edname), edLabel)),
            VSpacing(1),
            HBox(
              ComboBox(
                Id(:monthdate),
                Opt(:notify),
                _("Day of Month"),
                [
                  Item(Id(:md_00), _("All")),
                  Item(Id(:md_01), "1"),
                  Item(Id(:md_02), "2"),
                  Item(Id(:md_03), "3"),
                  Item(Id(:md_04), "4"),
                  Item(Id(:md_05), "5"),
                  Item(Id(:md_06), "6"),
                  Item(Id(:md_07), "7"),
                  Item(Id(:md_08), "8"),
                  Item(Id(:md_09), "9"),
                  Item(Id(:md_10), "10"),
                  Item(Id(:md_11), "11"),
                  Item(Id(:md_12), "12"),
                  Item(Id(:md_13), "13"),
                  Item(Id(:md_14), "14"),
                  Item(Id(:md_15), "15"),
                  Item(Id(:md_16), "16"),
                  Item(Id(:md_17), "17"),
                  Item(Id(:md_18), "18"),
                  Item(Id(:md_19), "19"),
                  Item(Id(:md_20), "20"),
                  Item(Id(:md_21), "21"),
                  Item(Id(:md_22), "22"),
                  Item(Id(:md_23), "23"),
                  Item(Id(:md_24), "24"),
                  Item(Id(:md_25), "25"),
                  Item(Id(:md_26), "26"),
                  Item(Id(:md_27), "27"),
                  Item(Id(:md_28), "28"),
                  Item(Id(:md_29), "29"),
                  Item(Id(:md_30), "30"),
                  Item(Id(:md_31), "31")
                ]
              ),
              ComboBox(
                Id(:weekday),
                Opt(:notify),
                _("Day of Week"),
                [
                  _("All"),
                  _("Sun"),
                  _("Mon"),
                  _("Tue"),
                  _("Wed"),
                  _("Thu"),
                  _("Fri"),
                  _("Sat")
                ]
              ),
              IntField(Id(:hour), _("Hour"), 0, 23, ihour),
              IntField(Id(:mins), _("Minute"), 0, 59, imins)
            ),
            VSpacing(1),
            HBox(
              VSpacing(1),
              TextEntry(Id(:email1), Opt(:notify), _("Email Target 1"), email1),
              TextEntry(Id(:email2), Opt(:notify), _("Email Target 2"), email2),
              TextEntry(Id(:email3), Opt(:notify), _("Email Target 3"), email3)
            ),
            VSpacing(1),
            HBox(
              VSpacing(0.5),
              # DWR MOD `ComboBox(`id(`expType), `opt(`notify, `immediate), _("Export Type"),  [
              ComboBox(
                Id(:expType),
                Opt(:notify),
                _("Export Type"),
                [_("None"), _("csv"), _("html"), _("Both")]
              ),
              TextEntry(Id(:expPath), _("Location to store log."), expPath),
              Bottom(VWeight(1, PushButton(Id(:browse), _("&Browse"))))
            ),
            VSpacing(1),
            continueBtns
          )
        )
      )

      #************************************************
      mode = _("All")
      aamode = _("R")

      timeout_millisec = 20 * 1000
      event = {}
      editInput = nil
      #map<string,string> Settings = $[ ];

      #Cheap & easy way to give default value to ComboBox
      UI.ChangeWidget(Id(:weekday), :Value, swday) if swday != _("All")

      if monthdate != _("All")
        UI.ChangeWidget(Id(:monthdate), :Value, monthdate)
      end

      UI.ChangeWidget(Id(:expType), :Value, expType) if expType != _("None")

      while true
        event = UI.WaitForEvent(timeout_millisec)
        editInput = Ops.get(event, "ID") # We'll need this often - cache it

        if editInput == :monthdate && editInput != 0
          UI.ChangeWidget(Id(:weekday), :Value, _("All"))
        elsif editInput == :weekday && editInput != _("All")
          UI.ChangeWidget(Id(:monthdate), :Value, _("All"))
        end

        if editInput == :fwd
          email12 = Convert.to_string(UI.QueryWidget(Id(:email1), :Value))
          email22 = Convert.to_string(UI.QueryWidget(Id(:email2), :Value))
          email32 = Convert.to_string(UI.QueryWidget(Id(:email3), :Value))

          spath = "0"

          expPath = Convert.to_string(UI.QueryWidget(Id(:expPath), :Value))
          fileTest = {}
          Ops.set(fileTest, "checkFile", "1")
          Ops.set(fileTest, "file", expPath)

          pathExists = SCR.Read(path(".reports_parse"), fileTest)
          spath = Builtins.tostring(pathExists)
          Ops.set(_Settings, "expPath", expPath)

          if spath == "1"
            _Settings = getSchedSettings(_Settings)
            UI.ReplaceWidget(:editSchedRep, editFilterForm(_Settings))

            # Special handling for ComboBoxes (sev)
            UI.ChangeWidget(Id(:sev), :Value, formatSev) if formatSev != ""
          else
            Popup.Error(_("The specified directory does not exist."))
            UI.ChangeWidget(Id(:expPath), :Value, @oldExpPath)
          end
        elsif editInput == :aamode
          aamode = popUpSdMode

          if aamode != ""
            Ops.set(_Settings, "aamode", aamode)
            UI.ReplaceWidget(
              Id(:replace_aamode),
              PushButton(Id(:aamode), modeToHumanString(aamode))
            )
          end
        elsif editInput == :mode
          mode = popUpMode
          if mode != ""
            Ops.set(_Settings, "mode", mode)
            UI.ReplaceWidget(
              Id(:replace_mode),
              PushButton(Id(:mode), modeToHumanString(mode))
            )
          end
        elsif editInput == :browse
          selectFile = ""
          selectFile = UI.AskForExistingDirectory("/", _("Select Directory"))

          UI.ChangeWidget(Id(:expPath), :Value, selectFile) if selectFile != nil

          Ops.set(_Settings, "expPath", expPath)
        elsif editInput == :close || editInput == :cancel
          break
        elsif editInput == :save
          spath = "0"

          if sname == "Executive.Security.Summary" ||
              sname == "Applications.Audit"
            expPath = Convert.to_string(UI.QueryWidget(Id(:expPath), :Value))
            fileTest = {}
            Ops.set(fileTest, "checkFile", "1")
            Ops.set(fileTest, "file", expPath)

            pathExists = SCR.Read(path(".reports_parse"), fileTest)
            spath = Builtins.tostring(pathExists)
            Ops.set(_Settings, "expPath", expPath)
          else
            # SIR Reports already checked
            spath = "1"
          end

          if spath != "1"
            Popup.Error(_("The specified directory does not exist."))
            UI.ChangeWidget(Id(:expPath), :Value, @oldExpPath)
          else
            if sname != "Executive.Security.Summary" &&
                sname != "Applications.Audit"
              prog = Convert.to_string(UI.QueryWidget(Id(:prog), :Value))
              prof = Convert.to_string(UI.QueryWidget(Id(:prof), :Value))
              pid = Convert.to_string(UI.QueryWidget(Id(:pid), :Value))
              res = Convert.to_string(UI.QueryWidget(Id(:res), :Value))
              aamode2 = Convert.to_string(UI.QueryWidget(Id(:aamode), :Label))
              mode2 = Convert.to_string(UI.QueryWidget(Id(:mode), :Label))
              sev = Convert.to_string(UI.QueryWidget(Id(:sev), :Value))

              Ops.set(_Settings, "prog", prog)
              Ops.set(_Settings, "prof", prof)
              Ops.set(_Settings, "pid", pid)
              Ops.set(_Settings, "sev", sev)
              Ops.set(_Settings, "res", res)
              Ops.set(_Settings, "aamode", humanStringToMode(aamode2))
              Ops.set(_Settings, "mode", humanStringToMode(mode2))
            else
              email12 = Convert.to_string(UI.QueryWidget(Id(:email1), :Value))
              email22 = Convert.to_string(UI.QueryWidget(Id(:email2), :Value))
              email32 = Convert.to_string(UI.QueryWidget(Id(:email3), :Value))

              _Settings = getSchedSettings(_Settings)
            end

            Ops.set(_Settings, "name", sname)
            Ops.set(_Settings, "getconf", "")
            Ops.set(_Settings, "setconf", "1")

            expType2 = Convert.to_string(UI.QueryWidget(Id(:expType), :Value))

            if expType2 == "csv"
              Ops.set(_Settings, "exporttext", "1")
            elsif expType2 == "html"
              Ops.set(_Settings, "exporthtml", "1")
            elsif expType2 == "both"
              Ops.set(_Settings, "exporttext", "1")
              Ops.set(_Settings, "exporthtml", "1")
            end

            error = SCR.Write(path(".reports_sched"), _Settings)

            if Ops.is_string?(error)
              erStr = Builtins.tostring(error)
              Popup.Error(Ops.add(_("Error: "), erStr))
            end

            break
          end
        end 
        # END - Save Dialog (editInput == `save)
      end

      UI.CloseDialog

      #return (symbol) editInput;
      nil
    end

    def delSchedForm
      itemselected = Convert.to_integer(
        UI.QueryWidget(Id(:table), :CurrentItem)
      )
      name = humanStringToType(
        Ops.get_string(
          Convert.to_term(UI.QueryWidget(Id(:table), term(:Item, itemselected))),
          1,
          ""
        )
      )

      _Settings = {}
      Ops.set(_Settings, "del", "1")
      Ops.set(_Settings, "name", name)

      UI.OpenDialog(
        VBox(
          VSpacing(0.5),
          Label(_("Delete Confirmation")),
          VSpacing(1),
          HBox(
            HSpacing(Opt(:hstretch), 0.75),
            Left(
              HWeight(
                0,
                Label(
                  Ops.add(
                    Ops.add(_("Are you sure you want to delete: "), name),
                    _("?")
                  )
                )
              )
            )
          ),
          VSpacing(1),
          HBox(
            PushButton(Id(:cancel), Label.CancelButton),
            PushButton(Id(:del), Label.DeleteButton)
          )
        )
      )

      delInput = :default

      while delInput != :close
        delInput = Convert.to_symbol(UI.UserInput)

        if delInput == :del
          SCR.Write(path(".reports_sched"), _Settings)
          #any error = (any) SCR::Write(.reportsched, Settings);
          break
        elsif delInput == :close || delInput == :cancel
          break
        end
      end

      UI.CloseDialog

      nil
    end

    # Forces update of the table of available scheduled reports
    def updateSched
      _Settings = {}
      readSched = "1"
      Ops.set(_Settings, "getcron", "1")
      Ops.set(_Settings, "readSched", "1")
      Ops.set(_Settings, "type", "schedRep")

      itemList = []
      key = 1

      db = Convert.convert(
        SCR.Read(path(".reports_sched"), _Settings),
        :from => "any",
        :to   => "list <map>"
      )

      Builtins.foreach(db) do |record|
        itemList = Builtins.add(
          itemList,
          Item(
            Id(key),
            typeToHumanString(Ops.get_string(record, "name", "")),
            Ops.get(record, "mday"),
            Ops.get(record, "wday"),
            Ops.get(record, "hour"),
            Ops.get(record, "mins")
          )
        )
        key = Ops.add(key, 1)
      end

      schedForm = VBox(
        Label(_("Schedule Reports")),
        VSpacing(2),
        HBox(
          VSpacing(10),
          Table(
            Id(:table),
            Opt(:notify),
            Header(
              _("Report Name"),
              _("Day of Month"),
              _("Day of Week"),
              _("Hour"),
              _("Mins")
            ),
            itemList
          )
        ),
        VSpacing(0.5),
        HBox(
          PushButton(Id(:viewrep), _("View Archive")),
          PushButton(Id(:runrep), _("Run Now"))
        ),
        HBox(
          PushButton(Id(:add), Label.AddButton),
          PushButton(Id(:edit), Label.EditButton),
          PushButton(Id(:delete), Label.DeleteButton)
        )
      )

      Wizard.SetContentsButtons(
        _("AppArmor Security Event Report"),
        schedForm,
        @mainHelp,
        Label.BackButton,
        Label.NextButton
      )

      nil
    end

    def displaySchedForm
      # START - Move to separate Routine - START

      _Settings = {}
      readSched = "1"
      Ops.set(_Settings, "getcron", "1")
      Ops.set(_Settings, "readSched", "1")
      Ops.set(_Settings, "type", "schedRep")

      itemList = []
      key = 1

      db = Convert.convert(
        SCR.Read(path(".reports_sched"), _Settings),
        :from => "any",
        :to   => "list <map>"
      )

      Builtins.foreach(db) do |record|
        itemList = Builtins.add(
          itemList,
          Item(
            Id(key),
            typeToHumanString(Ops.get_string(record, "name", "")),
            Ops.get(record, "mday"),
            Ops.get(record, "wday"),
            Ops.get(record, "hour"),
            Ops.get(record, "mins")
          )
        )
        key = Ops.add(key, 1)
      end

      schedForm = Frame(
        Id(:dosched),
        _("Schedule Reports"),
        VBox(
          VSpacing(2),
          HBox(
            VSpacing(10),
            Table(
              Id(:table),
              Opt(:notify),
              Header(
                _("Report Name"),
                _("Day of Month"),
                _("Day of Week"),
                _("Hour"),
                _("Mins")
              ),
              itemList
            )
          ),
          VSpacing(0.5),
          HBox(
            PushButton(Id(:viewrep), _("View Archive")),
            PushButton(Id(:runrep), _("Run Now"))
          ),
          HBox(
            PushButton(Id(:add), Label.AddButton),
            PushButton(Id(:edit), Label.EditButton),
            PushButton(Id(:delete), Label.DeleteButton)
          )
        )
      )

      Wizard.SetContentsButtons(
        _("AppArmor Security Event Report"),
        schedForm,
        @mainHelp,
        Label.BackButton,
        _("&Done")
      )

      # Double-click tracking
      newRecord = nil
      lastRecord = nil

      event = {}
      id = nil
      while true
        event = UI.WaitForEvent(@timeout_millisec)

        id = Ops.get(event, "ID") # We'll need this often - cache it

        if id == :schedrep
          break
        elsif id == :abort || id == :cancel || id == :done
          break
        elsif id == :back
          break
        elsif id == :runrep || id == :viewrep
          break
        elsif id == :next
          id = :done
          break
        elsif id == :add
          addSchedForm
          Wizard.SetContentsButtons(
            _("AppArmor Security Event Report"),
            schedForm,
            @mainHelp,
            Label.BackButton,
            Label.NextButton
          )
          updateSched
          next
        elsif id == :edit
          editSchedForm
          updateSched
          next
        elsif id == :delete
          itemselected = Convert.to_integer(
            UI.QueryWidget(Id(:table), :CurrentItem)
          )
          repName = humanStringToType(
            Ops.get_string(
              Convert.to_term(
                UI.QueryWidget(Id(:table), term(:Item, itemselected))
              ),
              1,
              ""
            )
          )

          if repName == "Executive.Security.Summary" ||
              repName == "Applications.Audit" ||
              repName == "Security.Incident.Report"
            Popup.Error(_("Cannot delete a stock report."))
          else
            delSchedForm
            updateSched
          end

          next
        elsif id == :table
          newRecord = Convert.to_integer(
            UI.QueryWidget(Id(:table), :CurrentItem)
          )

          if newRecord == lastRecord
            #editSchedForm();
            #updateSched();
            id = :runrep
            break
            newRecord = 0
          end

          lastRecord = newRecord
        else
          Builtins.y2error("Unexpected return code: %1", id)
          next
        end
      end

      Convert.to_symbol(id)
    end
  end
end
