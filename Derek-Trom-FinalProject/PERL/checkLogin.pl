#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Session;
use File::Spec;
use DBI;
use strict;
my $dataSource = "DBI:mysql:f19final:localhost";
my $dbh = DBI->connect ($dataSource, "root", "pass260word");
my $username = param('txtUsername');
my $password = param('txtPassword');
my $authenticated = 'no';
sub authenticate{
    my $hashref;
    my $sql = "SELECT userID FROM tblusers WHERE login = '$username' AND password = '$password'";
    my $sth = $dbh->prepare($sql);
    my $result = $sth->execute();
    while ($hashref = $sth->fetchrow_hashref){
        $authenticated = 'yes';
    }
}


authenticate();

if ($authenticated eq 'yes'){
   #1st arg -dsn info - leave blank
   #2 arg -session id- set to undef to create a new session
   #3rd arg - where should the cookie be stored on the server
   my $session = new CGI::Session (undef, undef, {Directory=>File::Spec->tmpdir()});
   $session->param('loggedIn', 'yes');
   $session->param('username', $username);
   $session->close();
   my $cookie = cookie(-name=>'cs260', -value=> $session->id, -expires=>'+60s');
   print redirect(-cookie=>$cookie, -location=>'/cgi-bin/verifyLogin.pl'), start_html("Logged In");
   print end_html();
   
}
else
{
   print header(), start_html(-title=>'Invalid Login');
   print "<h3>Invalid Combination, try logging in again<a href='/cgi-bin/mainLogin.pl'> here </a></h3>";
   print end_html();

}
