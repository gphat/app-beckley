package App::Beckley::Controller::Image::Filter;

use strict;
use warnings;

=head1 NAME

App::Beckley::Controller::Filter - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use base 'Catalyst::Controller';

=head1 METHODS

=cut


=head2 index 

=cut

sub gaussian : Private {
    my ($self, $c, $args) = @_;

    $args ||= 1;

    $c->log->debug('Calling guassian filter with stddev of '.$args);
    $c->stash->{context}->{image}->filter(
        type => 'gaussian', stddev => $args
    );
}

=head2 grayscale

=cut

sub grayscale : Private
{
	my $self	= shift;
	my $c		= shift;

	my $img		= $c->stash->{context}->{image};
	my $gray	= $img->convert(preset => 'grey');
	my $width	= $img->getwidth;
	my $height	= $img->getheight;
	my $mask	= new Imager xsize => $width, ysize => $height, channels => 1;
	my @args	= split ',', shift;

	# create a normalized rectangle "object" by pulling
	# comma-delimited values out of the argument list.  all
	# values are optional.  an incomplete definition of the
	# rectangle will cause the rectangle to extend from its
	# defined dimensions to the lower right extremes of the
	# image.
	#
	# for example:
	#
	#   - if no dimensions are supplied, the entire image
	#     will be converted to grayscale.
	#   - if only the top of the rectangle is defined, the
	#     entire bottom is converted to grayscale.
	#   - if only the top and left of the rectangle are
	#     defined, then the entire bottom right half of the
	#     image if converted to grayscale.
	#   - if only the top, left, and width of the rectangle
	#     are defined, then the rectangle extending from
	#     there to the bottom of the image is converted to
	#     grayscale.

	my $rect =
	{
		top		=> shift(@args) || 0,
		left	=> shift(@args) || 0,
		width	=> shift(@args) || $width,
		height	=> shift(@args) || $height
	};

	# fill in our rectangle on this single eight bit channel
	# with the maximum pixel value (255).  we will use this
	# image as the mask for the drawing operation.

	$mask->box
	(
		xmin	=> $rect->{left},
		ymin	=> $rect->{top},
		xmax	=> $rect->{left} + $rect->{width},
		ymax	=> $rect->{top} + $rect->{height},
		filled	=> 1,
		color	=> new Imager::Color c0 => 255
	);

	# compose the grayscale image onto our source image with
	# the image mask we created above.  we use the 'none'
	# combine operation so that pixels are replaced outright
	# rather than alpha blended.  our mask doesn't have an
	# alpha channel, but i'd rather be explicit in what we
	# ask for here.

	$img->compose(src => $gray, mask => $mask, combine => 'none');
}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
