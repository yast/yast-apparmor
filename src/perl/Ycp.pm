# $Id: Ycp.pm 5800 2005-11-30 06:18:21Z dominic $
#

# ------------------------------------------------------------------
#
#    Copyright (C) 2002-2005 Novell/SUSE
#
#    This program is free software; you can redistribute it and/or
#    modify it under the terms of version 2 of the GNU General Public 
#    License published by the Free Software Foundation.
#
# ------------------------------------------------------------------

package Immunix::Ycp;

use strict;
use warnings;
#use Data::Dumper;

require Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(y2milestone y2debug ParseCommand Return ycpReturn ycpReturnSkalarAsString ycpReturnHashAsMap ycpGetCommand ycpGetArgType);

sub y2milestone { 

	my $mesg = shift;
	my $logFile = '/var/log/YaST2/imx-log';

	if ( open(LOG, ">>$logFile") ) {
		my $date = localtime;
		print LOG "$date: $mesg\n";
		close LOG;
	}

}

sub y2error {

	my $mesg = shift;
	my $logFile = '/var/log/YaST2/imx-errors';

	if ( open(LOG, ">>$logFile") ) {
		my $date = localtime;
		print LOG "$date: ERROR: $mesg\n";
		close LOG;
	}
}

sub y2debug { 

	my $mesg = shift;
	my $logFile = '/var/log/YaST2/imx-debug';

	if ( open(LOG, ">>$logFile") ) {
		my $date = localtime;
		print LOG "$date: DEBUG: $mesg\n";
		close LOG;
	}
}

sub ycpGetCommand { }
sub ycpGetArgType { }

sub perlToYcp {

  my $ref = shift;

  my $string;

  if(ref($ref) eq "HASH") {
    $string = '$[';
    for my $key (keys %$ref) {
      if($key =~ m/^\d+$/) {
        $string .= "$key:" . perlToYcp($ref->{$key}) . ",";
      } else {
        $string .= "\"$key\":" . perlToYcp($ref->{$key}) . ",";
      }
    }
    $string .= '] ';
  } elsif(ref($ref) eq "ARRAY") {
    $string = '[';
    for my $element (@$ref) {
      $string .= perlToYcp($element) . ',';
    }
    $string .= '] ';
  } elsif(defined $ref) {
    
    if($ref =~ m/^(true|false|nil|\d+)$/) {
      $string = "$ref";
    } else {
      $string = "\"$ref\"";
    }
  } else {
    $string = "nil";
  }
  return $string;
}

sub Return {
  my $data = shift;

  return ycpReturn($data);
}

sub ycpReturn {
  my $data = shift;

  my $string;
  if(ref($data)) {
    $string = perlToYcp($data);
  } else {
    $string = "(" . perlToYcp($data) . ")";
  }
  $| = 1;
  print $string;
}

sub ycpReturnHashAsMap {
  my %hash = @_;

  return ycpReturn(\%hash);
}

sub ycpReturnSkalarAsString {
  my $scalar = shift;

  return ycpReturn($scalar);
}

#my $data = { foo => [ "one", "two", "three" ], bar => "foobar" };
#my $data = [ "foo", [ "one", "two", "three" ], "bar", "foobar" ];
#Return($data);

