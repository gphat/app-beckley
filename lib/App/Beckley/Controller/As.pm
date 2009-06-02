package App::Beckley::Controller::As;

use strict;
use warnings;

=head1 NAME

App::Beckley::Controller::As - Catalyst Controller

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

sub image : Private {
    my ($self, $c, $type) = @_;

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
    $c->stash->{context}->{image}->write(data => \$data, type => $type);

    my $ct = $c->config->{cache_time} || 10800;
    $c->response->headers->expires($ct + time);

    $c->response->content_length(length($data));
    $c->response->headers->content_type("image/$type");
    $c->response->body($data);
}

=head2 text

Show the asset as an image

=cut

sub text : Private {
    my ($self, $c, $type) = @_;

    my $text = $c->stash->{context}->{text};
    $c->response->content_length(length($text));

    print STDERR "TEXT: $text\n";

    $c->response->body($text);
}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
