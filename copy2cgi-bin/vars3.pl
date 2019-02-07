use POSIX; use GDBM_File; use Time::Local;

$webmaster = 'webmaster@rusa.org';
$author = 'webmaster@rusa.org';
$administrator = $author;

$prefix = '/www/htdocs';
$docprefix = '';
$cgi = '/cgi-bin';
$cgiprefix = "$docprefix/cgi-bin";
$basedir = 'Data';
$helpdir = "$docprefix/help";
$progname = 'RUSA';

$dbdir = "/usr/share/nginx/gdbm";

# ==========================================================================
# DBM DATABASE DESCRIPTIONS
#     colon-separated list consisting of the base file name of the database,
#     the prefix letter to use for names, and the field names
# ==========================================================================
# member database
$dbname{'members'} = "members";
$dbprefix{'members'} = "M";
$dbkey{'members'} = "mid";
$dbfields{'members'} = "sname:fname:password:passtime:capabilities:joindate:expdate:updated:renewdate:address:city:state:zip:country:clubacp:phone:fax:email:gender:birthdate:pubaddress:mailnews:othermid:remarks:hidlist:mname:xname";

# member change history database
$dbname{'mhistory'} = 'mhistory';
$dbprefix{'mhistory'} = 'MH';
$dbkey{'mhistory'} = 'mhid';
$dbfields{'mhistory'} = 'mid:date:fid:from:to:letterid';

# membership request queue
$dbname{'mreq'} = 'mreq';
$dbprefix{'mreq'} = 'MREQ';
$dbkey{'mreq'} = 'mreqid';
$dbfields{'mreq'} = 'op:date:term:mid:addmid:newmid:dropmid:orderid:newclubtmidlist:status:tmidlist';

# temporary members database (address changes, new members)
$dbname{'tmembers'} = "tmembers";
$dbprefix{'tmembers'} = "TM";
$dbkey{'tmembers'} = "tmid";
$dbfields{'tmembers'} = "mid:fname:mname:sname:xname:joindate:expdate:address:city:state:zip:country:clubacp:phone:phone2:email:gender:birthdate";

# surnames database
$dbname{'surnames'} = "surnames";
$dbprefix{'surnames'} = "MS";
$dbkey{'surnames'} = "sname";
$dbfields{'surnames'} = "midlist";

# official database
$dbname{'officials'} = "officials";
$dbprefix{'officials'} = "OFF";
$dbkey{'officials'} = "mid";
$dbfields{'officials'} = "sname:fname:address:city:state:country:zip:phone:fax:email:term:reelect:phone2:newrba:newpro:remarks";

# office title database
$dbname{'titles'} = "titles";
$dbprefix{'titles'} = "T";
$dbkey{'titles'} = "tid";
$dbfields{'titles'} = "name:midlist:listpos:showterm:showregion:shownew:showchair:chairmid:message";

# club database
$dbname{'clubs'} = "clubs";
$dbprefix{'clubs'} = "C";
$dbkey{'clubs'} = "acpcode";
$dbfields{'clubs'} = "name:status:date:notes";

# club ACP number request
$dbname{'creq'} = "creq";
$dbprefix{'creq'} = "CREQ";
$dbkey{'creq'} = "creqid";
$dbfields{'creq'} = "tmid:name:clubacp:members:poc:address:city:state:zip:schedule:newsletter:website:affiliate:reqdate:criteria:mreqid:email";

# state database
$dbname{'states'} = "states";
$dbprefix{'states'} = "ST";
$dbkey{'states'} = "abbrev";
$dbfields{'states'} = "name:code";

# country name database
$dbname{'countries'} = "countries";
$dbprefix{'countries'} = "COUNTRY";
$dbkey{'countries'} = "countryid";
$dbfields{'countries'} = "name:itucode";

# zipcode database
$dbname{'zipcode'} = 'zipcode';
$dbprefix{'zipcode'} = "ZIP";
$dbkey{'zipcode'} = "zip";
$dbfields{'zipcode'} = "city:state:lat:long:tz:isdst";

# region database
$dbname{'regions'} = "regions";
$dbprefix{'regions'} = "REG";
$dbkey{'regions'} = "regid";
$dbfields{'regions'} = "state:city:orgclub:rbaid:webaddr:status:mapx:mapy:waiverdate:inslist:startdate:enddate:orgclubhist:rbahist";

