#!/usr/bin/perl
use strict;

use App::Beckley::Client;

my $beckurl = shift || usage();
my $key = shift || usage();
my $url = shift || usage();

my $becks = App::Beckley::Client->new($beckurl);

my $ret = $becks->store_url($key, $url);
if($ret) {
    print "Success\n";
} else {
    print "Failed: ".$becks->error."\n";
}

sub usage {
    die("Usage: store-url.pl <beckley-url> <key> <remote-url-to-fetch>\n");
}