# Sources for apparmor

module_DATA = \
  modules/AppArmorDialogs.rb

client_DATA = \
  clients/AA_DeleteProfile.rb \
  clients/AA_EditProfile.rb \
  clients/apparmor_no_impl.rb \
  clients/apparmor.rb \
  clients/AA_AddProfile.rb \
  clients/aa-settings.rb

yncludedir = @yncludedir@/apparmor
ynclude_DATA = \
  include/apparmor/capabilities.rb \
  include/apparmor/apparmor_profile_check.rb \
  include/apparmor/apparmor_packages.rb \
  include/apparmor/aa-config.rb \
  include/apparmor/config_complain.rb \
  include/apparmor/apparmor_ycp_utils.rb \
  include/apparmor/helps.rb \
  include/apparmor/profile_dialogs.rb

ylibdir = @yast2dir@/lib/apparmor
ylib_DATA = \
  lib/apparmor/settings.rb

scrconf_DATA = \
  scrconf/aaconf.scr \
  scrconf/apparmor_profiles.scr \
  scrconf/complain.scr \
  scrconf/apparmor.scr

agent_SCRIPTS = \
  servers_non_y2/ag_complain \
  servers_non_y2/ag_complain.pm \
  servers_non_y2/ag_aa_config \
  servers_non_y2/ag_aa_config.pm \
  servers_non_y2/ag_apparmor \
  servers_non_y2/ag_apparmor.pm \
  servers_non_y2/ag_apparmor_profiles \
  servers_non_y2/ag_apparmor_profiles.pm

desktop_DATA = \
  desktop/apparmor.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(scrconf_DATA) $(agent_SCRIPTS) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common
