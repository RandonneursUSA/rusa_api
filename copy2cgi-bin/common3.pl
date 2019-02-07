use MIME::Base64;

require 'cgi_form_util.pl';
require 'datetime.pl';
require 'print.pl';
require 'vars3.pl';
require 'states.pl';
require 'dbmtie.pl';

if ($ENV{'SKELFILE'}) {
    $skelfilename = $ENV{"SKELFILE"};
} else {
    $skelfilename = "/www/htdocs/rusa_skeleton.html";
}

#
# print messages about unexpected or unrecoverable errors
#
sub panic
{
    local($msg) = @_;
    &kprint($msg);
    exit(1);
}


sub add_datatables {
	print '<link rel="stylesheet" href="//cdn.datatables.net/1.10.11/css/jquery.dataTables.min.css" type="text/css" media="screen">';
	print '<script src="//cdn.datatables.net/1.10.11/js/jquery.dataTables.min.js"></script>';
}

sub kprint
{
    local($msg) = @_;
    if($ENV{'REMOTE_ADDR'}){    # are we a web cgi?
        &print_html_header('panic message') if(! $did_header);
        &print_hr;
        print "<P><B>PANIC:</B> $msg\n";
        print "<P>Please report this error message to $author\n";
        &print_continue;
        &print_hr;
        &print_html_footer;
    }
    else{
        print STDERR "$msg\n";
    }
}

sub print_html_header
{
    local($title, $elementname) = @_;
    print "Content-type: text/html\n\n";

    if($token eq ''){
        &fatal('r', $skelfilename) if(! -r $skelfilename);
        open(SKEL, "<$skelfilename");
        while(<SKEL>){
	    last if(/^\+\+\+/);
            s/\$title/$title/g;
            print;
	}
    }
    else{
        print "<HTML>\n";
        print "<HEAD><TITLE>$title</TITLE></HEAD>\n";
        print "<BODY BGCOLOR=\"#$bgcolor\"\n";
	print "LINK=\"#$linkcolor\" ALINK=\"#$alinkcolor\" VLINK=\"#$vlinkcolor\"\n";
	print "onLoad=\"self.focus();document.$elementname.focus()\"\n" if($elementname);
	print ">\n";
    }
    $did_header++;
}

sub print_html_footer
{
    if($token eq ''){
	while(<SKEL>){
	    print;
        }
        close(SKEL);
    }

    print "<script type='text/javascript'>";
    print "(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){";
    print "(i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),";
    print "m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)";
    print "})(window,document,'script','//www.google-analytics.com/analytics.js','ga');";
    print "ga('create', 'UA-51765480-1', 'rusa.org');";
    print "ga('require', 'displayfeatures');";
    print "ga('send', 'pageview');";
    print "</script>";

    print "</BODY>\n";
    print "</HTML>\n"
}

sub fatal
{
    local($rwx, $filename) = @_;
    $rwx = "read" if($rwx eq 'r');
    $rwx = "write" if($rwx eq 'w');
    $rwx = "execute" if($rwx eq 'x');
    print "<H1>Fatal error:</H1>\n";
    print "<P>Cannot $rwx file $filename. Contact administrator.\n";
    &print_html_footer;
    exit(1);
}

sub fatal_screen
{
    local($msg) = @_;
    if($ENV{'REMOTE_ADDR'}){	# are we a web cgi?
	&print_html_header('fatal error') if(! $did_header);
#	&print_hr;
	print "<P>$msg\n";
	print "<P>Contact $administrator\n";
#	&print_goback;
#	&print_hr;
	&print_html_footer;
    }
    else{
	print STDERR "$msg\n";
    }
    exit(1);
}

# copy the values supplied on the submitted form into F_fieldname vars
sub get_screen_inputs
{
    local($f, $varname);
    foreach $f (@formvars){
	$varname = "F_$f";
	${$varname} = &killspace($F{$f});
    }
    foreach $f (@multivars){
	$varname = "F_$f";
	@{$varname} = split(/\0/, $F{$f});
    }
}

