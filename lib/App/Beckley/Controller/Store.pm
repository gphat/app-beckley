package App::Beckley::Controller::Store;

use strict;
use warnings;

=head1 NAME

App::Beckley::Controller::Store - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use base 'Catalyst::Controller';

use CGI;
use Data::UUID;
use File::DigestStore;
use File::Temp;
use File::Type;
use LWP::UserAgent;
use MIME::Types;

=head1 METHODS

=cut


=head2 index 

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched App::Beckley::Controller::Store in Store.');
}

sub upload : Chained('/') PathPart('store/upload') Args(0) {
    my ($self, $c) = @_;

    my $key = $c->req->params->{key};

    $c->log->debug("Going to store key: $key");

    if(!defined($c->req->uploads->{'asset'})) {
        $c->log->warn('Nothing uploaded.');
        return;
    }
    my $upload = $c->req->uploads->{'asset'};

    my $store = File::DigestStore->new(root => $c->config->{'store'});
    my $id    = $store->store_file($upload->tempname);
    my $mime  = $upload->type;

	$mime = 'image/png' if $mime eq 'image/x-png';

	$c->log->debug("Stored $mime file of ".$upload->size." bytes as $id.");

    my $ug = Data::UUID->new;
    my $uuid = $ug->create_str;

    my $asset = $c->model('Write::Asset')->create({
        asset_id    => $uuid,
        key         => $key,
        path        => $id,
        mime_type   => $mime,
        source      => 'upload: '.$upload->filename,
        active      => 1,
    });

    if($c->req->params->{sendto}) {
        $c->res->redirect($c->req->params->{sendto}."?uuid=$uuid", 303);
        $c->detach;
    }

    $c->response->body($uuid);
}

sub url : Chained('/') PathPart('store/url') Args(1) {
    my ($self, $c, $key) = @_;

    $c->log->debug("Going to store key: $key");

    my $url = $c->req->params->{'url'};

    $url = CGI::unescape($url);

    if($key && $url) {
        $c->log->debug("Fetching $url") if $c->debug;

        my $useragent = LWP::UserAgent->new;
        my $response = $useragent->get($url);
		if ($response->is_success) {
			my $len		= $response->content_length;
			my $store	= File::DigestStore->new(root => $c->config->{'store'});
			my $id		= $store->store_string($response->content);
			my $ft		= File::Type->new;
			my $mime	= $ft->checktype_filename($store->fetch_file($id));

			$mime = 'image/png' if $mime eq 'image/x-png';

			$c->log->debug("Stored $mime file of $len bytes as $id.");

            my $ug = Data::UUID->new;
            my $uuid = $ug->create_str;

            my $asset = $c->model('Write::Asset')->create({
                asset_id    => $uuid,
                key         => $key,
                path        => $id,
                mime_type   => $mime,
                source      => $url,
                active      => 1,
            });

            $c->response->body($uuid);

        } else {
            die('Failed to fetch content: '.$response->message);
        }
        # $content = $response->content();
    }
}


=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
