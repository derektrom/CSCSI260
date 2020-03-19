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
my $sessionID = cookie('cs260');
my $session = new CGI::Session (undef, $sessionID, {Directory=>File::Spec->tmpdir()});

my $homeBtn = param('home');
my $backBtn = param('back'); 
my $editBtn = param('edit');
my $class = param('classname');
my $department = param('department');
my $classnumber = param ('classnum');
my $mark = param('grade');
my $numcredits = param('credits');
my $classToEdit = param('id');
my $classID;
my $cookie2 = cookie(-name=>'classID', -value=> param('id'), -expires=>'+60s');



sub verifyLogin{
    
    if ($session->param('loggedIn')){
    
        my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
    }
}
sub editCourse{
    my $cookieClass = cookie('classID');
    my $newName = shift;
    my $newDPT = shift;
    my $newNum = shift;
    my $newGrade = shift;
    my $newCred = shift;
    my $sql = "UPDATE tblclasses SET classname = '$newName', department = '$newDPT', classnum = '$newNum', grade = '$newGrade', credits = '$newCred' WHERE classID = $cookieClass";
    my $sth = $dbh->prepare($sql);
    my $result = $sth->execute();
    my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s'); 
    if ($result){
        print "<h2>Updated  Transcript</h2>", br;
        
    }
    else{
        print "Could not update", br, br;
    } 
     
}
sub fillClass{
    my $hashRef;
    
    my $whereSQL = "WHERE classID = '$classToEdit'";
    my $sql = "SELECT classname, department, classnum, grade, credits FROM tblclasses $whereSQL";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    print start_form(); 
    print "<table border=1>\n";
    print Tr (th ('Class Name'), th ('Department'), th ('Class #'),th ('Grade'),th ('Credits'));
    
    while ($hashRef = $sth->fetchrow_hashref) {
        my $classID = $hashRef->{'classID'};
        my $cookie2 = cookie(-name=>'classID', -value=> $classID, -expires=>'+15s');
        my $className = $hashRef->{'classname'};
        my $department = $hashRef->{'department'};
        my $classNum = $hashRef->{'classnum'};
        my $grade = $hashRef->{'grade'};
        my $credits = $hashRef->{'credits'};
        print Tr ( td (textfield(-name=>'classname',-method=>'GET',-maxlength=>100, -default => $className)),
               td (textfield(-maxlength=>5,-name=>'department', -method=> 'GET',-default =>$department )),
               td (textfield(-name=>'classnum', -method=> 'GET',-maxlength=>5, -default => $classNum)),
               td (textfield(-name=>'grade', -method=> 'GET', -maxlength=>1, -default => $grade)),
               td (textfield(-name=>'credits', -method=> 'GET',-maxlength=>2, -default=>$credits)));
    
    }
    print"<table/>";
    
    print end_form();
    print start_form();
    print Tr( td(submit(-name=>'home', -value=>'HOME')), td(submit(-name=>'back', -value=>'BACK TO TRANSCRIPT')));
    
    print end_form();
    
}
if($homeBtn ne ''){
    print redirect('/cgi-bin/mainPage.pl');
    exit;
}
if ($backBtn ne ''){
    print redirect('/cgi-bin/showClass.pl');
    exit; 
}



if (verifyLogin()){
    print header(-cookie =>$cookie2);
    print start_html(-title=> 'Edit Class', -BGCOLOR=>'DDDDDD');
    print start_form(-action=>"/cgi-bin/editClass.pl?id=$classToEdit");
    fillClass();
    
    if ($editBtn ne ''){
        if ($class ne '' && $department ne '' && $classnumber ne ''&& $mark ne '' && $numcredits ne ''){
            editCourse($class, $department, $classnumber, $mark, $numcredits);
        
        }
    }
    if ($editBtn ne '' && ($class eq '' || $department eq '' || $classnumber eq ''|| $mark eq '' || $numcredits eq ''))  {
        my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
        print "You did not fill all fields, or no record to update", br;
    }
    print submit(-name=>'edit', -value=>'UPDATE RECORD');
    print end_form();
    print end_html();
    
    
}
if (!verifyLogin()){
    print header(), start_html("oops");
    print "You don't have permission to access this page. Try logging in again ", a({-href=>'/cgi-bin/mainLogin.pl'}, " here"), br;
}