# break fields of a record into simple variables named PREFIX_fieldname
sub decode
{
    local($dbname, $record) = @_;
    local($dbprefix, $f, $varname, $fieldarrayname, @dbdata);

    $dbprefix = $dbprefix{$dbname};
    @dbdata = split(/\0/, $record);

    # do the split on the database field names just once
    $fieldarrayname = "${dbprefix}_fields";
    if(! @{$fieldarrayname}){
		@{$fieldarrayname} = split(/:/, $dbfields{$dbname});
    }

    foreach $f (@{$fieldarrayname}){
		$varname = "${dbprefix}_$f";
		${$varname} = shift(@dbdata);
    }
}


# break fields of a record into simple variables named PREFIX_fieldname
sub decode_fake
{
    local($dbname, $record, $fake) = @_;
    local($dbprefix, $f, $varname, $fieldarrayname, @dbdata);

    $dbprefix = $dbprefix{$dbname};
    @dbdata = split(/\0/, $record);

    # do the split on the database field names just once
    $fieldarrayname = "${dbprefix}_fields";
    if(! @{$fieldarrayname}){
		@{$fieldarrayname} = split(/:/, $dbfields{$dbname});
    }

    foreach $f (@{$fieldarrayname}){
		$varname = "${fake}_$f";
		${$varname} = shift(@dbdata);
    }
}

# pack fields of a record from simple variables named PREFIX_fieldname
sub encode
{
    local($dbname) = @_;
    local($dbprefix, $f, $varname, $record, $fieldarrayname, @dbdata);

    $dbprefix = $dbprefix{$dbname};

    # do the split on the database field names just once
    $fieldarrayname = "${dbprefix}_fields";
    if(! @{$fieldarrayname}){
	@{$fieldarrayname} = split(/:/, $dbfields{$dbname});
    }

    foreach $f (@{$fieldarrayname}){
	$varname = "${dbprefix}_$f";
	push(@dbdata, ${$varname});
    }
    $record = join("\0", @dbdata);
}

# log authentications (logins), database transactions, and panic messages
#
sub log_transaction
{
    local($mid, $transaction, $object, $details) = @_;
    local($logfile, $record);

    $logfile = "$prefix/$basedir/log";
    $record = join("\0", $mid, $time, $transaction, $object, $details);

    open(DBA, ">>$logfile");
    &lockdb(DBA);
    print DBA "$record\n";
    close(DBA);
    &unlockdb(DBA);
    chmod(0664, $logfile);
}

#
# lockdb and unlockdb are only used to lock the log file
# all dbm databases are locked/unlocked when opened for reading or writing
#
sub lockdb
{
    local($handle) = @_;
    flock($handle, 2);  # exclusive
    # and in case someone appended while we were waiting...
    seek($handle, 0, 2);
}

sub unlockdb
{
    local($handle) = @_;
    flock($handle, 8);  # unlock
}

sub authenticate_user
{
    $time = time;
    srand($time|$$);

    &parse_form_data(*F);
    $token = $F{'token'};
    &read_values;
    if($token){
        &authenticate_token;
        &get_member($S_uid);
        &decode_capabilities($M_capabilities);
    }
}

sub authenticate_token
{
    local($record);
    local($authenticated) = 0;

    &opendb('W', 'session');
    &scrub_old_sessions;

    if($record = $S{$token}){
	&decode('session', $record);
	if($S_ip eq $ENV{'REMOTE_ADDR'}){
	    $authenticated++;

	    # update the time of last operation
	    $S_optime = $time;
	    $S{$token} = &encode('session');
	}
    }
    &closedb('session');

    &authentication_failure if(! $authenticated);
}

