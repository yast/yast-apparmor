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
  class AAReportClient < Client
    def main
      Yast.import "UI"

      Yast.import "Wizard"
      Yast.import "Popup"
      Yast.import "Label"
      Yast.import "Sequencer"
      Yast.include self, "apparmor/apparmor_packages.rb"
      Yast.include self, "apparmor/apparmor_profile_check.rb"
      Yast.include self, "apparmor/reporting_dialogues.rb"
      Yast.include self, "apparmor/report_helptext.rb"
      textdomain "yast2-apparmor"

      @ret = nil

      # no command line support #269891
      if Ops.greater_than(Builtins.size(WFM.Args), 0)
        Yast.import "CommandLine"
        CommandLine.Init({}, WFM.Args)
        return deep_copy(@ret)
      end

      return deep_copy(@ret) if !installAppArmorPackages

      checkProfileSyntax

      @ret = mainSequence
      deep_copy(@ret)
    end

    # Globalz

    def mainSequence
      # Read the profiles from the SCR agent
      aliases = {
        "mainreport"   => lambda { mainReportForm },
        "configreport" => lambda { reportConfigForm },
        "reportview"   => lambda { mainArchivedReportForm },
        "schedReport"  => lambda { displaySchedForm },
        "viewreport"   => lambda { displayArchForm },
        "runReport"    => lambda { displayRunForm }
      }

      sequence = {
        "ws_start"     => "schedReport",
        "mainreport"   => {
          :back     => :back,
          :abort    => :abort,
          :next     => :finish,
          :schedrep => "schedReport",
          :finish   => :ws_finish
        },
        "schedReport"  => {
          :back    => :ws_start,
          :abort   => :abort,
          :viewrep => "viewreport",
          :runrep  => "runReport",
          :next    => "runReport",
          :finish  => :ws_finish
        },
        "viewreport"   => {
          :back   => "mainreport",
          :abort  => :abort,
          :next   => "mainreport",
          :finish => :ws_finish
        },
        "runReport"    => {
          :back   => :back,
          :abort  => :abort,
          :next   => "schedReport",
          :finish => :ws_finish
        },
        "configreport" => {
          :back   => :back,
          :abort  => :abort,
          :next   => "reportview",
          :finish => :ws_finish
        },
        "reportview"   => {
          :back   => :back,
          :abort  => :abort,
          :next   => :finish,
          :finish => :ws_finish
        }
      }

      Wizard.CreateDialog
      Wizard.SetTitleIcon("apparmor_view_profile")
      ret = Sequencer.Run(aliases, sequence)
      Wizard.CloseDialog
      deep_copy(ret)
    end
  end
end

Yast::AAReportClient.new.main
