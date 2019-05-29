# Sources for apparmor

module_DATA = \
  modules/AppArmorDialogs.rb

client_DATA = \
  clients/apparmor_no_impl.rb \
  clients/apparmor.rb \
  clients/aa-genprof.rb \
  clients/aa-logprof.rb \
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
  lib/apparmor/apparmor_ui_dialog.rb \
  lib/apparmor/genprof.rb \
  lib/apparmor/logprof.rb \
  lib/apparmor/profiles.rb \
  lib/apparmor/settings.rb

desktop_DATA = \
  desktop/org.openSUSE.YaST.Apparmor.desktop

symbolicdir = @icondir@/hicolor/symbolic/apps
symbolic_DATA = \
  icons/hicolor/symbolic/apps/yast-apparmor-symbolic.svg

scalabledir = @icondir@/hicolor/scalable/apps
scalable_DATA = \
  icons/hicolor/scalable/apps/yast-apparmor.svg

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(ylib_DATA) $(desktop_DATA) $(symbolic_DATA) $(scalable_DATA)

include $(top_srcdir)/Makefile.am.common
