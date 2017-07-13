
require 'open3'
require 'json'
require 'yast'
require 'apparmor/apparmor_ui_dialog'

Yast.import 'UI'
Yast.import 'Label'
Yast.import 'Popup'

module AppArmor
  # GenProf class executes the aa-genprof command and generates
  # the appropriate dialogs for the yast UI
  class GenProf
    GENPROF = '/usr/sbin/aa-genprof'.freeze
    attr_reader :program
    include Yast::UIShortcuts
    include Yast::Logger
    include Yast::I18n

    def initialize
      @program = Yast::UI.AskForExistingFile('/', '*',
                                             _('Choose a program to generate a profile for'))
      return nil unless @program.nil?
    end

    def execute
      cmd = "#{GENPROF} --json #{@program}"
      log.info "Executing #{cmd}"
      IO.popen(cmd, 'r+') do |f|
        f.sync = true
        f.each do |line|
          log.info "aa-genprof lines #{line}."
          next unless line.start_with?('{')
          hm = JSON.parse(line)
          log.info "aa-genprof hashmap #{hm}."
          l = get_dialog(hm)
          r = l.run
          unless r.nil?
            f.puts r.to_json
            f.flush
          end
        end
      end
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

    private

    def get_dialog(hm)
      case hm['dialog']
      when 'yesno'
        YesNoDialog.new(hm)
      when 'yesnocancel'
        YesNoCancelDialog.new(hm)
      when 'info'
        InfoDialog.new(hm)
      when 'important'
        ImportantDialog.new(hm)
      when 'getstring'
        GetStringDialog.new(hm)
      when 'getfile'
        GetFileDialog.new(hm)
      when 'promptuser'
        PromptDialog.new(hm)
      when 'apparmor-json-version'
        AAJSONVersion.new(hm)
      else
        Yast::Report.Error(_('Unknown Dialog %s returned by apparmor') % hm['dialog'])
        nil
      end
    end
  end
end
