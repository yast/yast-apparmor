
require 'yast'
require 'apparmor/apparmor_ui_dialog'

Yast.import 'UI'
Yast.import 'Label'
Yast.import 'Popup'

module AppArmor
  # LogProf class executes the aa-logprof command and generates
  # the appropriate dialogs for the yast UI
  class LogProf < AAProgram
    def initialize(logfile = '')
      textdomain "apparmor"
      @logfile = logfile
      command = '/usr/sbin/aa-logprof --json '
      command += " -f #{@logfile}" unless @logfile.empty?
      super(command)
    end

    def execute
      super
      Yast::UI.OpenDialog(
        Opt(:decorated, :defaultsize),
        VBox(
          # TRANSLATORS: file path
          Label(_("No more records in logfile %s to process") % @logfile),
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
