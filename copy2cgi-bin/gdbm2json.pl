#!/usr/bin/perl

# ------------------------------------------
# File: gbdm2json.pl
# Author: Paul Lieberman
# Created: May  2017
# Purpose: Web API to query RUSA
#
# Updated:
#    2018-09-20 - PL - Protect private data
#               
# -------------------------------------------

# use strict;
use GDBM_File;
use JSON::PP;

require 'vars.pl';

my @data; # global variables
my $data_dir = "/usr/share/nginx/gdbm";

my $query = $ENV{'QUERY_STRING'};

my ($qkey, $qval); 
my ($dbname, $squery) = split /&/, $query;
if ($squery) {
  ($qkey, $qval) = split /=/, $squery; 
}

$dbname = "regions" unless $dbname;

# Read the data from the GDBM file
# ----------------------------------
tie(my %data, "GDBM_File", "$data_dir/$dbname", 1, 0) or die "Can't open file";

my @fields = split(/:/, $dbfields{$dbname});
my $dbkey  = $dbkey{$dbname};


while (my ($key,$val) = each %data) {
  my %record;
  $record{$dbkey} = $key;
  my(@record) = split(/\0/, $val);
  my $i = 0;
  for my $field (@fields) {
    $record{$field} = $record[$i++];
  }
  if ($qkey) {
    if ($record{$qkey} eq $qval) {
      push @data, {%record};
      next;
    }
  }
  else {
    push @data, {%record};
  }
}
untie  %data;

# Remove non public data
# ------------------------------
if ($dbname eq "members") {
  @stripfields = ('address','city', 'state', 'zip', 'country', 'phone', 'phone2', 'fax', 'email', 'gender', 'birthdate', 'password');
  for my $record (@data) {
    for my $field (@stripfields) {
      ${$record}{$field} = undef;
    }
  }
}

if ($dbname eq "officials") {
  @stripfields = ('address','city', 'state', 'zip', 'country', 'phone', 'phone2', 'fax', 'email', 'gender', 'birthdate', 'password');
  for my $record (@data) {
    for my $field (@stripfields) {
      ${$record}{$field} = undef;
    }
  }
}

 




# Print out results
# ---------------------------------
print "Content-type: application/json\n\n";
print encode_json \@data;


