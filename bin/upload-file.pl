#!/usr/bin/perl
use strict;

use App::Beckley::Client;

my $beckurl = shift || usage();
my $key = shift || usage();
my $file = shift || usage();

my $becks = App::Beckley::Client->new($beckurl);

my $ret = $becks->store_upload($key, $file);
if($ret) {
    print "Success\n";
} else {
    print "Failed: ".$becks->error."\n";
}

sub usage {
    die("Usage: upload-file.pl <beckley-url> <key> <local filename>\n");
}
