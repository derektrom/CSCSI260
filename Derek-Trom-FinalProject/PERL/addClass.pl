#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Session;
use File::Spec;
use DBI;
use strict;
my $dataSource = "DBI:mysql:f19final:localhost";
my $dbh = DBI->connect ($dataSource, "root", "pass260word");
if (!$dbh){
    print header(), start_html("Oops, no database");
   print "Unable to connect to the database\n\n";
   print end_html();
   exit;
} 
my $result;
my $added = 0;
my $class = param('classname');
my $department = param('department');
my $classnumber = param ('classnum');
my $mark = param('grade');
my $numcredits = param('credits');
my $add = param('add');
my $back = param('home');
my $sql = "INSERT INTO tblclasses (classname, department, classnum, grade, credits) VALUES('$class', '$department', '$classnumber', '$mark', '$numcredits')";
my $sth = $dbh->prepare ($sql);
my $sessionID = cookie('cs260');
my $session = new CGI::Session (undef, $sessionID, {Directory=>File::Spec->tmpdir()});

   
sub verifyLogin{
    
    if ($session->param('loggedIn')){
    
        my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+90s');
    }
}
sub buttons{
    print start_form(-action=>'/cgi-bin/addClass.pl');
    print "<table border=1>\n";
    print Tr ( th ('Class Name'), th ('Department'),th('Class #'), th('Grade'), th('Credits'));
    print Tr ( td (textfield(-name=>'classname',-method=>'GET',-maxlength=>100)),
               td (textfield(-maxlength=>5,-name=>'department', -method=> 'GET')),
               td (textfield(-name=>'classnum', -method=> 'GET',-maxlength=>3)),
               td (textfield(-name=>'grade', -method=> 'GET', -maxlength=>1)),
               td (textfield(-name=>'credits', -method=> 'GET',-maxlength=>2)),
               td ("<center>",submit(-name=>'add', -value=>'ADD COURSE'),"</center>"));
    
    print "</table>", br, br;
    print submit(-name=>'home', -value=>'HOME');
    print end_form();
}


   

if(verifyLogin()){
    if ($back ne ''){
        my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
        print redirect('/cgi-bin/mainPage.pl');
        exit;
    }
    print header();
    if ($class ne '' && $department ne '' && $classnumber ne ''&& $mark ne '' && $numcredits ne '' && $add ne ''){
        $result = $sth->execute();
        my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
        if (!$result){
            print header(), start_html("oops");
            print "Record not added, try again", a({-href=>'/cgi-bin/addClass.pl'}, " here"), br;
            print end_html();
        } 
        print "Added Record";             
    }
    if (($add ne '')&& ($class eq '' || $department eq '' || $classnumber eq ''|| $mark eq '' || $numcredits eq ''))  {
        my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
        print "You did not fill all fields, try again ", br;
    }
    print start_html(-title=>'Add Class', -BGCOLOR=>'DDDDDD');
    print"<h1>ADD CLASS</h1>";
    buttons();
    print end_html();
}
if(!verifyLogin()){
    print header(), start_html("oops");
   print "You don't have permission to access this page. Try logging in again ", a({-href=>'/cgi-bin/mainLogin.pl'}, " here"), br;
}
$dbh->disconnect();
