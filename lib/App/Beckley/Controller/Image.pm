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
    my ($self, $c, $name, $ass) = @_;

    return if defined($c->stash->{assets}->{$name}->{image});

    my $asset = $c->stash->{assets}->{$name}->{asset};
    $c->response->headers->last_modified($asset->date_created->epoch);

    my $mime = $asset->mime_type;
    my $type;
    if($mime =~ /image\/(\w+)/) {
        $type = $1;
    }

    my $img = Imager->new;
    if(defined($type)) {
        $img->read(
            file => $c->stash->{assets}->{$name}->{path},
            type => $type
        ) or $c->detach('error', [ $img->errstr ]);
    } else {
        $img->read(file => $c->stash->{assets}->{$name}->{path})
            or $c->detach('error', [ $img->errstr ]);
    }
    $c->stash->{assets}->{$name}->{image} = $img;
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