sub scrub_old_sessions
{
    local($token, $tokenage);

    # Go through each session and delete the old ones
    # All tokens expire at the hard limit
    # Tokens above the soft limit expire if no recent activity

    foreach $token (keys %S){
	&decode('session', $S{$token});
	$tokenage = $time - $S_tokentime;
	if($tokenage > $V_hard_timeout
	   || ($tokenage > $V_soft_timeout
	   && $time - $S_optime > $V_activity_interval)){
#	    print "<P>deleting old token $S{$token} age=$tokenage\n";
	    delete($S{$token});
	}
    }
}

sub authentication_failure
{
    &print_html_header("authentication failure");
    &print_screen('authentication failure', '');
    &print_hr;
    print "<H1>Token invalid or expired -- login required</H1>\n";
    &print_link("LOGIN", "$docprefix/login.html");
    &print_hr;
    &print_html_footer;
    exit(0);
}

sub makesalt
{
    local($rand1, $rand2);

    $rand1 = int(rand(64));
    $rand2 = int(rand(64));
    return(substr($saltalphabet, $rand1, 1).substr($saltalphabet, $rand2, 1));
}

sub get_value
{
    local($var) = @_;
    local($value);

    &opendb('R', 'value');
    if(defined($V{$var})){
	$value = $V{$var};
	&closedb('value');
	return($value);
    }
    else{
	&closedb('value');
	&fatal_screen("Attempt to access unknown internal variable $var");
    }
}

sub set_value
{
    local($var, $value) = @_;

    &opendb('W', 'value');
    if(defined($V{$var})){
	$V{$var} = $value;
	&closedb('value');
    }
    else{
	&closedb('value');
	&fatal_screen("Attempt to access unknown internal variable $var");
    }
}

sub incr_value
{
    local($var, $incr) = @_;
    local($value);
    &opendb('W', 'value');
    if(defined($V{$var})){
	$value = $V{$var};
	$V{$var} = $value+$incr;
	&closedb('value');
	return($value);
    }
    else{
	&closedb('value');
	&fatal_screen("Attempt to access unknown internal variable $var");
    }
}

sub killspace
{
    # kill spaces at the beginning and end of a string
    local($s) = @_;
    $s =~ s/^\s*//;
    $s =~ s/\s*$//;
    $s;
}

sub killspace_for_fields
{
    local($f, $var);
    foreach $f (@formvars){
	$var = "F_$f";
	${$var} = &killspace(${$var});
    }
}

sub get_member
{
    local($mid) = @_;

    # open the member database and get the record
    &opendb('R', 'members');
    &decode('members', $M{$mid});
    &closedb('members');
}

sub encode_capabilities
{
}

sub decode_capabilities
{
    local($capabilities) = @_;
    foreach $capid (split(/:/, $capabilities)){
	($capname, $capdesc) = split(/:/, $capabilities{$capid});
	$cap{$capname} = 1;
    }
}

sub read_capabilities
{
    @CAPkeys = sort(numerically keys(%capabilities));
    foreach $capid (@CAPkeys){
	($CAPname{$capid}, $CAPdesc{$capid}) = split(/:/, $capabilities{$capid});
    }
}

sub list_and
{
    local($a, $b) = @_;
    local(%c, $x);

    # find the intersection of two lists
    foreach $x (split(/:/, $a)){
	$c{$x}++;
    }
    join(":", grep($c{$_}, split(/:/, $b)));
}

sub list_or
{
    local($a, $b) = @_;
    local(%c, $x);

    # find the union of two lists
    foreach $x (split(/:/, $a)){
	$c{$x} = 1;
    }
    foreach $x (split(/:/, $b)){
	$c{$x} = 1;
    }
    join(":", keys(%c));
}

sub list_diff
{
    local($a, $b) = @_;
    local(%c, $x);

    # find the items in the first list that are not in the second
    foreach $x (split(/:/, $a)){
	$c{$x} = 1;
    }
    foreach $x (split(/:/, $b)){
	delete($x{$x});
    }
    join(":", keys(%c));
}

