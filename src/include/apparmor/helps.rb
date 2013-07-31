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
  module ApparmorHelpsInclude
    def initialize_apparmor_helps(include_target)
      textdomain "yast2-apparmor"

      # START Help Section
      #**********************************************************
      @helps = {
        "EventNotifyHelpText" => _(
          "<p>The Security Event Notification screen enables you to setup email \n" +
            "alerts for security events. In the following steps, specify how often \n" +
            "alerts are sent, who receives the alert, and how severe the security \n" +
            "event must be to send an alert.</p>"
        ) +
          _(
            "<p><b>Notification Types</b><br> <b>Terse Notification:</b> \n" +
              "Terse notification summarizes the total number of system events without \n" +
              "providing details.  <br>For example:<br> <tt>dhcp-101.up.wirex.com has \n" +
              "had 10 security events since Tue Oct 12 11:10:00 2004</tt></p>"
          ) +
          _(
            "<p><b>Summary Notification:</b> The Summary notification displays \n" +
              "the logged AppArmor security events, and lists the number of \n" +
              "individual occurrences, including the date of the last occurrence.  \n" +
              "<br>For example:<br> <tt>AppArmor: PERMITTING access to capability\n" +
              "'setgid' (httpd2-prefork(6347) profile /usr/sbin/httpd2-prefork \n" +
              "active /usr/sbin/httpd2-prefork) 2 times, the latest at Sat Oct 9 16:05:54 2004.</tt>\n" +
              "</p>"
          ) +
          _(
            "<p><b>Verbose Notification:</b> The Verbose notification displays \n" +
              "unmodified, logged AppArmor security events. It tells you every time \n" +
              "an event occurs and writes a new line in the Verbose log. These \n" +
              "security events include the date and time the event occurred, when \n" +
              "the application profile permits access as well as rejects access, \n" +
              "and the type of file permission access that is permitted or rejected.</p>"
          ) +
          _(
            "<p>Verbose Notification also reports several messages that \n" +
              "the logprof tool uses to interpret profiles. <br>For example:<br>\n" +
              "<tt> Oct  9 15:40:31 AppArmor: PERMITTING r access to\n" +
              "/etc/apache2/httpd.conf (httpd2-prefork(6068) profile \n" +
              "/usr/sbin/httpd2-prefork active /usr/sbin/httpd2-prefork)</tt></p>"
          ) + "<ol>" +
          _(
            "<li> For each notification type that you would like \n" +
              "enabled, select the frequency of notification that you would \n" +
              "like.  For example, if you select <b>1 day</b> from the \n" +
              "pull-down list, you will be sent daily notifications of \n" +
              "security events, if they occur.</li>"
          ) +
          _(
            "<li> Enter the email address of those who should receive \n" +
              "the Terse, Summary, or Verbose notifications.If there is no local \n" +
              "SMTP server configured to distribute e-mails from this host to the \n" +
              "domain you entered, enter for example <i><user>@localhost</i> \n" +
              "and enable <i><user></i> to receive system mail, if it is not \n" +
              "a root user. </li>"
          ) +
          _(
            "<li>Select the lowest <b>severity level</b> for which a notification \n" +
              "should be sent. Security events will be logged and the notifications \n" +
              "will be sent at the time indicated by the interval when events are \n" +
              "equal or greater than the selected severity level. If the interval \n" +
              "is 1 day, the notification will be sent daily, if security events \n" +
              "occur."
          ) +
          _(
            "<b>Severity Levels:</b> These are numbered 1 through 10, \n" +
              "10 being the most severe security incident. The <b>severity.db</b> \n" +
              "file defines the severity level of potential security events. \n" +
              "The severity levels are determined by the importance of \n" +
              "different security events, such as certain resources accessed \n" +
              "or services denied.</li>"
          ) +
          _(
            "<li>Select <b>Include unknown security events</b> if \nyou would like to include events that are not rated with a severity number.</li>"
          ) + "</ol>",
        # ----------------------------
        "profileWizard"       => _(
          "<b>AppArmor Profiling Wizard</b><br>"
        ) +
          _(
            "This wizard presents entries generated by the AppArmor access control module. \n" +
              "You can generate highly optimized and robust security profiles \n" +
              "by using the suggestions made by AppArmor."
          ) +
          _(
            "AppArmor suggests that you allow or deny access to specific resources \n" +
              "or define execute permission for entries. Questions \n" +
              "that display were logged during the normal application \n" +
              "execution test previously performed. <br>"
          ) +
          _(
            "The following help text describes the detail of the security profile \n" +
              "syntax used by AppArmor. <br><br>At any stage, you may \n" +
              "customize the profile entry by changing the suggested response. \n" +
              "This overview will assist you in your options. Refer to the \n" +
              "Novell AppArmor Administration Guide for step-by-step \n" +
              "instructions. <br><br>"
          ) +
          _("<b>Access Modes</b><br>") +
          _(
            "File permission access modes consists of combinations of the following six modes:"
          ) + "<ul>" +
          _("<li>r    - read</li>") +
          _("<li>w    - write</li>") +
          _("<li>m    - mmap PROT_EXEC</li>") +
          _("<li>px   - discrete profile execute</li>") +
          _("<li>ux   - unconfined execute</li>") +
          _("<li>ix   - inherit execute</li>") +
          _("<li>l    - link</li>") + "</ul>" +
          _("<b>Details for Access Modes</b>") + "<br><br>" +
          _("<b>Read mode</b><br>") +
          _(
            "Allows the program to have read access to the\n" +
              "resource. Read access is required for shell scripts\n" +
              "and other interpreted content, and determines if an\n" +
              "executing process can core dump or be attached to with\n" +
              "ptrace(2).  (ptrace(2) is used by utilities such as\n" +
              "strace(1), ltrace(1), and gdb(1).)"
          ) + "<br><br>" +
          _("<b>Write mode</b><br>") +
          _(
            "Allows the program to have write access to the\n" +
              "resource. Files must have this permission if they are\n" +
              "to be unlinked (removed.)"
          ) + "<br><br>" +
          _("<b>Mmap PROT_EXEC mode</b><br>") +
          _("Allows the program to call mmap with PROT_EXEC on the\nresource.") + "<br><br>" +
          _("<b>Unconfined execute mode</b><br>") +
          _(
            "Allows the program to execute the resource without any\n" +
              "AppArmor profile being applied to the executed\n" +
              "resource. Requires listing execute mode as well.\n" +
              "Incompatible with Inherit and Discrete Profile execute\n" +
              "entries."
          ) + "<br><br>" +
          _(
            "This mode is useful when a confined program needs to\n" +
              "be able to perform a privileged operation, such as\n" +
              "rebooting the machine. By placing the privileged section \n" +
              "in another executable and granting unconfined \n" +
              "execution rights, it is possible to bypass the mandatory \n" +
              "constraints imposed on all confined processes.\n" +
              "For more information on what is constrained, see the\n" +
              "apparmor(7) man page."
          ) + "<br><br>" +
          _("<b>Discrete Profile execute mode</b><br>") +
          _(
            "This mode requires that a discrete security profile is\n" +
              "defined for a resource executed at a AppArmor domain\n" +
              "transition.  If there is no profile defined then the\n" +
              "access will be denied.  Incompatible with Inherit and\n" +
              "Unconstrained execute entries."
          ) + "<br><br>" +
          _("<b>Link mode</b><br>") +
          _(
            "Allows the program to be able to create and remove a\n" +
              "link with this name (including symlinks). When a link\n" +
              "is created, the file that is being linked to MUST have\n" +
              "the same access permissions as the link being created\n" +
              "(with the exception that the destination does not have\n" +
              "to have link access.) Link access is required for\n" +
              "unlinking a file."
          ) + "<br><br>" +
          _("<b>Globbing</b>") + "<br><br>" +
          _(
            "File resources may be specified with a globbing syntax\n" +
              "similar to that used by popular shells, such as csh(1),\n" +
              "bash(1), zsh(1)."
          ) + "<br>" + "<ul>" +
          _(
            "<li><b>*</b>   can substitute for any number of characters, except '/'<li>"
          ) +
          _(
            "<li><b>**</b>  can substitute for any number of characters, including '/'</li>"
          ) +
          _(
            "<li><b>?</b>   can substitute for any single character except '/'</li>"
          ) +
          _(
            "<li><b>[abc]</b> will substitute for the single character a, b, or c</li>"
          ) +
          _(
            "<li><b>[a-c]</b> will substitute for the single character a, b, or c</li>"
          ) +
          _(
            "<li><b>{ab,cd}</b> will expand to one rule to match ab, one rule to match cd</li>"
          ) + "</ul>" +
          _("<b>Clean Exec - for sanitized execution</b>") + "<br><br>" +
          _(
            "The Clean Exec option for the discrete profile and unconstrained \n" +
              "execute permissions provide added security by stripping the \n" +
              "environment that is inherited by the child program of specific \n" +
              "variables. You will be prompted to choose whether you want to sanitize the\n" +
              "environment if you choose 'p' or 'u' during the profiling process.\n" +
              "The variables are:"
          ) + "<ul>" +
          "<li>GCONV_PATH</li>" +
          "<li>GETCONF_DIR</li>" +
          "<li>HOSTALIASES</li>" +
          "<li>LD_AUDIT</li>" +
          "<li>LD_DEBUG</li>" +
          "<li>LD_DEBUG_OUTPUT</li>" +
          "<li>LD_DYNAMIC_WEAK</li>" +
          "<li>LD_LIBRARY_PATH</li>" +
          "<li>LD_ORIGIN_PATH</li>" +
          "<li>LD_PRELOAD</li>" +
          "<li>LD_PROFILE</li>" +
          "<li>LD_SHOW_AUXV</li>" +
          "<li>LD_USE_LOAD_BIAS</li>" +
          "<li>LOCALDOMAIN</li>" + "<li>LOCPATH</li>" +
          "<li>MALLOC_TRACE</li>" + "<li>NLSPATH</li>" +
          "<li>RESOLV_HOST_CONF</li>" +
          "<li>RES_OPTION</li>" + "<li>TMPDIR</li>" +
          "<li>TZDIR</li> </ul>"
      }
    end
  end
end