# insurance certificate database
$dbname{'inscert'} = "inscert";
$dbprefix{'inscert'} = "INS";
$dbkey{'inscert'} = "insid";
$dbfields{'inscert'} = "carrier:insured:startdate:enddate:rcvdate:remarks";

# event database
$dbname{'events'} = "events";
$dbprefix{'events'} = "E";
$dbkey{'events'} = "eid";
$dbfields{'events'} = "regid:date:type:dist:status:datesub:dateapp:rtid:grid:foreign:remarks:collidlist";

# permanent database
$dbname{'permanents'} = "permanents";
$dbprefix{'permanents'} = "PERM";
$dbkey{'permanents'} = "pid";
$dbfields{'permanents'} = "name:startcity:startstate:endcity:endstate:type:dist:climbing:mid:dates:statelist:fee:dateadd:datereviewed:description:url:free:reversible:status:remarks:climbmethod:superrand:superranddate:collidlist";

# route database
$dbname{'routes'} = "routes";
$dbprefix{'routes'} = "RT";
$dbkey{'routes'} = 'rtid';
$dbfields{'routes'} = "regid:dist:datesub:dateapp:approver:start:controls:submitter:filed:active:name:remarks:secrets:statelist:collidlist";

# grand randonnee name database
$dbname{'grandrand'} = "grandrand";
$dbprefix{'grandrand'} = "GR";
$dbkey{'grandrand'} = 'grid';
$dbfields{'grandrand'} = "name:abbrev:status";

# start location dispute table
$dbname{'locdisp'} = 'locdisp';
$dbprefix{'locdisp'} = 'LOCDISP';
$dbkey{'locdisp'} = 'locdispid';
$dbfields{'locdisp'} = 'mid:rsid:date:rtid:pid:startloc:endloc:remarks:statelist:other:status:datedone';

# result processing status database
$dbname{'rstatus'} = "rstatus";
$dbprefix{'rstatus'} = "RS";
$dbkey{'rstatus'} = "rsid"; # eid or TBxxx
$dbfields{'rstatus'} = "status:history:ridlist:trouble:pid:date:dnfr:dnfd:dist:reversed:membercount:nonmembercount:ridlistdnf";

# result database
$dbname{'results'} = "results";
$dbprefix{'results'} = "R";
$dbkey{'results'} = "rid";
$dbfields{'results'} = "mid:sname:fname:time:medal:cert:dist:dist2:bicycle:dnf:sex";

# result DNF database
$dbname{'resultsdnf'} = "resultsdnf";
$dbprefix{'resultsdnf'} = "RDNF";
$dbkey{'resultsdnf'} = "rid";
$dbfields{'resultsdnf'} = "mid:sname:fname:days";

# events/perms by member (index)
$dbname{'mresults'} = "mresults";
$dbprefix{'mresults'} = "MRS";
$dbkey{'mresults'} = "mid";
$dbfields{'mresults'} = "rsidlist";

# item (store) database
$dbname{'items'} = 'items';
$dbprefix{'items'} = 'I';
$dbkey{'items'} = 'iid';
$dbfields{'items'} = 'name:description:icatid:parentid:listpos:features:size:color:fabric:cost:vendor:price:unit:minquantity:maxquantity:quantityprice:imagethumb:imagelist:promotion:remarks:noinventory:nobackorder:duedate:shipruleid:invthreshold:buyers:regshipruleid:customprice:sizing:startdate:enddate';

# item category database
$dbname{'icat'} = 'icat';
$dbprefix{'icat'} = 'ICAT';
$dbkey{'icat'} = 'icatid';
$dbfields{'icat'} = 'name:listpos:imgid:buyers';

# item inventory database
$dbname{'inventory'} = 'inventory';
$dbprefix{'inventory'} = 'INV';
$dbkey{'inventory'} = 'iid'; # same keys as items
$dbfields{'inventory'} = 'midqlist:pending';

# shipping rate database
$dbname{'shiprule'} = 'shiprule';
$dbprefix{'shiprule'} = 'SHIPRULE';
$dbkey{'shiprule'} = 'shipruleid';
$dbfields{'shiprule'} = 'name:description:listpos:c1:c2';

