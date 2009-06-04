package App::Beckley::Controller::Image::Transform;
use strict;
use warnings;

=head1 NAME

App::Beckley::Controller::Transform - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use base 'Catalyst::Controller';

use Imager;

=head1 METHODS


=head2 flip

Flip an image.  Takes an argument of 'v' for a vertical flip or 'h' for
horizontal.  You can also combine the two (e.g. hv or vh).

=cut

sub flip : Private {
    my ($self, $c, $name, $args) = @_;

    $c->forward('/image/default', [ $name ]);

    $c->stash->{assets}->{$name}->{image}->flip(dir => $args);
}

=head2 rotate

Rotate an image.  Arguments should be one of:

  d{0-9\.}* (e.g. d90)

  Rotate an image in degrees.
  
  r{0-9\.}* (e.g. r0.78539)
  
  Rotate an image in radians.
  
=cut

sub rotate : Private {
    my ($self, $c, $name, $args) = @_;

    $c->forward('/image/default', [ $name ]);

    if($args =~ /^r([0-9\.]+)/) {
        $c->stash->{assets}->{$name}->{image}
            = $c->stash->{assets}->{$name}->{image}->rotate(radians => $1);
    } elsif($args =~ /^d([0-9\.]+)/) {
        $c->stash->{assets}->{$name}->{image}
            = $c->stash->{assets}->{$name}->{image}->rotate(degrees => $1);
    }
}

=head2 overlay

Overlays an image over the current on.  Accepts arguments in the following
form:

over 4

=item name,x,y

Follows the same rules as the above, but allows an x,y coordinate at
which to position the overlay.  Defaults to 0,0.  If you the supplied
coordinates are B<negative> they will be substracted from the destination
image's width and or height to work from the opposite edge.  For example if
the arguments are -16,-16 then the overlay will be positioned at width - 16,
height - 16 (effectively working from the bottom left corner).

=back

=cut

sub overlay : Private {
    my ($self, $c, $name, $args) = @_;

    $c->forward('/image/default', [ $name ]);

    my @parts = split(/,/, $args);

    if($parts[1]) {
        if($parts[1] < 0) {
            $parts[1] = $c->stash->{assets}->{$name}->{image}->getwidth - abs($parts[1]);
        }
    } else {
        $parts[1] = 0;
    }

    if($parts[2]) {
        if($parts[2] < 0) {
            $parts[2] = $c->stash->{assets}->{$name}->{image}->getheight - abs($parts[2]);
        }
    } else {
        $parts[2] = 0;
    }

    $c->log->error($parts[0]);
    $c->forward('/image/default', [ $parts[0] ]);

    $c->stash->{assets}->{$name}->{image}->rubthrough(
        src => $c->stash->{assets}->{$parts[0]}->{image},
        tx => $parts[1],
        ty => $parts[2]
    );
}

=head2 scale

Scales the image.  Accepts arguments in the following form:

\d+x\d+ (e.g. 800x600)

Scale an image so proportions are maintained.  The X or Y number that creates
the largest image will be chosen.  This is very useful, but might not do
what you expect.

w\d+ (e.g. w800)

Scales an image to the specified width, maintaining it's proportions.

h\d+ (e.g. h600)

Scales an image to the specified height, maintaining it's proportions.

=cut

sub scale : Private {
    my ($self, $c, $name, $args) = @_;

    $c->forward('/image/default', $name);

    if($args =~ /^(\d+)x(\d+)$/) {
        $c->stash->{assets}->{$name}->{image}
            = $c->stash->{assets}->{$name}->{image}->scale(
                xpixels => $1, ypixels => $2, qtype => 'mixing'
            );
    } elsif($args =~ /^w(\d+)$/) {
        $c->stash->{assets}->{$name}->{image}
            = $c->stash->{assets}->{$name}->{image}->scale(
                xpixels => $1, qtype => 'mixing'
            );
    } elsif($args =~ /^h(\d+)$/) {
        $c->stash->{assets}->{$name}->{image}
            = $c->stash->{assets}->{$name}->{image}->scale(
                ypixels => $1, qtype => 'mixing'
            );
    }
}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
