#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Session;
use File::Spec;
use strict;

my $sessionID = cookie('cs260');
my $session = new CGI::Session (undef, $sessionID, {Directory=>File::Spec->tmpdir()});
if ($session->param('loggedIn')){
   my $cookie = cookie (-name=>'cs260', -value=> $session->id, -expires=>'+60s');
   print header(-cookie=>$cookie), start_html("Logged in");
   print "Server says you are logged in", br;
   print start_html(-head=>meta({http_equiv=>'Refresh', -content=>'2;URL=/cgi-bin/mainPage.pl'}));
   print "If you are not redirected in 10 seconds click ",  a({-href=>'/cgi-bin/mainPage.pl'},"here"), br;
   print end_html();
}
else{
   print header(), start_html("oops");
   print "You don't have permission to access this page. Try logging in again ", a({-href=>'/cgi-bin/getLoginInfo.pl'}, " here"), br;
}