# image database
$dbname{'image'} = 'image';
$dbprefix{'image'} = 'IMG';
$dbkey{'image'} = 'imgid';
$dbfields{'image'} = 'filename:caption:linktext';

# store shopping cart database
$dbname{'cart'} = 'cart';
$dbprefix{'cart'} = 'CART';
$dbkey{'cart'} = 'ip';
$dbfields{'cart'} = 'time:mid:regid:name:foreign:itemlist:awardlist';

# orders database
$dbname{'orders'} = "orders";
$dbprefix{'orders'} = 'ORDER';
$dbkey{'orders'} = 'orderid';
$dbfields{'orders'} = 'mid:regid:date:paydate:paymethod:paystatus:itemlist:shiplist:amtsubtotal:amtship:amtcredit:amttotal:addresstype:reason:name:address:city:state:zip:country:phone:email:awardlist:reminddate:amtpaid:amtppfee:createmid:remarks:mreqid:paymid';

# award type database
$dbname{'awardtypes'} = "awardtypes";
$dbprefix{'awardtypes'} = 'AWDT';
$dbkey{'awardtypes'} = 'awdtid';
$dbfields{'awardtypes'} = "summary:type:dist:series:iid:startdate:enddate:mid:hasapp:hastrinket";

# user award database
$dbname{'mawards'} = "mawards";
$dbprefix{'mawards'} = 'MAWD';
$dbkey{'mawards'} = 'mid';
$dbfields{'mawards'} = "awdidlist";

# award database
$dbname{'awards'} = "awards";
$dbprefix{'awards'} = 'AWD';
$dbkey{'awards'} = 'awdid';
$dbfields{'awards'} = "awdtid:rsidlist:applydate:approvedate:purchdate:series";

# RUSA SR database
$dbname{'rusasr'} = "rusasr";
$dbprefix{'rusasr'} = 'RUSASR';
$dbkey{'rusasr'} = 'mid';
$dbfields{'rusasr'} = 'flag';

# account posting database
$dbname{'account'} = "account";
$dbprefix{'account'} = 'ACCT';
$dbkey{'account'} = 'acctid';
$dbfields{'account'} = "ref:date:amt:mid";

# PayPal transaction id database
$dbname{'pptxnid'} = "pptxnid";
$dbprefix{'pptxnid'} = 'PPTXNID';
$dbkey{'pptxnid'} = '';
$dbfields{'pptxnid'} = 'id';

# Upload directories database
$dbname{'updirs'} = 'uploaddirs';
$dbprefix{'updirs'} = 'UPDIR';
$dbkey{'updirs'} = 'updirid';
$dbfields{'updirs'} = 'path:description:maxsize:overwrite:midlist';

# RSS channels database
$dbname{'channels'} = 'channels';
$dbprefix{'channels'} = 'CHAN';
$dbkey{'channels'} = 'chanid';
$dbfields{'channels'} = 'title:description:link:status';

# form letters database
$dbname{'letters'} = 'letters';
$dbprefix{'letters'} = 'LETTER';
$dbkey{'letters'} = 'letterid';
$dbfields{'letters'} = 'title:status:body:type:use:subject';

# accident report database
$dbname{'accident'} = 'accident';
$dbprefix{'accident'} = 'ACC';
$dbkey{'accident'} = 'accid';
$dbfields{'accident'} = 'rcvdate:mid:name:gender:age:type:regid:date:dist:pid:bike:tod:edist:description:injury:factors:rbaremarks:privateremarks';

# collection (of events, routes, or permanent routes)
$dbname{'collection'} = 'collection';
$dbprefix{'collection'} = 'COLL';
$dbkey{'collection'} = 'collid';
$dbfields{'collection'} = 'name:type:eidlist:rtidlist:permidlist';

# session database
$dbname{'session'} = "session";
$dbprefix{'session'} = "S";
$dbkey{'session'} = "token";
$dbfields{'session'} = "uid:tokentime:optime:ip:sortorder";

# value database
$dbname{'value'} = "values";
$dbprefix{'value'} = "V";

