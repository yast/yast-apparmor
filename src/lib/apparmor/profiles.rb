# Get the status of profiles loaded
#  - enforced
#  - complain
# Uses aa-status --json

require 'json'
require 'open3'
Yast.import 'UI'
Yast.import 'Label'
Yast.import 'Popup'

module AppArmor
  # Class representing a single apparmor profile
  class Profile
    attr_reader :name, :status, :pid

    def initialize(name, status)
      textdomain 'apparmor'
      @name = name
      @status = status
      @pid = []
    end

    # Return/Set the name of the profile
    def name(n = '')
      @name = n unless n.empty?
      @name
    end

    # return the current status
    def status(s = '')
      @status = s if s != ''
      @status
    end

    # Set to complain mode
    def complain
      system("/usr/sbin/aa-complain #{@name}")
      status('complain')
    end

    # Set to enforce mode
    def enforce
      system("/usr/sbin/aa-enforce #{@name}")
      status('enforce')
    end

    def addPid(p)
      @pid.push(p)
    end

    attr_reader :pid

    def toggle
      if @status == 'complain'
        enforce
      else
        complain
      end
    end

    def to_s
      @name + ', ' + @status + ', ' + @pid
    end

    def to_array
      a = []
      a.push(@name)
      a.push(@status)
      pstr = ' '
      # Convert PID array to a pretty string with commas
      @pid.each do |p|
        pstr = pstr + p.to_str + ', '
      end
      a.push(pstr)
      a
    end
  end

  # Class representing a list of profiles
  class Profiles
    attr_reader :raw, :prof
    def initialize
      status_output = `/usr/sbin/aa-status --json`
      jtext = JSON.parse(status_output)
      h = jtext['profiles']
      @prof = {}
      h.each do |name, status|
        @prof[name] = Profile.new(name, status)
      end
      h = jtext['processes']
      h.each do |name, pidmap|
        pidmap.each do |p|
          @prof[name].addPid(p['pid'])
        end
      end
    end

    def active
      # Select the ones which have pids
      @prof.reject { |_name, pr| pr.pid.empty? }
    end

    def all
      @prof
    end

    def toggle(name)
      @prof[name].toggle
    end
  end

  class ProfilesDialog < ::UI::Dialog
    include Yast::UIShortcuts
    include Yast::I18n
    include Yast::Logger

    def initialize
      super
      @profiles = Profiles.new
      @active = true
    end

    def dialog_options
      Opt(:decorated, :defaultsize)
    end

    def dialog_content
      VBox(
        # Header
        Heading(_('Profile List')),
        # Active profiles
        Left(
          CheckBox(Id(:active_only), Opt(:notify), _('Show Active only'), @active)
        ),
        VSpacing(0.4),
        # Profile List
        table,
        VSpacing(0.3),
        # Footer buttons
        HBox(
          HWeight(1, PushButton(Id(:changeMode), _('Change mode'))),
          HStretch(),
          HWeight(1, PushButton(Id(:finish), Yast::Label.FinishButton))
        )
      )
    end

    def table
      headers = Array[_('Name'), _('Mode'), _('PID')]
      Table(
        Id(:entries_table),
        Opt(:keepSorting),
        Header(*headers),
        table_items
      )
    end

    def table_items
      profs = if @active
                @profiles.active
              else
                @profiles.all
              end
      arr = []
      profs.each do |_n, pr|
        arr.push(pr.to_array)
      end
      arr.map { |i| Item(*i) }
    end

    def redraw_table
      Yast::UI.ChangeWidget(Id(:entries_table), :Items, table_items)
    end

    def changeMode_handler
      selected_item = Yast::UI.QueryWidget(Id(:entries_table), :CurrentItem)
      log.info "Toggling #{selected_item}"
      @profiles.toggle(selected_item)
      redraw_table
    end

    def active_only_handler
      @active = Yast::UI.QueryWidget(Id(:active_only), :Value)
      redraw_table
    end

    def finish_handler
      finish_dialog
    end
  end
end
