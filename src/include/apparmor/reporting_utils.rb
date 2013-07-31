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
  module ApparmorReportingUtilsInclude
    def initialize_apparmor_reporting_utils(include_target)
      Yast.import "UI"

      Yast.import "Wizard"
      Yast.import "Popup"
      Yast.import "Label"
      Yast.include include_target, "apparmor/report_helptext.rb"
      textdomain "yast2-apparmor"
    end

    def checkEventDb
      dbActivated = false
      args = {}
      Ops.set(args, "checkDb", "1")

      dbCheck = SCR.Read(path(".reports_parse"), args)
      dbOn = Builtins.tointeger(dbCheck)

      dbActivated = true if dbOn == 1

      dbActivated
    end

    def findDupe(name)
      unique = false
      args = {}
      Ops.set(args, "name", name)
      Ops.set(args, "getdupe", "1")
      aDupe = SCR.Read(path(".reports_sched"), args)

      if aDupe == "" || aDupe == nil
        unique = true # bad, but try for a non-breaking failure
      elsif aDupe == 1
        unique = false
      else
        unique = true
      end

      unique
    end

    def unI18n(weekday)
      weekday = "Mon" if weekday == _("Mon")
      weekday = "Tue" if weekday == _("Tue")
      weekday = "Wed" if weekday == _("Wed")
      weekday = "Thu" if weekday == _("Thu")
      weekday = "Fri" if weekday == _("Fri")
      weekday = "Sat" if weekday == _("Sat")
      weekday = "Sun" if weekday == _("Sun")

      weekday
    end

    # Possible 'type's for getLastPage() && getLastSirPage()
    # 	- displayArchForm():	type = sirRep || audRep || essRep
    # 	- displayRunForm():		type = sir || aud || ess

    # Return last page number of post-filtered report
    def getLastPage(type, _Settings, name)
      _Settings = deep_copy(_Settings)
      if type == "sir" || type == "sirRep"
        if name != nil && name != ""
          Ops.set(_Settings, "name", name)
        else
          Builtins.y2error(
            _("No name provided for retrieving SIR report page count.")
          )
          return 1 # return a page count of 1
        end
      end

      Ops.set(_Settings, "type", type)
      Ops.set(_Settings, "getLastPage", "1")
      page = {}
      page = Convert.to_map(SCR.Read(path(".reports_parse"), _Settings))
      lastPage = Ops.get_integer(page, "numPages", 1)

      lastPage
    end

    def CheckDate(day, month, year)
      mdays = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
      ret = true

      return false if year == nil || month == nil || day == nil

      ret = ret && Ops.greater_or_equal(month, 1) &&
        Ops.less_or_equal(month, 12)

      if Ops.modulo(year, 4) == 0 &&
          (Ops.modulo(year, 100) != 0 || Ops.modulo(year, 400) == 0)
        Ops.set(mdays, 1, 29)
      end

      ret = ret && Ops.greater_or_equal(day, 1) &&
        Ops.less_or_equal(
          day,
          Ops.get_integer(mdays, Ops.subtract(month, 1), 0)
        )
      ret = ret && Ops.greater_or_equal(year, 1970) && Ops.less_than(year, 2032)
      ret
    end

    # Make the table for displaying report data
    def makeSirTable(reportList)
      reportList = deep_copy(reportList)
      myTable = Table(
        Id(:table),
        Opt(:keepSorting, :immediate),
        Header(
          _("Host"),
          _("Date"),
          _("Program"),
          _("Profile"),
          _("PID"),
          _("Severity"),
          _("Mode Request"),
          _("Mode Deny"),
          _("Detail"),
          _("Event Type"),
          _("Operation"),
          _("Attribute"),
          _("Additional Name"),
          _("Net Family"),
          _("Net Protocol"),
          _("Net Socket Type")
        ),
        reportList
      )
      deep_copy(myTable)
    end

    def popUpGoto(lastPage)
      UI.OpenDialog(
        VBox(
          HBox(TextEntry(Id(:gotoPage), _("Enter a Page to Move to."), "")),
          HBox(
            PushButton(Id(:abort), Opt(:notify), Label.AbortButton),
            PushButton(Id(:save), Opt(:notify), Label.SaveButton)
          )
        )
      )

      event = {}
      id = nil
      igoto = nil

      while true
        event = UI.WaitForEvent
        id = Ops.get(event, "ID")

        if id == :abort || id == :close || id == :cancel
          break
        elsif id == :save
          agoto = UI.QueryWidget(Id(:gotoPage), :Value)
          igoto = Builtins.tointeger(agoto)

          if igoto == nil || Ops.less_than(igoto, 1) ||
              Ops.greater_than(igoto, lastPage)
            Popup.Message(
              Ops.add(
                Ops.add("You must enter a value between 1 and ", lastPage),
                "."
              )
            )
          else
            break
          end
        end
      end

      UI.CloseDialog

      igoto
    end

    def getSortId(type, sortId)
      sortId = deep_copy(sortId)
      sortKey = ""


      if type == "aud" || type == "audRep"
        if sortId == 0
          sortKey = "prog"
        elsif sortId == 1
          sortKey = "profile"
        elsif sortId == 2
          sortKey = "pid"
        elsif sortId == 3
          sortKey = "state"
        elsif sortId == 4
          sortKey = "type"
        end
      elsif type == "ess" || type == "essRep"
        if sortId == 0
          sortKey = "host"
        elsif sortId == 1
          #sortKey = "date";
          sortKey = "numRejects"
        elsif sortId == 2
          sortKey = "numEvents"
        elsif sortId == 3
          sortKey = "sevMean"
        elsif sortId == 4
          sortKey = "sevHi"
        end
      else
        if sortId == 0
          sortKey = "host"
        elsif sortId == 1
          #sortKey = "date";
          sortKey = "time"
        elsif sortId == 2
          sortKey = "prog"
        elsif sortId == 3
          sortKey = "profile"
        elsif sortId == 4
          sortKey = "pid"
        elsif sortId == 5
          sortKey = "resource"
        elsif sortId == 6
          sortKey = "severity"
        elsif sortId == 7
          sortKey = "aamode"
        elsif sortId == 8
          sortKey = "mode"
        end
      end

      sortKey
    end

    # Get the name of the filter (header column) to sort by
    def popUpSort(type)
      btnList = nil

      if type == "aud" || type == "audRep"
        btnList = VBox(
          Left(RadioButton(Id(0), _("Program"))),
          Left(RadioButton(Id(1), _("Profile"))),
          Left(RadioButton(Id(2), _("PID"))),
          Left(RadioButton(Id(3), _("State"))),
          Left(RadioButton(Id(4), _("Type")))
        )
      elsif type == "ess" || type == "essRep"
        btnList = VBox(
          Left(RadioButton(Id(0), _("Host"))),
          Left(RadioButton(Id(1), _("Num. Rejects"))),
          Left(RadioButton(Id(2), _("Num. Events"))),
          Left(RadioButton(Id(3), _("Ave. Sev"))),
          Left(RadioButton(Id(4), _("High Sev")))
        )
      else
        btnList = VBox(
          # Sorting by host is no longer meaningful (due to sql changes)
          #`Left(`RadioButton(`id(0), _("Host") )),
          Left(RadioButton(Id(1), _("Date"))),
          Left(RadioButton(Id(2), _("Program"))),
          Left(RadioButton(Id(3), _("Profile"))),
          Left(RadioButton(Id(4), _("PID"))),
          Left(RadioButton(Id(5), _("Detail"))),
          Left(RadioButton(Id(6), _("Severity"))),
          Left(RadioButton(Id(7), _("Access Type"))),
          Left(RadioButton(Id(8), _("Mode")))
        )
      end

      UI.OpenDialog(
        VBox(
          HBox(
            #`HSpacing( `opt(`vstretch), 0.5),
            RadioButtonGroup(Id(:sortKey), btnList)
          ),
          HBox(
            PushButton(Id(:abort), Label.AbortButton),
            PushButton(Id(:save), Label.SaveButton)
          )
        )
      )

      event = {}
      id = nil
      sortKey = nil

      while true
        event = UI.WaitForEvent
        id = Ops.get(event, "ID") # We'll need this often - cache it

        if id == :abort || id == :cancel || id == :close
          break
        elsif id == :save
          sortId = UI.QueryWidget(Id(:sortKey), :CurrentButton)

          # sortKey needs to match the hash reference names in parseEventLog()
          # 	&& sortRecords() in Immunix::Reports.pm

          sortKey = getSortId(type, sortId)
          break
        end
      end

      UI.CloseDialog

      sortKey
    end

    # Mode
    def popUpMode
      checkMode = Convert.to_string(UI.QueryWidget(Id(:mode), :Label))
      splitMode = Builtins.splitstring(checkMode, " ")
      myMode = Ops.get_string(
        splitMode,
        Ops.subtract(Builtins.size(splitMode), 1),
        "All"
      )

      UI.OpenDialog(
        VBox(
          HBox(
            CheckBox(Id(:clear), Opt(:notify, :immediate), _("All"), true),
            CheckBox(Id(:read), Opt(:notify, :immediate), _("Read"), false),
            CheckBox(Id(:write), Opt(:notify, :immediate), _("Write"), false),
            CheckBox(Id(:link), Opt(:notify, :immediate), _("Link"), false),
            CheckBox(Id(:exec), Opt(:notify, :immediate), _("Execute"), false),
            CheckBox(Id(:mmap), Opt(:notify, :immediate), _("MMap"), false)
          ),
          HBox(
            PushButton(Id(:cancel), Label.CancelButton),
            PushButton(Id(:save), Label.SaveButton)
          )
        )
      )

      isall = Builtins.search(myMode, "All")
      if isall != nil && Ops.greater_or_equal(isall, 0)
        UI.ChangeWidget(Id(:clear), :Value, false)
        UI.ChangeWidget(Id(:read), :Value, true)
        UI.ChangeWidget(Id(:write), :Value, true)
        UI.ChangeWidget(Id(:link), :Value, true)
        UI.ChangeWidget(Id(:exec), :Value, true)
        UI.ChangeWidget(Id(:mmap), :Value, true)
      else
        if Builtins.search(myMode, "r") != nil
          UI.ChangeWidget(Id(:clear), :Value, false)
          UI.ChangeWidget(Id(:read), :Value, true)
        end
        if Builtins.search(myMode, "w") != nil
          UI.ChangeWidget(Id(:clear), :Value, false)
          UI.ChangeWidget(Id(:write), :Value, true)
        end
        if Builtins.search(myMode, "l") != nil
          UI.ChangeWidget(Id(:clear), :Value, false)
          UI.ChangeWidget(Id(:link), :Value, true)
        end
        if Builtins.search(myMode, "x") != nil
          UI.ChangeWidget(Id(:clear), :Value, false)
          UI.ChangeWidget(Id(:exec), :Value, true)
        end
        if Builtins.search(myMode, "m") != nil
          UI.ChangeWidget(Id(:clear), :Value, false)
          UI.ChangeWidget(Id(:mmap), :Value, true)
        end
      end

      mode = ""
      event = {}
      id = nil

      while true
        event = UI.WaitForEvent
        id = Ops.get(event, "ID") # We'll need this often - cache it

        if id == :clear
          if UI.QueryWidget(Id(:clear), :Value) == true
            UI.ChangeWidget(Id(:read), :Value, false)
            UI.ChangeWidget(Id(:write), :Value, false)
            UI.ChangeWidget(Id(:link), :Value, false)
            UI.ChangeWidget(Id(:exec), :Value, false)
            UI.ChangeWidget(Id(:mmap), :Value, false)
            mode = "All"
          end
        elsif id == :read || id == :write || id == :link || id == :exec ||
            id == :mmap
          if UI.QueryWidget(Id(:read), :Value) == true
            UI.ChangeWidget(Id(:clear), :Value, false)
          elsif UI.QueryWidget(Id(:write), :Value) == true
            UI.ChangeWidget(Id(:clear), :Value, false)
          elsif UI.QueryWidget(Id(:link), :Value) == true
            UI.ChangeWidget(Id(:clear), :Value, false)
          elsif UI.QueryWidget(Id(:exec), :Value) == true
            UI.ChangeWidget(Id(:clear), :Value, false)
          elsif UI.QueryWidget(Id(:mmap), :Value) == true
            UI.ChangeWidget(Id(:link), :Value, false)
          end
        elsif id == :abort || id == :cancel || id == :close
          mode = myMode
          break
        elsif id == :save
          if UI.QueryWidget(Id(:clear), :Value) == true
            mode = "All"
          else
            aaList = []
            if UI.QueryWidget(Id(:read), :Value) == true
              aaList = Builtins.add(aaList, "r")
            end
            if UI.QueryWidget(Id(:write), :Value) == true
              aaList = Builtins.add(aaList, "w")
            end
            if UI.QueryWidget(Id(:link), :Value) == true
              aaList = Builtins.add(aaList, "l")
            end
            if UI.QueryWidget(Id(:exec), :Value) == true
              aaList = Builtins.add(aaList, "x")
            end
            if UI.QueryWidget(Id(:mmap), :Value) == true
              aaList = Builtins.add(aaList, "m")
            end

            Builtins.foreach(aaList) { |perm| mode = Ops.add(mode, perm) }
          end

          break
        end
      end

      UI.CloseDialog
      mode
    end

    # Access Type - AA Mode
    def popUpSdMode
      checkMode = Convert.to_string(UI.QueryWidget(Id(:aamode), :Label))
      checkMode = Builtins.filterchars(checkMode, "APRl")
      splitMode = Builtins.splitstring(checkMode, " ")
      mySdMode = Ops.get_string(
        splitMode,
        Ops.subtract(Builtins.size(splitMode), 1),
        "R"
      )

      UI.OpenDialog(
        VBox(
          HBox(
            CheckBox(Id(:clear), Opt(:notify, :immediate), _("All"), false),
            CheckBox(Id(:permit), Opt(:notify, :immediate), _("Permit"), false),
            CheckBox(Id(:reject), Opt(:notify, :immediate), _("Reject"), false),
            CheckBox(Id(:audit), Opt(:notify, :immediate), _("Audit"), false)
          ),
          HBox(
            PushButton(Id(:cancel), Opt(:notify), Label.CancelButton),
            PushButton(Id(:save), Opt(:notify), Label.SaveButton)
          )
        )
      )

      if mySdMode == "P"
        UI.ChangeWidget(Id(:clear), :Value, false)
        UI.ChangeWidget(Id(:permit), :Value, true)
      elsif mySdMode == "R"
        UI.ChangeWidget(Id(:clear), :Value, false)
        UI.ChangeWidget(Id(:reject), :Value, true)
      elsif mySdMode == "A"
        UI.ChangeWidget(Id(:clear), :Value, false)
        UI.ChangeWidget(Id(:audit), :Value, true)
      elsif mySdMode == "PR"
        UI.ChangeWidget(Id(:clear), :Value, false)
        UI.ChangeWidget(Id(:permit), :Value, true)
        UI.ChangeWidget(Id(:reject), :Value, true)
      elsif mySdMode == "PA"
        UI.ChangeWidget(Id(:clear), :Value, false)
        UI.ChangeWidget(Id(:permit), :Value, true)
        UI.ChangeWidget(Id(:audit), :Value, true)
      elsif mySdMode == "PRA"
        UI.ChangeWidget(Id(:clear), :Value, false)
        UI.ChangeWidget(Id(:permit), :Value, true)
        UI.ChangeWidget(Id(:reject), :Value, true)
        UI.ChangeWidget(Id(:audit), :Value, true)
      elsif mySdMode == "RA"
        UI.ChangeWidget(Id(:clear), :Value, false)
        UI.ChangeWidget(Id(:reject), :Value, true)
        UI.ChangeWidget(Id(:audit), :Value, true)
      elsif mySdMode == "All"
        UI.ChangeWidget(Id(:clear), :Value, true)
        UI.ChangeWidget(Id(:permit), :Value, false)
        UI.ChangeWidget(Id(:reject), :Value, false)
        UI.ChangeWidget(Id(:audit), :Value, false)
      end

      aaMode = ""
      event = {}
      id = nil

      while true
        event = UI.WaitForEvent
        id = Ops.get(event, "ID")

        if id == :clear
          if UI.QueryWidget(Id(:clear), :Value) == true
            UI.ChangeWidget(Id(:permit), :Value, false)
            UI.ChangeWidget(Id(:reject), :Value, false)
            UI.ChangeWidget(Id(:audit), :Value, false)
            aaMode = "All"
          end
        elsif id == :permit || id == :reject || id == :audit
          if UI.QueryWidget(Id(:permit), :Value) == true
            UI.ChangeWidget(Id(:clear), :Value, false)
          elsif UI.QueryWidget(Id(:reject), :Value) == true
            UI.ChangeWidget(Id(:clear), :Value, false)
          elsif UI.QueryWidget(Id(:audit), :Value) == true
            UI.ChangeWidget(Id(:clear), :Value, false)
          end
        elsif id == :cancel
          aaMode = mySdMode
          break
        elsif id == :save
          if UI.QueryWidget(Id(:clear), :Value) == true
            aaMode = "All"
          else
            aaMode = ""
            mList = []
            if UI.QueryWidget(Id(:permit), :Value) == true
              mList = Builtins.add(mList, "P")
            end
            if UI.QueryWidget(Id(:reject), :Value) == true
              mList = Builtins.add(mList, "R")
            end
            if UI.QueryWidget(Id(:audit), :Value) == true
              mList = Builtins.add(mList, "A")
            end

            Builtins.foreach(mList) { |state| aaMode = Ops.add(aaMode, state) }
          end

          break
        end
      end

      UI.CloseDialog
      aaMode
    end

    # For On Demand Reports
    #     - Returns list of terms corresponding to the type of report
    # **********************************************************************
    def getReportList(type, _Settings)
      _Settings = deep_copy(_Settings)
      reportList = []

      if type == "aud"
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
        db = Convert.convert(
          SCR.Read(path(".reports_ess"), _Settings),
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
      else
        db = Convert.convert(
          SCR.Read(path(".logparse"), _Settings),
          :from => "any",
          :to   => "list <map>"
        )
        key = 0

        Builtins.foreach(db) do |record|
          reportList = Builtins.add(
            reportList,
            Item(
              Id(key),
              Ops.get(record, "host"),
              Ops.get(record, "date"),
              Ops.get(record, "prog"),
              Ops.get(record, "profile"),
              Ops.get(record, "pid"),
              Ops.get(record, "severity"),
              Ops.get(record, "mode_req"),
              Ops.get(record, "mode_deny"),
              Ops.get(record, "resource"),
              Ops.get(record, "aamode"),
              Ops.get(record, "op"),
              Ops.get(record, "attr"),
              Ops.get(record, "name_alt"),
              Ops.get(record, "net_family"),
              Ops.get(record, "net_proto"),
              Ops.get(record, "net_socktype")
            )
          )
          key = Ops.add(key, 1)
        end
      end

      deep_copy(reportList)
    end
  end
end
