#!/usr/bin/perl
use strict;

use App::Beckley::Client;

my $beckurl = shift || usage();
my $key = shift || usage();

my $becks = App::Beckley::Client->new($beckurl);

my $ret = $becks->get_last_modified($key);
if($ret) {
    print $ret->epoch."\n";
} else {
    print "Failed: ".$becks->error."\n";
}

sub usage {
    die("Usage: get-last-modified.pl <beckley-url> <key>\n");
}