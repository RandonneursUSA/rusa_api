#!/usr/bin/perl
# Original script
# Author: James T. Kuehn (jtkuehn@frontiernet.net)
# Copyright 2010 James T. Kuehn
# =========================================================================
use Data::Dumper;
use JSON::PP;

require 'common3.pl';

my $query = $ENV{'QUERY_STRING'};

bail("Please pass in a RUSA member ID")  unless $query;
$mid = $query;

&opendb('R', 'mresults', 'rstatus', 'events', 'results', 'permanents', 'routes');
@rsidlist = split(/:/, $MRS{$mid});
bail("Sorry, no results for member $mid") unless @rsidlist;

my %results;

foreach $rsid (@rsidlist) {
  my %result;
	if($rsid =~ /^TB/){
	    &decode('rstatus', $RS{$rsid});
	    &decode('permanents', $PERM{$RS_pid});
	    $permid = $RS_pid;
	    $result{'date'} = $RS_date;
	    $result{'type'} = $PERM_superrand? 'ACPT-SR6': 'RUSAT';
	    $result{'dist'} = $RS_dist;
	    $result{'routename'} = "$PERM_startstate: $PERM_name";
	    $result{'routelink'} = "/cgi-bin/permview_GF.pl?permid=$RS_pid";
	    foreach $rid (split(/:/, $RS_ridlist)){
    		  &decode('results', $R{$rid});
		      next if($R_mid != $mid);
		      $result{'cert'} = $R_cert? $R_cert: 'pending';
	        $result{'time'} = $R_time;
		      last;
	   }
	}
	else{
	    &decode('rstatus', $RS{$rsid});
	    &decode('events', $E{$rsid});
	    next if($E_foreign); # don't show PBP here
	    if($E_rtid){
	        &decode('routes', $RT{$E_rtid});
		      $result{'routename'} = ($RT_name)? $RT_name: "route $E_rtid (unnamed)";
		      $result{'routelink'} = "/cgi-bin/routesearch_PF.pl?rtid=$E_rtid";
	    }
	    else{
		    $result{'routename'} = '?';
	    }
	    $result{'date'} = $E_date;
	    $result{'type'} = $E_type;
	    $result{'dist'} = $E_dist;
	    foreach $rid (split(/:/, $RS_ridlist)){
		      &decode('results', $R{$rid});
	 	      next if($R_mid != $mid);
		      $result{'cert'}   = $R_cert? $R_cert: 'pending';
	        $result{'time'}   = $R_time;
		      $result{'fdist'}  = $R_dist if($E_type =~ /ACPF|RUSAF/);
		      $result{'medal'}  = 'Y' if($E_type eq 'ACPB' && $R_medal);
		      last;
	    }
	}
  $results{$rsid} = \%result; 
}

&closedb('members', 'clubs', 'mresults', 'rstatus', 'events', 'results', 'permanents', 'routes');

# Print out results
# ---------------------------------
print "Content-type: application/json\n\n";
print encode_json \%results;

sub bail {
  my $err = @_ ? $_[0] : "It didn't work.";
  my $error =  '{"success":false,"payload":{},"error":{"code":123,"message":' . "$err" . '}}';
  print "Content-type: application/json\n\n", $error;
  exit;
}
