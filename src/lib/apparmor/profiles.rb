# Get the status of profiles loaded
#  - enforced
#  - complain
# Uses aa-status --json

require 'json'
require 'open3'
require 'yast'
Yast.import 'UI'
Yast.import 'Label'
Yast.import 'Popup'

module AppArmor
  # Class representing a single apparmor profile
  class Profile
    attr_reader :name, :status, :pid

    def initialize(name, status)
      @name = name
      @status = status
      @pid = []
    end

    # Set to complain mode
    def complain
      system("/usr/sbin/aa-complain #{@name}")
      @status = 'complain'
    end

    # Set to enforce mode
    def enforce
      system("/usr/sbin/aa-enforce #{@name}")
      @status = 'enforce'
    end

    def addPid(p)
      @pid.push(p)
    end

    def toggle
      if @status == 'complain'
        enforce
      else
        complain
      end
    end

    def to_s
      "#{@name}, #{@status}, #{@pid}"
    end

    def to_array
      a = []
      a.push(@name)
      a.push(@status)
      pstr = @pid.map(&:to_str).join(", ")
      a.push(pstr)
      a
    end
  end

  # Class representing a list of profiles
  class Profiles
    include Yast::Logger
    attr_reader :prof
    def initialize
      @prof = {}
      status_output = command_output("/usr/sbin/aa-status", "--pretty-json")
      log.info("aa-status output:\n#{status_output}\n")
      jtext = JSON.parse(status_output)
      add_profiles(jtext["profiles"])
      add_processes(jtext["processes"])
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

  private

    # Add all profiles from the "profiles" section of the parsed JSON output of
    # the aa-status command.
    #
    # Sample JSON:
    #
    #  "profiles": {
    #      "/usr/bin/lessopen.sh": "enforce",
    #      "/usr/lib/colord": "enforce",
    #      "/usr/{bin,sbin}/dnsmasq": "enforce",
    #      "nscd": "enforce",
    #      "ntpd": "enforce",
    #      "syslogd": "enforce",
    #      "traceroute": "enforce",
    #      "winbindd": "enforce"
    #  }
    def add_profiles(profiles)
      return if profiles.nil?
      profiles.each do |name, status|
        log.info("Profile name: #{name} status: #{status}")
        @prof[name] = Profile.new(name, status)
      end
    end

    # Add all processesfrom the "profiles" section of the parsed JSON output of
    # the aa-status command.
    #
    # Sample JSON:
    #
    # "processes": {
    #     "/usr/sbin/nscd": [
    #         {
    #             "profile": "nscd",
    #             "pid": "805",
    #             "status": "enforce"
    #         }
    #     ],
    #     "/usr/lib/colord": [
    #         {
    #             "profile": "/usr/lib/colord",
    #             "pid": "1790",
    #             "status": "enforce"
    #         }
    #     ]
    # }
    def add_processes(processes)
      return if processes.nil?
      processes.each do |executable_name, pidmap_list|
        pidmap_list.each do |pidmap|
          profile_name = pidmap["profile"] || executable_name
          pid = pidmap["pid"]
          if @prof.key?(profile_name)
            msg = "Active process #{pid} #{executable_name}"
            msg += " profile name #{profile_name}" if executable_name != profile_name
            log.info(msg)
            @prof[profile_name].addPid(pid)
          else
            log.warn("No profile #{profile_name}")
          end
        end
      end
    end

    # Returns the output of the given command
    #
    # @param args [Array<String>, Array<Array<String>>] the command to execute and
    #   its arguments. For a detailed description, see
    #   https://www.rubydoc.info/github/openSUSE/cheetah/Cheetah#run-class_method
    # @return [String] commmand output or an empty string if the command fails.
    def command_output(*args)
      Yast::Execute.locally!(*args, stdout: :capture)
    rescue Cheetah::ExecutionFailed
      ""
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
      textdomain "apparmor"
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
