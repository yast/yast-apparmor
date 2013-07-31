# Sources for apparmor

module_DATA = \
  modules/AppArmorDialogs.rb

client_DATA = \
  clients/AA_Report.rb \
  clients/AA_DeleteProfile.rb \
  clients/AA_EditProfile.rb \
  clients/apparmor_no_impl.rb \
  clients/apparmor.rb \
  clients/AA_AddProfile.rb \
  clients/GenProf.rb \
  clients/apparmor-settings.rb \
  clients/LogProf.rb

yncludedir = @yncludedir@/apparmor
ynclude_DATA = \
  include/apparmor/capabilities.rb \
  include/apparmor/reporting_dialogues.rb \
  include/apparmor/apparmor_profile_check.rb \
  include/apparmor/apparmor_packages.rb \
  include/apparmor/reporting_archived_dialogs.rb \
  include/apparmor/report_helptext.rb \
  include/apparmor/aa-config.rb \
  include/apparmor/reporting_utils.rb \
  include/apparmor/config_complain.rb \
  include/apparmor/apparmor_ycp_utils.rb \
  include/apparmor/helps.rb \
  include/apparmor/profile_dialogs.rb

scrconf_DATA = \
  scrconf/reports_sched.scr \
  scrconf/aaconf.scr \
  scrconf/reports_ess.scr \
  scrconf/apparmor_profiles.scr \
  scrconf/complain.scr \
  scrconf/genprof.scr \
  scrconf/logparse.scr \
  scrconf/reports_parse.scr \
  scrconf/apparmor.scr \
  scrconf/reports_confined.scr \
  scrconf/logprof.scr

agent_SCRIPTS = \
  servers_non_y2/ag_complain \
  servers_non_y2/ag_logprof.pm \
  servers_non_y2/ag_aa_config \
  servers_non_y2/ag_reports_parse \
  servers_non_y2/ag_apparmor_profiles \
  servers_non_y2/ag_logparse \
  servers_non_y2/ag_aa_config.pm \
  servers_non_y2/ag_apparmor.pm \
  servers_non_y2/ag_apparmor_profiles.pm \
  servers_non_y2/ag_reports_confined.pm \
  servers_non_y2/ag_reports_ess \
  servers_non_y2/ag_logprof \
  servers_non_y2/ag_reports_sched \
  servers_non_y2/ag_reports_sched.pm \
  servers_non_y2/ag_apparmor \
  servers_non_y2/ag_reports_parse.pm \
  servers_non_y2/ag_complain.pm \
  servers_non_y2/ag_reports_ess.pm \
  servers_non_y2/ag_logparse.pm \
  servers_non_y2/ag_genprof.pm \
  servers_non_y2/ag_reports_confined \
  servers_non_y2/ag_genprof

desktop_DATA = \
  desktop/apparmor.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(scrconf_DATA) $(agent_SCRIPTS) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common