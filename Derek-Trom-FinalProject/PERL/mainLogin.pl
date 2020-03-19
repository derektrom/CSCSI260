#!/usr/bin/perl

use CGI qw(:standard);
use CGI::Session;
use File::Spec;
use strict;
my $homeBtn = param('home');
if ($homeBtn ne ''){
    print redirect("/cgi-bin/mainPage.pl");
    exit;
}
print header(), start_html(-title=>'LOGIN PAGE', -BGCOLOR=>'DDDDDD');

print start_form(-action=> "/cgi-bin/checkLogin.pl",-method=>'POST');

print "<center>Enter login</center>", br, br;

print "<center>Username ", textfield(-name=>'txtUsername', method=>"POST"),"</center>", br, br;
print "<center>Password ", password_field(-name=>'txtPassword', , method=>"POST"),"</center>", br, br;
print "<center>",submit(-name=>'btnLogin', -value=>'Login'),"</center>";
print end_form();
print start_form(-action=> "/cgi-bin/mainPage.pl");
print br, br, "<center>",submit(-name=>'home', -value=>'BACK TO MAIN'), "</center>";

print end_form(), end_html();