sub list_eq
{
    local($a, $b) = @_;
    local(%c, %d, $x);

    # return 1 if two lists are identical, otherwise return 0
    # lists may contain duplicate items
    foreach $x (split(/:/, $a)){
	$c{$x} = 1;
    }
    foreach $x (split(/:/, $b)){
	$d{$x} = 1;
    }
    @a = keys(%c);
    @b = keys(%d);

    return(0) if(@a != @b);
    @a = sort(numerically @a);
    @b = sort(numerically @b);
    foreach $x (@a){
	return(0) if($x != shift(@b));
    }
    1;
}

sub list_delete
{
    # delete an item from a list, returning the new list
    local($a, $item) = @_;
    local(%a, $x);

    foreach $x (split(/:/, $a)){
	$a{$x} = 1;
    }
    delete($a{$item});
    join(":", keys(%a));
}

sub list_add
{
    # add an item to a list, returning the new list
    local($a, $item) = @_;
    ($a)? join(':', $a, $item): $item;
}

sub list_card
{
    local($a) = @_;
    $_ = @_ = split(/:/, $a);
}

sub min
{
    local($a, $b) = @_;
    ($a < $b)? $a: $b;
}

sub max
{
    local($a, $b) = @_;
    ($a > $b)? $a: $b;
}

sub numerically { $a <=> $b; }

sub read_generic
{
    local($dbname) = @_;
    local($dbprefix, @fields, $keyname, $sortname, $defname);
    local($id, $value, @dbdata, $avar, %avar);

    $dbprefix = $dbprefix{$dbname};
    @fields = split(/:/, $dbfields{$dbname});
    $keyname = "${dbprefix}keys";
    $defname = "defn$dbprefix";
    $sortname = "by$dbprefix";

    # create a list of variable names, based on the prefix
    foreach (@fields){
        $avar{$_} = "$dbprefix$_";
    }

    &opendb('R', $dbname);
    @{$keyname} = ();
    while(($id, $value) = each(%{$dbprefix})){
        @dbdata = split(/\0/, $value);
        foreach (@fields){
            $avar = $avar{$_};
            $$avar{$id} = shift(@dbdata);
        }
        push(@{$keyname}, $id);
    }
    &closedb($dbname);

    &{$defname} if(defined(&{$defname}));
    @{$keyname} = sort($sortname @{$keyname}) if(defined(&{$sortname}));
}

sub byCOUNTRY { $COUNTRYname{$a} cmp $COUNTRYname{$b}; }

# define the award name and sortstring for award types
sub defnAWDT
{
    foreach (@AWDTkeys){
        $AWDTname{$_} = $awardtypes{$AWDTtype{$_}};
        $AWDTsortstring{$_} = join('', $AWDTname{$_}, $AWDTseries{$_}, sprintf("%04d", $AWDTdist{$_}));
    }
}
sub byAWDT { $AWDTsortstring{$a} cmp $AWDTsortstring{$b}; }

sub read_items
{
    local($iid, $value);
    local($I_name, $I_description, $I_icatid, $I_parentid, $I_listpos,
	$I_features, $I_size, $I_color, $I_fabric, $I_cost, $I_vendor,
	$I_price, $I_unit, $I_minquantity, $I_maxquantity, $I_quantityprice,
	$I_imagethumb, $I_imagelist, $I_promotion, $I_remarks,
	$I_noinventory, $I_nobackorder, $I_invthreshold, $I_buyers, $I_duedate,
	$I_shipruleid, $I_regshipruleid, $I_customprice);
    &opendb('R', 'items');
    while(($iid, $value) = each(%I)){
        &decode('items', $value);
        $Iname{$iid} = $I_name;
        $Iicatid{$iid} = $I_icatid;
        $Isize{$iid} = $I_size;
	$Iseltext{$iid} = ($I_size)? "$I_name - $I_size": $I_name;
	$Iparentid{$iid} = $I_parentid;
	$Ilistpos{$iid} = $I_listpos;
	$Ichildidlist{$I_parentid} = &list_add($Ichildidlist{$I_parentid}, $iid) if($I_parentid);
        push(@Ikeys, $iid);
    }
    &closedb('items');
    @Ikeys = sort(byIcat @Ikeys);
}

