package App::Beckley::Controller::Load;

use strict;
use warnings;

=head1 NAME

App::Beckley::Controller::Load - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use base 'Catalyst::Controller';

use File::stat;
use IO::File;

=head1 METHODS

=head2 uuid

Start point for uuid based asset fetch

=cut

sub uuid : Private {
    my ($self, $c, $name, $uuid) = @_;

    $c->stash->{assets}->{$name}->{asset} = $c->model('Read::Asset')->find($uuid);

    $c->forward('post_load');
}

=head2 key

Start point for key based asset fetch

=cut

sub key : Private {
    my ($self, $c, $name, $key) = @_;

    my $asset = $c->model('Read::Asset')->search(
        { key => $key },
        {
            order_by => \'date_created DESC',
            rows => 1,
            page => $c->req->params->{'offset'} || 0
        }
    )->single;

    unless(defined($asset)) {
        # Try and use a fallback
        if(exists($c->config->{fallback})
            && exists($c->config->{fallback}->{key})) {

            foreach my $fallback (@{ $c->config->{fallback}->{key}}) {
                $c->log->debug('Trying fallback.');
                if($key =~ $fallback->{regex}) {
                    $c->log->debug('Found fallback '.$fallback->{key});

                    $asset = $c->model('Read::Asset')->search(
                        { key => $fallback->{key} },
                        {
                            order_by => \'date_created DESC',
                            rows => 1,
                            page => $c->req->params->{'offset'} || 0
                        }
                    )->single;
                }
            }
        }
    }

    $c->stash->{assets}->{$name}->{asset} = $asset;

    $c->forward('post_load');
}

sub post_load : Private {
    my ($self, $c, $name) = @_;

    my $asset = $c->stash->{assets}->{$name}->{asset};
    unless(defined($asset)) {
        $c->detach('not_found');
    }

    # Set this now.  It can be changed later.
    $c->res->headers->content_type($asset->mime_type);

    $c->response->headers->last_modified($asset->date_created->epoch);

    my $store = File::DigestStore->new(root => $c->config->{store});
    $c->log->debug('Retrieving file '.$asset->path) if $c->debug;
    my $file = $store->fetch_file($asset->path);
    $c->log->debug("Retrieving file $file") if $c->debug;

    $c->stash->{assets}->{$name}->{'path'} = $file;
}

sub not_found : Private {
    my ($self, $c) = @_;

    $c->response->body('Asset not found');
    $c->response->status(404);
}


=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
