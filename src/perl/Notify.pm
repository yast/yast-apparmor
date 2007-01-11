# ------------------------------------------------------------------
#
#    Copyright (C) 2005-2006 Novell/SUSE
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of version 2 of the GNU General Public
#    License published by the Free Software Foundation.
#
# ------------------------------------------------------------------

package Immunix::Notify;

################################################################################
# /usr/lib/perl5/vendor_perl/Immunix/Notify.pm
#
#   - Parses /etc/apparmor/notify.cfg for AppArmor notification
#   - Used with sd-config.ycp for yast configuration
#
################################################################################

use strict;
use ycp;
use POSIX;
use Locale::gettext;

setlocale(LC_MESSAGES, "");
textdomain("yast2-apparmor");

use constant NTCONF => '/etc/apparmor/notify.cfg';

sub debug {
  my $cf = shift;

  for my $type ( keys %$cf) {
      ycp::y2milestone("[apparmor] Type: $type");
      for my $rec ( keys %{$cf->{ $type }} ) {
          ycp::y2milestone("[apparmor]\t$rec value: $cf->{$type}{$rec}");
      }
  }
}


# Replaces old files with new files
sub updateFiles {

    my ( $oldFile, $newFile )  = @_;

    if ( unlink("$oldFile") ) {
        if ( ! rename ("$newFile", "$oldFile") ) {
            if ( ! system('/bin/mv', "$newFile","$oldFile") ) {
                Immunix::Ycp::y2error(sprintf(gettext("Failed copying %s."), $oldFile));
                return 1;
            }
        }
    } else {
        system('/bin/rm', "$oldFile");
        system('/bin/mv', "$newFile", "$oldFile");
    }

    return 0;
}