sub itemprice
{
    local($q) = @_;
    local($qrange, $qprice, $qlo, $qhi);
    foreach (split(/;/, $I_quantityprice)){
        ($qrange, $qprice) = split(/:/);
        ($qlo, $qhi) = split(/\-/, $qrange);
        $qhi = 99999 if(! $qhi);
        return($qprice) if($q>=$qlo && $q<=$qhi);
    }
    return($I_price);
}

sub byIcat
{
    my($la, $lb);
    $la = $ICATlistpos{$Iicatid{$a}};
    $lb = $ICATlistpos{$Iicatid{$b}};
    return($la <=> $lb) if($la != $lb);
    return($Ilistpos{$a} <=> $Ilistpos{$b}) if($Ilistpos{$a} != $Ilistpos{$b});
    $a <=> $b; # by item number
}

sub byICAT { $ICATlistpos{$a} <=> $ICATlistpos{$b}; }

sub count_categories
{
    local($iid, $value);
    &opendb('R', 'items');
    while(($iid, $value) = each(%I)){
        &decode('items', $value);
        $count{$I_icatid}++;
    }
    &closedb('items');
}

sub bySHIPRULE { $SHIPRULElistpos{$a} <=> $SHIPRULElistpos{$b}; }

sub count_shiprules
{
    local($iid, $value);
    &opendb('R', 'items');
    while(($iid, $value) = each(%I)){
        &decode('items', $value);
        $count{$I_shipruleid}++;
        $count{$I_regshipruleid}++;
    }
    &closedb('items');
}

sub defnIMG
{
    foreach (@IMGkeys){
	$IMGseltext{$_} = $IMGlinktext{$_}?
	    join(' - ', $IMGcaption{$_}, $IMGlinktext{$_}): $IMGcaption{$_};
    }
}
sub byIMG
{
    return ($IMGcaption{$a} <=> $IMGcaption{$b})
	if($IMGcaption{$a} =~ /^\d/ && $IMGcaption{$b} =~ /^\d/);
    $IMGcaption{$a} cmp $IMGcaption{$b};
}

sub byT { $Tlistpos{$a} <=> $Tlistpos{$b}; }
sub defnT
{
    foreach (@Tkeys){
        $allowtitle{$_}++ if($cap{'officialedit'}
            || $cap{'permofficialedit'} && $Tname{$_} =~ /Permanent/
            || $cap{'rbaofficialedit'} && $Tname{$_} =~ /Regional Brevet/);
    }
}

sub defnOFF
{
    foreach (@OFFkeys){
	$OFFname{$_} = join(', ', uc($OFFsname{$_}), $OFFfname{$_});
    }
}
sub byOFF { lc($OFFname{$a}) cmp lc($OFFname{$b}); }

sub byLETTER { lc($LETTERtitle{$a}) cmp lc($LETTERtitle{$b}); }