sub ycpToPerl {
  my $string = shift || "";

  my $original_string = $string;

  my @stack = ( "TOPOFSTACK" );

  my $tree;
  my $where;
  my $key = "";

  # strip leading whitespace
  $string =~ s/^\s+//;
  # strip trailing comma or whitespace if they exist
  $string =~ s/,?\s*$//;

  while($string) {
    if($string =~ s/^\$\[//s) {                          # beginning of a hash
      
      # create a new hash ref
      my $hash = { };
  
      # insert it into the tree at our current location
      if(not $tree) {
        # if tree hasn't been set up yet, create it now as a hash
        $tree = $hash;
        $where = $tree;
      } elsif(ref($where) eq "ARRAY") {
        push @$where, $hash;
      } elsif(ref($where) eq "HASH") {
        if($key) {
          $where->{$key} = $hash;
        } else {
          die  "ERROR: trying to insert hash value without a key: $_";
        }
      } else {
        die "ERROR: clowns ate my brain: $_";
      }

      # zero out out the key for the new hash...
      $key = "";
  
      # push the parent onto the stack
      push @stack, $where;
  
      # our new "current" location is the newly created hash
      $where = $hash;
  
    } elsif($string =~ s/^\[//s) {                     # beginning of an array
  
      # create a new array ref
      my $array = [ ];
  
      # insert it into the tree at our current location
      if(not $tree) {
        # if tree hasn't been set up yet, create it now as an array
        $tree = $array;
        $where = $tree;
      } elsif(ref($where) eq "ARRAY") {
        push @$where, $array;
      } elsif(ref($where) eq "HASH") {
        if($key) {
          $where->{$key} = $array;
        } else {
          die "ERROR: trying to insert hash value without a key: $_";
        }
      } else {
        die "ERROR: Can't identify var for translation: $_";
      }
  
      $key = "";

      # push the parent onto the stack
      push @stack, $where;
  
      # our new "current" location is the newly created array
      $where = $array;
        
    } elsif($string =~ s/^(true|false|nil)(?=[,:\]])//s) {            # true/false
      my $value = $1;

      my $realvalue;
      $realvalue = 1     if $value eq "true";
      $realvalue = 0     if $value eq "false";
      $realvalue = undef if $value eq "nil";

      # shove it into the right place
      if(ref($where) eq "HASH") {
        if($key) {
          $where->{$key} = $realvalue;
          $key = "";
        } else {
          $key = $value;
        }
      } elsif(ref($where) eq "ARRAY") {
        push @$where, $realvalue;
      } else {
        die "ERROR: awoooga!  awooooga!: $string";
      }
    } elsif($string =~ s/^"([^"]*)"//s) {            # normal string
      my $value = $1;

      # shove it into the right place
      if(not $tree) {
        $tree = $value;
      } elsif(ref($where) eq "HASH") {
        if($key) {
          $where->{$key} = $value;
          $key = "";
        } else {
          $key = $value;
        }
      } elsif(ref($where) eq "ARRAY") {
        push @$where, $value;
      } else {
        die "ERROR: dogs don't know it's not bacon: $string";
      }
    } elsif($string =~ s/^(\d+)(?=[,:\]])//s) {               # normal integer
      my $value = $1;

      # shove it into the right place
      if(ref($where) eq "HASH") {
        if($key) {
          $where->{$key} = $value;
          $key = "";
        } else {
          $key = $value;    # ??? - can we use a bare integer as a hash key?
        }
      } elsif(ref($where) eq "ARRAY") {
        push @$where, $value;
      } else {
        die "ERROR: one by one the penguins steal my sanity: $string";
      }
    } elsif($string =~ s/^\]//) {
      # hit the end of this containing block, move back up a level
      $where = pop @stack;
      if($where eq "TOPOFSTACK") {
        die "ERROR: popped off top of stack: $string";
      }
    } else {
      y2error("ERROR: failed to parse: '$original_string'");
      die "ERROR: failed to parse: '$original_string'";
    }

    # strip trailing : or , and any whitespace
    $string=~ s/^[,:]\s*//s;
  }

  if(pop(@stack) ne "TOPOFSTACK") {
    die "ERROR: stack depth mismatch";
  }

  return $tree;
}

sub ParseCommand {
  my $string = shift;

  chomp $string;
  my $original_string = $string;

  if($string=~ m/^`?(\S+)\s*\((.+)\)\s*$/) {
    my ($cmd, $params) = ($1, $2); 

    if($params =~ m/^(\.\S*),\s*(.+)\s*$/) {
      my ($path, $args) = ($1, ycpToPerl($2));

      return ($cmd, $path, $args);
    } elsif($params =~ m/^(\.\S*)$/) {
      my $path = $1;

      return ($cmd, $path, "");
    } elsif($cmd eq "result" && $params eq "nil") {
      return ($cmd, "", "");
    } elsif($params eq "") {
      return ($cmd, "", "");
    } else {
      die "ERROR: failed to parse params: $params - $original_string\n";
    }
  } else {
    die "ERROR: failed to parse command: $string";
  }

}


#my $foo = ycpToPerl('$["one":"1one", "two":"2two", "three":["foo", $["holy":"catfish", "bacon":"cheese"], "baz"]]');

#my ($ycommand, $ypath, $yargument) = ParseCommand('Read(.foobar, $["one":"1one", "two":"2two", "three":["foo", $["holy":"catfish", "bacon":false], "baz"]])');

#print Data::Dumper->Dump([$ycommand, $ypath, $yargument], [qw(*ycommand *ypath *yargument)]);
#print Data::Dumper->Dump([$foo]);

1;