sub safeFormat {

  my $emailAddr = shift;
  my $safeFormat = 0;

  if ( $emailAddr && (length($emailAddr) < 129) ) {

    #if ( $emailAddr =~ /^\w+[\.\w]+\@[\w+\.]+\w+$/ ||
	if ( $emailAddr =~ /^(\w+\.?)+\w+\@(\w+\.?)+\w+$/ ||
		      $emailAddr =~ /^\/var\/mail\/\w+$/ ) {
      $safeFormat = 1;
    } else {
       ycp::y2milestone("[apparmor] email address contains invalid
				characters.");
    }

  } else {
    ycp::y2milestone("[apparmor] email address is too long--more than
			128 characters.");
  }

  return $safeFormat;
}

# check for reasonable values (especially email address)
sub sanitize {

  my $newConfig = shift;
  my $oldConfig = getNotifySettings();
  my $result = "success";

	if ( $newConfig->{'set_notify'}) {
	  delete($newConfig->{'set_notify'});     # don't need this anymore
	}

  # Sanitize, reverting to current values if poorly formed email address
  for my $type (keys(%$newConfig)) {

    my $enable = "enable_" . "$type";
    my $email = "$type" . "_email";

	next unless ($newConfig->{$type}->{$enable} eq 'yes');

        if ( $newConfig->{$type}->{$enable} eq "yes" && !
				safeFormat($newConfig->{$type}->{$email}) ) {
            $result = "Error in email address format.  Skipping changes
						for $type notification.";
            ycp::y2milestone("[apparmor] $result");
            $newConfig->{$type} = $oldConfig->{$type};
        }
    }

    return ($newConfig, $result);
}

sub getNotifyStatus {

  my $config = getNotifySettings();

  my $noteStatus = "disabled";

  if ( $config->{terse}->{terse_freq} && $config->{terse}->{terse_freq} != 0) {
    $noteStatus = "enabled";
  } elsif ( $config->{summary}->{summary_freq} && 
					$config->{summary}->{summary_freq} != 0) {
    $noteStatus = "enabled";
  } elsif ( $config->{verbose}->{verbose_freq} &&
					$config->{verbose}->{verbose_freq} != 0) {
    $noteStatus = "enabled";
  }

  return $noteStatus;
}

sub delBadEntries {

  my $config = shift;
  my @delList = ();

  # Remove bad entries pulled from config file
  for my $type (keys(%$config)) {
    if ( $type !~ /(summary|terse|verbose)/ ) {
		push(@delList, $type);
		next;
    } else {

        my $freq = $type . "_freq";
        my $email = $type . "_email";
        my $level = $type . "_level";
        my $unk  = $type . "_unknown";
        no strict;

		if ( ! $config->{$type}->{$email} ) {
			push(@delList, $type);
			next;
		}	

        for my $val ( keys %{$config->{ $type }} ) {
          if ( $val eq $freq ) {
            if ( $config->{$type}->{$val} !~ /\d+/ ) {
              $config->{$type}->{$val} = 0;
            }
          } elsif ( $val eq $email ) {
            if ( ! safeFormat($config->{$type}->{$val}) ) {
              push(@delList, $type);
              next;
            }
          } elsif ( $val eq $level ) {
            if ( ! ($config->{$type}->{$val} =~ /\d\d/ &&
						$config->{$type}->{$val} < 11) ) {
              $config->{$type}->{$val} = 0;
            }
          } elsif ( $val eq $unk ) {
            $config->{$type}->{$val} =~ /[0|1]/ || 0;
          }
        }
    }
  }

  # Delete entire record if bad email address
  for (@delList) {
    delete($config->{$_});
  }

  return $config;
}

sub getNotifySettings {

  my $config = ();
  my $cleanConfig = ();
  my $ntConf = NTCONF; 

  if ( open(CFG, "<$ntConf") ) {
    while(<CFG>) {
      chomp;
      $config->{$2}{$1} = $4 if /^((\S+)_(\S+))\s+(.+)\s*$/;
    }
    close(CFG);

    # delete notification entries without a reasonable email address 
    $cleanConfig = delBadEntries($config);

  } else {
    ycp::y2milestone("[apparmor] Couldn't open $ntConf.");
  }

  return $cleanConfig;
}

sub setNotifySettings {

  my $config = shift;
  my $result = "success";
  my $ntConf = NTCONF; 

  Immunix::Reports::enableEventD();
  if ( open(CFG, "> $ntConf") ) {
    if($config->{terse}->{enable_terse} eq "yes") {
      # if we didn't get passed a valid frequency, default to off
      $config->{terse}->{terse_freq}  ||= 0;
      $config->{terse}->{terse_level} ||= 0;
      # default to including unknown events if we didn't get passed that setting
      $config->{terse}->{terse_unknown} = 1 unless defined $config->{terse}->{terse_unknown};
      print CFG "terse_freq $config->{terse}->{terse_freq}\n";
      print CFG "terse_email $config->{terse}->{terse_email}\n";
      print CFG "terse_level $config->{terse}->{terse_level}\n";
      print CFG "terse_unknown $config->{terse}->{terse_unknown}\n";
    }
    if($config->{summary}->{enable_summary} eq "yes") {
      # if we didn't get passed a valid frequency, default to off
      $config->{summary}->{summary_freq} ||= 0;
      $config->{summary}->{summary_level} ||= 0;
      # default to including unknown events if we didn't get passed that setting
      $config->{summary}->{summary_unknown} = 1 unless defined $config->{summary}->{summary_unknown};
      print CFG "summary_freq $config->{summary}->{summary_freq}\n";
      print CFG "summary_email $config->{summary}->{summary_email}\n";
      print CFG "summary_level $config->{summary}->{summary_level}\n";
      print CFG "summary_unknown $config->{summary}->{summary_unknown}\n";
    }
    if($config->{verbose}->{enable_verbose} eq "yes") {
      # if we didn't get passed a valid frequency, default to off
      $config->{verbose}->{verbose_freq} ||= 0;
      $config->{verbose}->{verbose_level} ||= 0;
      # default to including unknown events if we didn't get passed that setting
      $config->{verbose}->{verbose_unknown} = 1 unless defined $config->{verbose}->{verbose_unknown};
      print CFG "verbose_freq $config->{verbose}->{verbose_freq}\n";
      print CFG "verbose_email $config->{verbose}->{verbose_email}\n";
      print CFG "verbose_level $config->{verbose}->{verbose_level}\n";
      print CFG "verbose_unknown $config->{verbose}->{verbose_unknown}\n";
    }
    close(CFG);
  } else {
    $result = "Unable to write config changes to $ntConf";
    ycp::y2milestone("[apparmor] $result: $!");
  }

  return($result);
}


1;

