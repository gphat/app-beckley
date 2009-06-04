package App::Beckley::Client;
use strict;

use DateTime::Format::HTTP;
use File::Type;
use HTTP::Request::Common;
use LWP::UserAgent;

=head1 NAME

App::Beckley::Client

=head1 DESCRIPTION

Quick client API for Beckley.

=head1 SYNOPSIS

my $beck = App::Beckley::Client->new($beckley_url);
my $retval = $bek->store_url($key, $url);
if($retval) {
    say "Yay!";
} else {
    say $beck->error();
}

=head1 METHODS

=over 4

=item new

Makes a new App::Beckley::Client object.

=cut
sub new {
    my $proto = shift();
    my $class = ref($proto) || $proto;
    my $self = {};

    $self->{BECKURL} = shift or die('Please supply the base URL to Beckley');

    bless($self, $class);
    return $self;
}

=item get_last_modified($key)

=cut

sub get_last_modified {
    my ($self, $key) = @_;

    my $ua = LWP::UserAgent->new;

    my $resp = $ua->request(GET $self->{BECKURL}."/fetch/key/$key/head");
    unless($resp->is_success) {
        $self->error($resp->status_line);
        return undef;
    }

    return DateTime::Format::HTTP->parse_datetime(
        $resp->header('Last-Modified')
    );
}

=item store_upload

Stores a file in the remote Beckley instance via uploading.  Works for
local files.

=cut

sub store_upload {
    my ($self, $key, $filename) = @_;

    # Clear the error.
    $self->error(undef);

    unless(-e $filename) {
        $self->error("Unable to read file: $filename");
        return 0;
    }

    my $ft  = File::Type->new;
    my $mime= $ft->checktype_filename($filename);

    eval {
        my $ua = LWP::UserAgent->new;

        my $resp = $ua->request(POST $self->{BECKURL}."/store/upload",
            Content_type => 'form-data',
            Content => [
                key => $key,
                asset => [ $filename, undef, 'Content-Type' => $mime ]
            ]
        );

        unless($resp->is_success) {
            print $resp->status_line."\n";
            $self->error($resp->status_line);
            return 0;
        }
    };

    if($@) {
        $self->error($@);
        return 0;
    }

    return 1;
}

=item store_url

Store the file at a url with the specified key.  Returns a true value if
successful.  Otherwise returns a false value.

=cut

sub store_url {
    my ($self, $key, $url) = @_;

    # Clear the error.
    $self->error(undef);

    my $ua = LWP::UserAgent->new();

    if(defined($key) && defined($url)) {
        my $resp = $ua->post($self->{BECKURL}."/store/url/$key", [
        	url => $url
        ]);

        if($resp->is_success()) {
            return 1;
        } else {
            $self->error($resp->status_line);
            return 0;
        }

    } else {
        $self->error('Must supply a key and url');
    }

    return 0;
}

=item error

Set/Get the error on this object.

=cut

sub error {
    my $self = shift();

    if(@_) { $self->{ERROR} = shift() };
    return $self->{ERROR};
}

=back

=head1 AUTHOR

 Cory Watson <cwatson@magazines.com>

=head1 LICENSE

 For Internal Use Only

 (c) 2008 Magazines.com, Inc.  All Rights Reserved.

=cut

1;