sub read_values
{
    my($key, $value);
    &opendb('R', 'value');
    while(($key, $value) = each(%V)){
	${"V_$key"} = $value;
    }
    &closedb('value');
}

$default_bgcolor = "FFFFFF";            # white
$default_textcolor = "000000";          # black
$default_linkcolor = "0000FF";          # blue
$default_alinkcolor = "FF0000";         # red
$default_vlinkcolor = "0000FF";         # blue
$default_highlightcolor = "FFFFaa";     # yellow

$bgcolor = $default_bgcolor;
$textcolor = $default_textcolor;
$linkcolor = $default_linkcolor;
$alinkcolor = $default_alinkcolor;
$vlinkcolor = $default_vlinkcolor;
$hightlightcolor = $default_highlightcolor;

$default_startdate = "0000/00/00";
$default_enddate = "9999/99/99";
$default_maxrecords = 500;
$seconds_per_hour = 3600;
$seconds_per_day = 24 * 3600;
$feet_per_meter = 3.28084;
$saltalphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789./";

$memberemail = 'membership@rusa.org';
$memberemaillink = "<A HREF=\"mailto:$memberemail\">Membership Chairman</A>";

# items sold in the RBA medal store, in order of appearance
#@regionmedalstore = (7, 181, 183, 182, 184, 185); # ppin/medals
@regionmedalstore = (7, 259, 258, 257, 256, 255, 228); # ppin/medals; added fleche pin

# RUSA event types
@eventtypes = ('RM', 'ACPB', 'ACPF', 'RUSAP', 'RUSAB', 'RUSAF' );
%eventnames_by_type =
    (
     'RM', 'RM randonn&eacute;e',
     'ACPB', 'ACP brevet',
     'ACPF', 'ACP fl&egrave;che',
     'RUSAP', 'RUSA populaire',
     'RUSAB', 'RUSA brevet',
     'RUSAF', 'RUSA arrow/dart/dart populaire',
     'RUSAT', 'RUSA permanent'
     );

# Event status codes
@eventstatustypes = ('S', 'R', 'C', 'T', 'H', 'X');
@onpubliccalendar = ('R', 'C');
%eventstatusnames =
    (
        'S', 'Submitted (awaiting approval)',
        'R', 'Approved',
        'C', 'Canceled (current)',
        'T', 'Test',
        'H', 'Archived',
        'X', 'Canceled (archived)',
    );

# the following types of events contribute to ACP points
@ACPpoints = ('ACPB');
# the following types of events contribute to RUSA points
@RUSApoints = ('RM', 'ACPB', 'ACPF', 'RUSAP', 'RUSAB', 'RUSAF');

@permtypes = ('LOOP', 'OB', 'PP');
%permnames_by_type =
    (
     'PP', 'point-to-point',
     'OB', 'out & back',
     'LOOP', 'loop'
     );

%bicycletypes =
    (
	1, 'single',
	2, 'tandem',
	3, 'triplet',
    );

%awardtypes =
    (
	'rm',	'RM Randonnee',
	'acpb', 'ACP Brevet',
	'r5000', 'ACP Randonneur 5000',
	'sr',	'ACP Super Randonneur',
	'arc',	'RUSA American Randonneur Challenge',
	'c2c',	'RUSA Coast to Coast',
	'rd',	'RUSA Distance',
	'khound','RUSA K-Hound',
	'r12',	'RUSA R-12',
	'r120', 'RUSA Ultra R-12',
	'ur',	'RUSA Ultra Randonneur',
	'anniv10', 'RUSA 10th Anniversary',
	'mond', 'RUSA Mondial',
	'galaxy', 'RUSA Galaxy',
	'p12',  'RUSA P-12',
	'amex', 'RUSA American Explorer',
	'cup',  'RUSA Cup',
	'pop',	'RUSA Populaire',
	'team',	'RUSA Fl&egrave;che/Arrow/Dart',
    );

# these define classes of buyers in the store
@buyercodes = ('M', 'R', 'P');
%buyerclass = (
    'M', 'members',
    'R', 'RBAs/regions',
    'P', 'public',
);

