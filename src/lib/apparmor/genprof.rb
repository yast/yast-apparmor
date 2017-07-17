
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
      return nil if @program.nil?
      command = "/usr/sbin/aa-genprof --json #{@program}"
      super(command)
    end

    def execute
      super

      Yast::UI.OpenDialog(
        Opt(:decorated, :defaultsize),
        VBox(
          Label(_("Profile for #{@program} generated")),
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
