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


my $loggedIn = 0;  
my $sessionID = cookie('cs260');
my $session = new CGI::Session (undef, $sessionID, {Directory=>File::Spec->tmpdir()});
   
sub loggedInBtns{
    print Tr(td(submit(-name=>'add', -value=>'ADD CLASS')), td(submit(-name=>'home1', -value=>'HOME')));
} 
sub loggedOutBtns{
    print Tr(td(submit(-name=>'home2', -value=>'HOME')), td(submit(-name=>'login', -value=>'LOGIN'))) ;
} 
sub verifyLogin{
    
    if ($session->param('loggedIn')){
        $loggedIn = 1;
        my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
    }
}
sub table{
    my $hashRef;
    my $search = param('search');
    my $GPA = 0 ;
    my $creditsAttempted = 0;
    my $creditsPassed = 0;
    my $honorPoints = 0;
    my $satisfactoryCredits = 0;
    my $whereSQL = "WHERE ((classname LIKE '%$search%') OR (department LIKE '%$search%'))";
    my $sql = "SELECT classID, classname, department, classnum, grade, credits FROM tblclasses $whereSQL ORDER BY classname";
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    
    print "<table border=4>\n";
    print Tr (th ('Class Name'), th ('Department'), th ('Class #'),th ('Grade'),th ('Credits'), $loggedIn ? th("Edit") : "");

    while ($hashRef = $sth->fetchrow_hashref) {
        my $classID = $hashRef->{'classID'};
        my $className = $hashRef->{'classname'};
        my $department = $hashRef->{'department'};
        my $classNum = $hashRef->{'classnum'};
        my $grade = $hashRef->{'grade'};
        my $credits = $hashRef->{'credits'};
        print Tr ( td ($className), 
                   td($department), 
                   td($classNum),
                   td($grade),
                   td($credits),
                   $loggedIn ? td(a({-href=>"/cgi-bin/editClass.pl?id=$classID"}, "Edit")) : "");
        $creditsAttempted += $credits;
        if (($grade ne 'U') && ($grade ne 'F')){
            $creditsPassed = $creditsPassed + $credits;
        }
        if ($grade eq 'S'){
            $satisfactoryCredits += $credits;
        }
        if($grade eq 'A'){
            $honorPoints += 4*$credits;
            
        }
        if($grade eq 'B'){
            $honorPoints += 3*$credits;
            
        }
        if($grade eq 'C'){
            $honorPoints += 2*$credits;
           
        }
        if($grade eq 'D'){
            $honorPoints += 2*$credits;
           
        }
    }
    print"</table>", br, br;
    my $gpaCredits = $creditsPassed - $satisfactoryCredits;
    $GPA = ($honorPoints/$gpaCredits);
    my $result = sprintf("%.3f", $GPA);
    print "<table border=1>\n";
    print Tr(td('Attempted Credits'), td($creditsAttempted));
    print Tr(td('Passed Credits'), td($creditsPassed));
    print Tr(td('Honor Points'), td($honorPoints));
    print Tr(td('Grade Point Average'), td($result));
    print "</table>";
    $dbh->disconnect();   
    
} 

my $loginBtn = param('login');
my $backBtn1 = param('home1');
my $backBtn2 = param('home2');
my $searchBtn = param('searchBtn');
my $addBtn = param('add');
my $user = $session->param('username');

if ($addBtn ne ''){
    my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
    print redirect('/cgi-bin/addClass.pl');
    exit;
}
if ($searchBtn ne ''){
    my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
}
if ($backBtn1 ne ''){
    my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
    print redirect('/cgi-bin/mainPage.pl');
    exit;
}
if ($backBtn2 ne ''){
    print redirect('/cgi-bin/mainPage.pl');
    exit;
}
if ($loginBtn ne ''){
    print redirect('/cgi-bin/mainLogin.pl');
    exit;
}

print header(), start_html(-title=>'Show Classes', -BGCOLOR=>'DDDDDD');
if (verifyLogin()){
    print"<center><h1>SHOW CLASSES/EDIT CLASSES</h1></center>";
    print "<h2>$user\'s Transcript</h2>";
}
else{
    print"<center><h1>SHOW CLASSES</h1></center>";
    print "<h2>Class List</h2>"
}

print start_form(-action=>'/cgi-bin/showClass.pl');

print textfield(-name=>'search',-method=>'GET',-maxlength=>100), br, br;
print submit(-name=>'searchBtn', -value=>'SEARCH'), br,br;        
 
     
if ($loggedIn){
    table();
    loggedInBtns();
    }
else{
    table();
    loggedOutBtns();
}
print end_form(); 
print end_html();


