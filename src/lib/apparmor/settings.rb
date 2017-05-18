# ***************************************************************************
#
# Copyright (c) 2017 SUSE Linux
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
# To contact SuSE about this file by physical or electronic mail,
# you may find current contact information at www.suse.com
#
# ***************************************************************************

require 'yast'
require 'ui/dialog'

Yast.import 'UI'
Yast.import 'Label'
Yast.import 'Popup'
Yast.import 'Service'

module AppArmor
  class ApparmorSettings < ::UI::Dialog
    include Yast::UIShortcuts
    include Yast::I18n

    def initialize
      super
      textdomain 'apparmor'
      @service_enabled = Yast::Service.Enabled('apparmor')
      # call the aaState_handler to identify status and enable/disable frame
      change_state
    end

    def dialog_options
      Opt(:decorated, :defaultsize)
    end

    def dialog_content
      VBox(
        Heading(_('Apparmor Settings')),
        VSpacing(1),
        VBox(
          CheckBox(Id(:aaState), Opt(:notify), _('&Enable Apparmor'), @service_enabled)
        ),
        VSpacing(1),
        Frame(
          Id(:aaEnableFrame),
          _('Configure Profiles'),
          HBox(
            Label(_('Configure Profile modes')),
            PushButton(Id(:modeconf), _('Configure'))
          )
        ),
        VSpacing(1),
        HBox(
          Right(
            PushButton(Id(:quit), Yast::Label.QuitButton)
          )
        )
      )
    end

    def modeconf_handler
      finish_dialog
    end

    def aaState_handler
      @service_enabled = Yast::UI.QueryWidget(:aaState, :Value)
      change_state
    end

    def quit_handler
      finish_dialog
    end

    def change_state
      status = Yast::Service.Enabled('apparmor')
      # If the service is the same state as our status, return
      return if status == @service_enabled

      # Change the state to what we have
      if @service_enabled
        Yast::Service.start('apparmor')
        Yast::Service.enable('apparmor')
      else
        Yast::Service.stop('apparmor')
        Yast::Service.disable('apparmor')
      end

      # Check if the change of service state worked
      status = Yast::Service.Enabled('apparmor')
      if status != @service_enabled
        Yast::Report.Error(_('Failed to change apparmor service. Please use journal (journalctl -n -u apparmor) to diagnose'))
      else
        # Enable the configuration frame since everything went well
        Yast::UI.ChangeWidget(Id(:aaEnableFrame), :Enabled, status)
      end
    end
  end
end
