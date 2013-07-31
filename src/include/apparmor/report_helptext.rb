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
  module ApparmorReportHelptextInclude
    def initialize_apparmor_report_helptext(include_target)
      textdomain "yast2-apparmor"

      @defs = _(
        "<b>Program Name Pattern:</b><br> When you enter a program name or pattern \n" +
          "that matches the name of the binary executable of the program of \n" +
          "interest, the report will display security events that have \n" +
          "occurred for a specific program.<br>"
      ) +
        _(
          "<b>Profile Name Pattern:</b> When you enter the name of the profile, \n" +
            "the report will display the security events that are generated for \n" +
            "the specified profile.  You can use this to see what is being confined \n" +
            "by a specific profile.<br>"
        ) +
        _(
          "<b>PID Number:</b> Process ID number is a number that uniquely identifies \n" +
            "one specific process or running program (this number is valid only \n" +
            "during the lifetime of that process).<br>"
        ) +
        _(
          "<b>Severity Level:</b>  Select the lowest severity level for security \n" +
            "events that you would like to be included in the report. The selected \n" +
            "severity level, and above, will be included in the reports.<br>"
        ) +
        _(
          "<b>Detail:</b>  A source to which the profile has denied access.  \n" +
            "This includes capabilities and files. You can use this field to \n" +
            "report the resources are not allowed to be accessed by profiles.<br>"
        ) +
        _(
          "<b>Mode:</b> The Mode is the permission that the profile grants \n" +
            "to the program or process to which it is applied. The options are: \n" +
            "r (read) w (write) l (link) x (execute)<br>"
        ) +
        _(
          "<b>Access Type:</b> The access type describes what is actually happening \n" +
            "with the security event. The options are: PERMITTING, REJECTING, \n" +
            "or AUDITING.<br>"
        ) +
        _(
          "<b>CSV or HTML:</b> Enables you to export a CSV (comma separated \n" +
            "values) or html file. The CSV file separates pieces of data in \n" +
            "the log entries with commas using a standard data format for \n" +
            "importing into table-oriented applications. You can enter a \n" +
            "pathname for your exported report by typing in the full \n" +
            "pathname in the field provided.</p>"
        )

      @setArchHelp = Ops.add(
        _(
          "<p>The Report Configuration dialog enables you to filter the archived \nreport selected in the previous screen. To filter by <b>Date Range:</b>"
        ) +
          _(
            "<ol><li>Click <b>Filter By Date Range</b>. The fields become active.</li>  \n" +
              "<li>Enter the start and end dates that delineate the scope of the report.</li> \n" +
              " <li>Enter other filtering parameters. See below for definitions of parameters.</li></ol></p>"
          ) +
          _(
            "The following definitions help you to enter the filtering parameters in the \nReport Configuration Dialog:<br>"
          ),
        @defs
      )


      @types = _(
        "<b>Executive Security Summary:</b> A combined report, \n" +
          "consisting of one or more Security incident reports from \n" +
          "one or more machines.  This report provides a single view of \n" +
          "security events on multiple machines.<br>"
      ) +
        _(
          "<b>Applications Audit Report:</b> An auditing tool that \n" +
            "reports which application servers are running and whether \n" +
            "the applications are confined by AppArmor. Application \n" +
            "servers are applications that accept incoming network connections. <br>"
        ) +
        _(
          "<b>Security Incident Report:</b> A report that displays application \n" +
            "security for a single host.  It reports policy violations for locally \n" +
            "confined applications during a specific time period. You can edit and \n" +
            "customize this report, or add new versions.</p>"
        )

      @runHelp = Ops.add(
        _(
          "<p>The AppArmor On-Demand Report screen displays \n" +
            "an instantly generated version of one of the following \n" +
            "reports:<br>"
        ),
        @types
      )


      @filterCfHelp1 = @setArchHelp
      # START Help Section
      #**********************************************************


      @schedHelpText = Ops.add(
        _(
          "<p>The summary of scheduled reports page shows us when reports are scheduled to run. \n" +
            "Reports can be set to run monthly, weekly, daily, or hourly. The default settings are \n" +
            "daily at midnight. The reports can also be emailed, upon completion, to up to three \n" +
            "email recipients.<br>"
        ) +
          _(
            "In the Set Schedule section, you can schedule the following three types of security reports:<br>"
          ),
        @types
      )

      @archHelpText = _(
        "<p>The View Archive Reports form enables you to view previously generated\nreports located in the /var/log/apparmor/reports-archived directory. Use the checkboxes at the top to narrow-down the category of reports shown in the list to: SIR Reports, AUD Reports or ESS Reports. To see report details, select a report and click the <b>View</b> button.<br><br> You can view reports from one or more systems if you move the reports to the /var/log/apparmor/reports-archived directory.</p>"
      )

      @mainHelp = @schedHelpText


      @helpList = [@schedHelpText]

      @defaultHelp = RichText(@schedHelpText)
      @schedHelp = RichText(@schedHelpText)
      @archHelp = RichText(@archHelpText)
      @otherHelp = RichText(@archHelpText)

      @repConfHelp = _("repConfHelp")

      @sirHelp = _(
        "<p><b>Security Incident Report (SIR):</b> A report that displays security \n" +
          "events of interest to an administrator. The SIR reports policy violations \n" +
          "for locally confined applications during the specified time period. The SIR \n" +
          "reports policy exceptions and policy engine state changes. These two types \n" +
          "of security events are defined as follows:"
      ) +
        _(
          "<ul> <li><b>Policy Exceptions:</b> When an application requests a resource \n" +
            "that's not defined within its profile, a security event is generated.</li>  \n" +
            "<li><b>Policy Engine State Changes:</b> Enforces policy for applications and \n" +
            "maintains its own state, including when engines start or stop, when a policy \n" +
            "is reloaded, and when global security feature are enabled or disabled.</li></ul> \n" +
            "Select the report from the archive, then <b>View</b> to see the report details.</p>"
        )


      @audHelp = _(
        "<p><b>Applications Audit Report (AUD):</b> An auditing tool that reports which application servers are running and whether they are confined by AppArmor. Application servers are applications that accept incoming network connections. This report provides the host machine's IP Address, the date the Applications Audit Report ran, the name and path of the unconfined program or application server, the suggested profile or a placeholder for a profile for an unconfined program, the process ID number, the state of the program (confined or unconfined) and the type of confinement that the profile is performing (enforce/complain).</p>"
      )

      @essHelp = _(
        "<p><b>Executive Security Summary (ESS):</b> A combined report, \n" +
          "consisting of one or more high-level reports from one or more machines. This \n" +
          "report can provide a single view of security events on multiple machines if each \n" +
          "machine's data is copied to the reports archive directory, which is \n" +
          "<b>/var/log/apparmor/reports-archived</b>. This report provides the host \n" +
          "machine's IP address, the start and end dates of the polled events, total number \n" +
          "of rejects, total number of events, average of severity levels reported, and the \n" +
          "highest severity level reported. One line of the ESS report represents a range \n" +
          "of SIR reports.</p>"
      )
    end
  end
end
