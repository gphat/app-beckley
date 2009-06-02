package App::Beckley::Controller::Text::Filter;

use strict;
use warnings;

=head1 NAME

App::Beckley::Controller::Filter - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use base 'Catalyst::Controller';

use CSS::Minifier::XS qw(minify);

=head1 METHODS

=cut


=head2 index 

=cut

sub css_compress : Private {
    my ($self, $c, $args) = @_;

    $c->stash->{context}->{text} = minify($c->stash->{context}->{text});
}


=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
