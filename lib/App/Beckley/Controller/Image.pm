package App::Beckley::Controller::Image;

use strict;
use warnings;

=head1 NAME

App::Beckley::Controller::Image - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use base 'Catalyst::Controller';

use Imager;

=head1 METHODS

=head2 default

Sets up this asset for image processing

=cut

sub default : Private {
    my ($self, $c) = @_;

    my $asset = $c->stash->{'context'}->{'asset'};
    $c->response->headers->last_modified($asset->date_created->epoch);

    my $mime = $c->stash->{'context'}->{'asset'}->mime_type;
    my $type;
    if($mime =~ /image\/(\w+)/) {
        $type = $1;
    }

    my $img = Imager->new;
    if(defined($type)) {
        $img->read(
            file => $c->stash->{'context'}->{'path'},
            type => $type
        ) or $c->detach('error', [ $img->errstr ]);
    } else {
        $img->read(file => $c->stash->{'context'}->{'path'})
            or $c->detach('error', [ $img->errstr ]);
    }
    $c->stash->{'context'}->{'image'} = $img;

    if($c->req->params->{'format'}) {
        $c->stash->{'format'} = 'image/'.$c->req->params->{'format'};
    }

    my $itype = $c->stash->{'format'}
        || $c->stash->{context}->{asset}->mime_type;
    $c->stash->{as} = {
        action => 'image',
        arg => $itype
    };
}

sub error : Private {
    my ($self, $c, $error) = @_;

    $c->res->body($error);
    $c->res->status(500);
}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
