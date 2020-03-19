#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Session;
use File::Spec;
use strict;
my $username = param('txtUsername');
my $addClass = param('addBtn');
my $editClass = param('editBtn');
my $transcript = param('transBtn');
my $login = param('login');
my $sessionID = cookie('cs260');
my $session = new CGI::Session (undef, $sessionID, {Directory=>File::Spec->tmpdir()});
sub verifyLogin{
    
    if ($session->param('loggedIn')){
    
        my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
    }
}
sub loggedInButtons{
    print "<center>",submit(-name=>'transBtn', -value=>'SHOW TRANSCRIPT/EDIT CLASS'), "</center>";
    print br, br, "\n";    
    
    print "<center>",submit(-name=>'addBtn', -value=>'ADD CLASS'), "</center>";
    print br, br, "\n"
}
sub loggedOutBtns{
    print "<center>",submit(-name=>'login', -value=>'LOG IN'), "</center>";
    print br, br, "\n";
    
    print "<center>",submit(-name=>'transBtn', -value=>'SHOW TRANSCRIPT'), "</center>";
    print br, br, "\n";  
    
}

if ($addClass ne ''){
        my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+90s');
        print redirect ("/cgi-bin/addClass.pl");
        exit;
    }

if ($transcript ne ''){
        my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
        print redirect ("/cgi-bin/showClass.pl");
        exit;
    }
if (!verifyLogin() && $login ne ''){
   print redirect("/cgi-bin/mainLogin.pl");
   exit;
}

print header(), start_html(-title=>'Class Tracker', -BGCOLOR=>'DDDDDD');
print start_form(-action=>'/cgi-bin/mainPage.pl');

if (verifyLogin()){
    print "<center><h1>CLASS RECORDS</h1></center>";
    my $user = $session->param('username');
    print "<h3><center>Hello, $user!</center></h3>", br;
    loggedInButtons();
}
else{
    print "<center><h1>CLASS RECORDS</h1></center>";
    loggedOutBtns();
}

print end_form(), end_html();
