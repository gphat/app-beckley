package App::Beckley::Controller::Text;

use strict;
use warnings;

=head1 NAME

App::Beckley::Controller::Text - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use base 'Catalyst::Controller';

use IO::File;
use Imager;

=head1 METHODS

=head2 default

Sets up this asset for CSS processing

=cut

sub default : Private {
    my ($self, $c) = @_;

    my $fh = IO::File->new($c->stash->{context}->{path}, 'r');
    while(<$fh>) {
        $c->stash->{context}->{text} .= $_;
    }
    $fh->close;

    $c->stash->{as} = {
        action => 'text'
    };
}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
