#!/usr/bin/perl

BEGIN {
  push(@INC, "modules");
}

use DBI;
use Data::Dumper;

use SL::LXDebug;

use SL::Form;
use SL::Template;

$userspath  = "users";
$templates  = "templates";
$memberfile = "users/members";
$sendmail   = "| /usr/sbin/sendmail -t";

$| = 1;

$lxdebug = LXDebug->new();

require "lx-erp.conf";

$form = new Form;
$form->{"script"} = "oe.pl";
$form->{"path"} = "bin/mozilla";


$ENV{'HOME'} = getcwd() . "/$userspath";

my $template = OpenDocumentTemplate->new("", $form, \%myconfig, $userspath);

if (@ARGV && ($ARGV[0] eq "-r")) {
  system("ps auxww | " .
         "grep -v awk | " .
         "awk '/^www-data.*(soffice|Xvfb)/ { print \$2 }' | " .
         "xargs -r kill");
  sleep(10);
}

exit(1) unless ($template->spawn_xvfb());
exit(2) unless ($template->spawn_openoffice());
exit(0);
