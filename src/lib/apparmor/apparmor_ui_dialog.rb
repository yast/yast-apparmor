# This file has all the dialog translations/representations
# which come from the apparmor's json
# show_respond() must return what would be communicated back to
# the program in the form of a hash map. It could be nil if no
# data must be written.

require 'yast'

Yast.import 'UI'
Yast.import 'Label'
Yast.import 'Report'
Yast.import 'Popup'

module AppArmor
  # A Dialog to confirm Yes/No from the user
  class YesNoDialog
    include Yast::UIShortcuts
    include Yast::I18n
    def initialize(hm)
      @data = hm['text']
      @map = {}
      @map['dialog'] = 'yesno'
    end

    def run
      if Yast::Popup::YesNo(@data)
        @map['response'] = 'yes'
        @map['response_key'] = 'y'
      else
        @map['response'] = 'no'
        @map['response_key'] = 'n'
      end
      @map
    end
  end

  # A Dialog to confirm Yes/No/Cancel from the user
  class YesNoCancelDialog
    include Yast::UIShortcuts
    include Yast::I18n
    include Yast::Logger
    def initialize(hm)
      @data = hm['data']
      @map = {}
      @map['dialog'] = 'yesnocancel'
      @focus = :focus_yes
      @focus = case hm['default']
               when :n
                 :focus_no
               when :c
                 :focus_retry
               else
                 :focus_yes
               end
    end

    def run
      input = Yast::Popup::AnyQuestion3(
        Yast::Popup::NoHeadline(),
        @data,
        Label.YesButton,
        Label.NoButton,
        Label.CancelButton,
        @focus
      )

      case input
      when :yes
        @map['response'] = 'yes'
        @map['response_key'] = 'y'
      when :no
        @map['response'] = 'no'
        @map['response_key'] = 'n'
      when :retry
        @map['response'] = 'cancel'
        @map['response_key'] = 'c'
      end
      @map
    end
  end

  # Just to consume/log information received from the command
  # Does not perform any function
  class InfoDialog
    include Yast::Logger
    def initialize(hm)
      log.info "Hash map #{hm}"
    end

    def run
      nil
    end
  end

  class ImportantDialog
    include Yast::Logger
    def initialize(hm)
      log.info "Hash map #{hm}"
    end

    def run
      nil
    end
  end

  # Get a string from the user
  class GetStringDialog
    include Yast::UIShortcuts
    include Yast::I18n
    include Yast::Logger
    def initialize(hm)
      log.info "Hash map #{hm}"
      @map = {}
      @map['dialog'] = 'getstring'
    end

    def run
      Yast::UI.OpenDialog(
        Opt(:decorate, :defaultsize),
        VBox(
          Inputfield(Id(:str), @text),
          PushButton('&OK')
        )
      )
      str = Yast::UI.QueryWidget(Id(:str), :Value)
      Yast::UI.UserInput()
      Yast::UI.CloseDialog()
      @map['response'] = str
      @map
    end
  end

  # Get a file path from the user
  class GetFileDialog
    include Yast::UIShortcuts
    include Yast::I18n
    include Yast::Logger
    def initialize(hm)
      log.info "Hash map #{hm}"
      @map = {}
      @map['dialog'] = 'getfile'
    end

    def run
      filename = Yast::UI.AskForExistingFile('/etc/apparmor.d', '*',
                                             _('Choose a file'))
      @map['response'] = filename unless filename.nil?
      @map
    end
  end

  # A prompt dialog has a title, a list of options (Checkboxes) and a
  # couple of actions (buttons)
  class PromptDialog
    include Yast::UIShortcuts
    include Yast::I18n
    include Yast::Logger
    include Yast
    def initialize(hm)
      log.info "Hash map #{hm}"
      @map = {}
      @map['dialog'] = 'promptuser'
      @title = hm['title']
      @headers = hm['headers']
      @explanation = hm['explanation']
      @options = hm['options']
      @menu_items = hm['menu_items']
    end

    def run
      @map['selected'] = 0
      # Display the dynamic widget

      UI.OpenDialog(
        Opt(:decorated, :defaultsize),
        VBox(
          *explanation_label,
          *header_labels,
          *options_radio_buttons,
          *menu_buttons
        )
      )

      @map['response_key'] = Yast::UI.UserInput()
      selected = Yast::UI.QueryWidget(:options, :CurrentButton)
      @map['selected'] = selected.to_i
      Yast::UI.CloseDialog
      @map
    end

    private

    def explanation_label
      box = VBox(VSpacing(1))
      box << Label(@explanation) if @explanation
    end

    def header_labels
      @headers.each_with_object(VBox()) do |pair, result|
        key, value = pair
        result << Label(key.to_s + ': ' + value.to_s)
        result << VSpacing(1)
      end
    end

    def options_radio_buttons
      box = VBox()
      return box if @options.nil?
      @options.each_with_index do |opt, i|
        log.info "opt #{opt} i #{i}"
        box << RadioButton(Id(i.to_s), opt.to_s, i == 0)
        box << VSpacing(1)
      end
      VBox(RadioButtonGroup(Id(:options), box))
    end

    def menu_to_text_key(menu)
      ind = menu.index('(')
      key = menu[ind + 1, 1].downcase
      text = menu.delete('(').delete(')').delete('[').delete(']')
      [text, key]
    end

    def menu_buttons
      box = HBox()
      @menu_items.each do |menu|
        text, key = menu_to_text_key(menu)
        box << PushButton(Id(key.to_s), text)
        box << HSpacing(1)
      end
      VBox(box)
    end
  end

  # Checks JSON version of the tool and if we are compatible
  class AAJSONVersion
    include Yast::I18n
    include Yast::Logger
    AA_JSON = 2.12
    def initialize(hm)
      log.info "Hash map #{hm}"
      @json_version = hm['data'].to_f
    end

    def run
      if @json_version > AA_JSON
        Yast::Report.Error(_(format('Apparmor JSON version %s is greater than %0.2f', @json_version, AA_JSON)))
      end
    end
  end
end