sub read_regions
{
    local($regid, $value);
    local($regname, $regrange);
    local(@rbas, $rba, $startdate, $enddate, $startyear, $endyear);
    local($REG_state, $REG_city, $REG_orgclub, $REG_rbaid, $REG_webaddr,
	$REG_status, $REGname,
	$REG_mapx, $REG_mapy, $REG_waiverdate, $REG_inslist,
	$REG_orgclubhist, $REG_rbahist);

    &opendb('R', 'regions');
    while(($regid, $value) = each(%REG)){
        &decode('regions', $value);
        $REGstate{$regid} = $REG_state;
	$REGcity{$regid} = $REG_city;
	$REGorgclub{$regid} = $REG_orgclub;
	$REGrbaid{$regid} = $REG_rbaid;
	$REGwebaddr{$regid} = $REG_webaddr;
	$REGstatus{$regid} = $REG_status;
	$regname = "$REG_state: $REG_city";

	# use the RBA history to set the start and end dates for the region
	@rbas = split(/;/, $REG_rbahist);
	($rba, $startdate, $enddate) = split(/:/, $rbas[0]);
	$startyear = substr($startdate, 0, 4);
	($rba, $startdate, $enddate) = split(/:/, $rbas[$#rbas]);
	$endyear = substr($enddate, 0, 4);
	$regrange = ($startyear eq $endyear)? $startyear: "$startyear-$endyear";

	$REGname{$regid} = $regname;
	$REGxname{$regid} = "$regname ($regrange)";
	$REGwaiverdate{$regid} = $REG_waiverdate;
	$REGmapx{$regid} = $REG_mapx;
	$REGmapy{$regid} = $REG_mapy;
	$REGinslist{$regid} = $REG_inslist;
	$REGorgclubhist{$regid} = $REG_orgclubhist;
	$REGrbahist{$regid} = $REG_rbahist;
	push(@REGkeys, $regid);
    }
    &closedb('regions');

    @REGkeys = sort(byregionname @REGkeys);
    undef(@REGactivekeys);
    foreach $regid (@REGkeys){
	push(@REGactivekeys, $regid) if($REGstatus{$regid});
    }
}

sub byregionname
{
    $REGname{$a} cmp $REGname{$b};
}

sub rbabyregdate
{
    local($regid, $date) = @_;
    local($rba, $startdate, $enddate);
    foreach (split(/;/, $REGrbahist{$regid})){
	($rba, $startdate, $enddate) = split(/:/);
	$enddate = $default_enddate if(! $enddate);
	return($rba) if($date ge $startdate && $date le $enddate);
    }
    return('');
}

sub orgclubbyregdate
{
    local($regid, $date) = @_;
    local($cid, $startdate, $enddate);
    foreach (split(/;/, $REGorgclubhist{$regid})){
	($cid, $startdate, $enddate) = split(/:/);
	$enddate = $default_enddate if(! $enddate);
	return($cid) if($date ge $startdate && $date le $enddate);
    }
    return('');
}

sub newInsuranceFeb2016
{
	my($date) = @_;
	if ($date lt '2016/02/01') {
		return 0;
	}
	return 1;
}

# this should be replaced by a database
sub insrate
{
    my($date) = @_;
    return(1.60) if($date lt '2010/02/15');
    return(1.63) if($date lt '2013/02/16');
    return(1.67) if($date lt '2014/02/16');
	return(1.95) if($date lt '2016/03/01');
    return 5.00;
}

sub byC { $a <=> $b; }

sub Cusfirst
{
    # US club ACP codes start with 9, so put those first
    return($a <=> $b) if($a =~ /^9/ && $b =~ /^9/);
    return($a <=> $b) if($a !~ /^9/ && $b !~ /^9/);
    return($b <=> $a);
}

sub read_clubs_assignable
{
    &build_statecode_index;
    &opendb('R', 'clubs');
    while(($cid, $value) = each(%C)){
        next if($cid =~ /^9[0-5]\d\d9[59]$/);        # don't want Independents or RUSA
        &decode('clubs', $value);
        next if($C_status ne 'A'); # don't want inactive
        if($cid =~ /^9[0-5]/){       # US club
            $state = $state_by_code{substr($cid, 1, 2)};
        }
        else{
            $state = 'FOREIGN';
        }
        $Cname{$cid} = "$C_name ($state)";
        push(@Ckeys, $cid);
    }
    @Ckeys = sort(byCname @Ckeys);
}

sub byCname
{
    $Cname{$a} cmp $Cname{$b};
}

sub byGR { $GRname{$a} cmp $GRname{$b}; }
sub defnGR
{
    foreach (@GRkeys){
	push(@GRactivekeys, $_) if($GRstatus{$_});
    }
}

sub send_mail
{
    local($to, $subject, $tmpfile, $cc, $bcc) = @_;
    $cc = "-c $cc" if($cc);
    $bcc = "-b $bcc" if($bcc);
    local($cmd) = "/usr/bin/mail -s '$subject' $cc $bcc $to < $tmpfile";
    system($cmd);
}

sub finishers
{
    local($type) = @_;
    local($nf);
    $nf = @_ = split(/:/, $RS_ridlist);
    return($nf) if($type !~ /F$/);

    # for team events, we must ignore the team nodes
    foreach (@_){
	&decode('results', $R{$_});
	$nf-- if($R_mid == -1);
    }
    $nf;
}

sub finisherdays
{
    local($h, $m, $d, $fd);
    $fd = 0;
    foreach (split(/:/, $RS_ridlist)){
        &decode('results', $R{$_});
        next if($R_mid == -1);  # skip team nodes
        ($h, $m) = split(/:/, $R_time);
        $h-- if($m == 0);       # consider 24:00 as 1 day
        $d = int($h / 24) + 1;
        $fd += $d;
    }
    $fd;
}

sub expdate
{
    my($curexpdate, $term) = @_;
    my($cy, $cm, $cd) = split(/\//, $today);
    my($expyear);
    if($curexpdate lt $today){  # expired membership
        $expyear = ($cm <= (12-$V_bonusmonths))? $cy+$term-1: $cy+$term;
    }
    else{       # extend by term years
        $expyear = substr($curexpdate, 0, 4) + $term;
    }
    sprintf($dateformat, $expyear, 12, 31);
}

sub m_or_tm
{
    my($mid) = @_;
    if($mid =~ /^T/){
	$mid = substr($mid, 1);
        &decode('tmembers', $TM{$mid});
        $M_fname = $TM_fname;
        $M_mname = $TM_mname;
        $M_sname = $TM_sname;
        $M_xname = $TM_xname;
    }
    else{
        &decode('members', $M{$mid});
    }
}

sub extract_state
{
    my($s) = @_;
    $s =~ /^[^,]+, ([A-Z]{2})/;
    $1;
}

sub obscure_zip
{
    my($s) = @_;
    $s =~ s/\-\d{4}$/-xxxx/;
    $s;
}

sub obscure_phone
{
    my($s) = @_;
    return($s) unless($s);

    if($s =~ /^\+/){
        my($cc, $num) = $s =~ /^(\+\d{1,3}) ([0-9\-]+)$/;
        # preserve first and last digits only
        my($p1, $p2, $p3) = $num =~ /^(.)(.+)(.)$/;
        $p2 =~ y/[0-9]/x/;
        return("$cc $p1$p2$p3");
    }
    else{
        # preserve area code, first digit of prefix, and last digit
        return(join('', substr($s, 0, 5), 'xx-xxx', substr($s, length($s)-1, 1)));
    }
}

sub obscure_email
{
    my($s) = @_;
    return($s) unless($s);
    my($n, $d) = split(/\@/, $s);
    # preserve first letter of name, first letter of domain, and final
    # part of top-level domain, for example, foo@bar.org becomes f**@b**.org
    $n = join('', substr($n, 0, 1), 'x' x (length($n)-1));
    my($tld) = $d =~ /(\.[a-zA-Z]+)$/;
    $d =~ s/$tld$//;
    $d = join('', substr($d, 0, 1), 'x' x (length($d)-1), $tld);
    join('@', $n, $d);
}

sub obscure_address
{
    my($s) = @_;
    $s =~ y/[a-zA-Z0-9]/x/;
    $s;
}

sub js_email {
	my($email) = @_;
	$email =~ s/\./_dot_/g;
	$email =~ s/\@/_at_/g;
	$email = encode_base64($email);
	# print($email);
	# print("\n");
	return $email;
}

1;
