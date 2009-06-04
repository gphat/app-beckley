package App::Beckley::Controller::Image::Show;

use strict;
use warnings;

=head1 NAME

App::Beckley::Controller::Image::Show - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use base 'Catalyst::Controller';

use Imager;

=head1 METHODS

=cut


=head2 image

Show the asset as an image

=cut

sub as : Private {
    my ($self, $c, $name, $type) = @_;

    $c->forward('/image/default', $name);

    # Handle mime-type style images
    if($type =~ /^image\/(.*)/) {
        $type = $1;
    }

    my @types = Imager->write_types;
    unless(grep( $_ eq $type,  @types)) {
        $c->log->error("Unwritable type $type");
        $c->detach('/default');
    }

    my $data;
    $c->stash->{assets}->{$name}->{image}->write(data => \$data, type => $type);

    my $ct = $c->config->{cache_time} || 10800;
    $c->response->headers->expires($ct + time);

    $c->response->content_length(length($data));
    $c->response->headers->content_type("image/$type");
    $c->response->body($data);
}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
