#!/usr/bin/perl
#

BEGIN {
  push(@INC, "modules");
}

use SL::LXDebug;
$lxdebug = LXDebug->new();

use SL::Form;
use SL::Locale;

eval { require "lx-erp.conf"; };

$form = new Form;

eval { require("$userspath/$form->{login}.conf"); };

$locale = new Locale "$myconfig{countrycode}", "kopf";

eval { require "bin/mozilla/kopf.pl"; };
