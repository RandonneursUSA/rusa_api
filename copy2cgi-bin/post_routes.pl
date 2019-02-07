#!/usr/bin/perl
# ------------------------------------------------------
# Author:   Paul Lieberman
# Created:  15-Jan-2018
#
# This script is called from Drupal to post route
# assigments to calendared events.
# 
# It is called with a POST of JSON content
#
# -------------------------------------------------------

use strict;
use JSON::PP;
use GDBM_File;
use Data::Dumper;

my $events_db = "/usr/share/nginx/gdbm/events";
my @dbfields = split(/:/, "regid:date:type:dist:status:datesub:dateapp:rtid:grid:foreign:remarks:collidlist");

my($updates, $data, @data, %data, $query_string, $error);

my $request_method = $ENV{'REQUEST_METHOD'};
my $content_type = $ENV{'CONTENT_TYPE'};

# Read the data
if($request_method eq "POST" && $content_type eq 'application/json'){
    read(STDIN, $query_string, $ENV{'CONTENT_LENGTH'});
    @data = url_decode($query_string);
    my $json = $data[0];

    eval {
        my $jobj = JSON::PP->new;
        $jobj->allow_nonref();
        my $tmp = $jobj->decode($json);
        $updates = $jobj->decode($tmp);

        # Save changes to GDBM file
        tie(my %data, "GDBM_File", $events_db, GDBM_WRITER, 0664);

        # Loop through updates and update the data
        while (my ($eid, $event) = each (%{$updates})) {
            my $record = decode($data{$eid});
            ${$record}{'rtid'} = ${$event}{'rtid'};
            ${$record}{'dist'} = ${$event}{'dist'};
            my $packed = encode($record);
            $data{$eid} = $packed;
        }
        untie $events_db;
        $error = '{"success":true,"payload":{}}';
    }
    or do {
        my $err = $@;
        open my $FH, ">", "/tmp/rba-post-error.txt";
        print $FH $err . "\n";
        close $FH;
        $error = '{"success":false,"payload":{},"error":{"code":123,"message":' . $err . '}}'; 
    }

}

print "Content-type: application/json\n\n", $error;


sub url_decode {
    my($key, $value, %data);

    my $query = shift;
    foreach (split(/&/, $query)){
        ($key, $value) = split (/=/);
        $value =~ tr/+/ /;
        $value =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack("C", hex($1))/eg;
        #$data{$key} = (defined($data{$key}))? join("\0", $data{$key}, $value): $value;
        $data{$key} = $value;
    }
    return %data;
}


# Break fields of a record into a hash
# Based on sub of the same name in common2.pl
sub decode {
    my ($record) = @_;  # holds the input
    my %record;         # holds the results

    my @dbdata = split(/\0/, $record);

    foreach my $field (@dbfields){
        $record{$field} = shift(@dbdata);
    }
    return \%record;
}



# pack fields of a record from hash
sub encode {
    my ($record) = @_;  # hashref to record
    my @record;         # holds the results
    my @dbdata;

    foreach my $field (@dbfields) {
        push(@dbdata, ${$record}{$field});
    }
    $record = join("\0", @dbdata);
    return $record;
}