# these indicate status of store orders
%paystatus = (
    0,	'awaiting',
    2,  'PayPal failed, awaiting',
    3,  'needs pricing or shipping calculation',
    8,  'annual billing',
    9,  'paid'
);
%shipstatus = (
    0,  'awaiting',
    1, 'partial shipment',
    9, 'complete'
);

@lettertypes = ('newpri', 'newsec', 'renew',
    'clubok', 'clubno', 'badbirthdate', 'nochange', 'deleteorder',
    'memberhelp', 'other');
%lettertypenames = (
    'newpri', 'New Primary',
    'newsec', 'New Secondary',
    'renew',  'Renewal',
    'clubok', 'Club Added',
    'clubno', 'Club Rejected',
    'badbirthdate', 'Bad Birthdate',
    'nochange', 'No Change Requested',
    'deleteorder', 'Deleting Order',
    'memberhelp', 'Membership Help',
    'other',  'Other'
);

# the following codes define what people are permitted to do on the system
%capabilities =
    (
     10, 'memberview:can view full member database',
     11, 'memberedit:can modify member database',
     12, 'membercap:can modify member capabilities and generate passwords',
     20, 'clubview:can view full club database',
     21, 'clubedit:can modify club database',
     40, 'eventview:can view full event database',
     41, 'eventedit:can modify event database',
     #42, 'eventsubmit:can submit event calendar',
     43, 'regionedit:can modify region table',
     44, 'insview:can view regional insurance table',
     45, 'insedit:can edit regional insurance table',
     51, 'officialedit:can modify full official/volunteer database',
     52, 'titleedit:can modify position title database',
     53, 'permofficialedit:can modify officials within the permanent organizer category',
     54, 'rbaofficialedit:can modify officials within the RBA category',
     60, 'resultview:can view full results database',
     61, 'resultedit:can modify results database',
     #62, 'resultsubmit:can submit results',
     #63, 'resultsubmitview:can view submitted results',
     64, 'resultpermedit:can modify permanent results database',
     65, 'resultrusaedit:can modify domestic results database',
     71, 'routeedit:can modify route database',
     72, 'permedit:can modify permanent routes database',
     73, 'permmapedit:can modify permanent location map',
     80, 'regionaccountview:can view regional invoices',
     81, 'regionaccountedit:can modify regional invoices',
     #82, 'medalsubmit:can submit medal orders',
     90, 'storeview:can view store items and inventory',
     91, 'storeedit:can modify store item descriptions and inventories',
     92, 'storeship:can process orders and ship items',
     93, 'storeprice:can modify store prices',
     94, 'storepost:can mark all types of orders as paid',
     95, 'storempost:can mark membership orders as paid',
    100, 'logview:can view transaction logs',
    110, 'awardview:can view award applicants',
    111, 'awardSR:can manage SR award database',
    112, 'awardR5000:can manage R5000 award database',
    113, 'awardRD:can manage RUSA distance award database',
    114, 'awardUR:can manage Ultra Randoneur award database',
    115, 'awardR12:can manage R-12 award database',
    116, 'awardARC:can manage Amer. Rand. Challenge award database',
    117, 'awardC2C:can manage Coast-to-Coast award database',
    118, 'awardMOND:can manage Mondial/Galaxy award database',
    119, 'awardP12:can manage P-12 award database',
    120, 'awardAMEX:can manage Amer. Explorer award database',
    121, 'awardCUP:can manage RUSA Cup award database',
    122, 'awardKH:can manage K-Hound award database',
    123, 'awardR120:can manage R-12 Ultra award database',
    130, 'channeledit:can modify RSS channels',
    131, 'contentedit:can add content to selected RSS feeds',
    140, 'upload:can upload files',
    141, 'uploaddir:can manage upload directories',
    150, 'accidentview:can view accident report database',
    151, 'accidentedit:can modify accident report database',
    999, 'dbadmin:DB administrator use only, certain operations may leave tables in an inconsistent state',
    );

# locations of images
%image =
    (
    'help', "/Images/Icons/question.gif",
    'home', "/Images/Icons/home.gif",
    'uparrow', "/Images/Icons/a_up.gif",
    'downarrow', "/Images/Icons/a_down.gif",
    'exit', "/Images/Icons/door_exit.gif",
    'cart', "/Images/Icons/cart2.jpg"
    );

1;
