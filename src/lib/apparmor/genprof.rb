
require 'yast'
require 'apparmor/apparmor_ui_dialog'

Yast.import 'UI'
Yast.import 'Label'
Yast.import 'Popup'

module AppArmor
  # GenProf class executes the aa-genprof command and generates
  # the appropriate dialogs for the yast UI
  class GenProf < AAProgram
    include Yast::UIShortcuts
    include Yast::Logger
    include Yast::I18n

    def initialize
      textdomain 'apparmor'
      @program = Yast::UI.AskForExistingFile('/usr/bin/', '*',
                                             _('Choose a program to generate a profile for'))
      command = "/usr/sbin/aa-genprof --json #{@program}"
      super(command)
    end

    def execute
      return nil if @program.nil?
      super

      Yast::UI.OpenDialog(
        Opt(:decorated, :defaultsize),
        VBox(
          # TRANSLATORS: file path
          Label(_("Profile for %s generated") % @program),
          VSpacing(2),
          HBox(
            HStretch(),
            HWeight(1, PushButton(Id(:ok), Yast::Label.OKButton)),
            HStretch()
          )
        )
      )
      Yast::UI.UserInput()
      Yast::UI.CloseDialog()
    end
  end
end
