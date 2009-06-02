package App::Beckley::Controller::Root;

use strict;
use warnings;

=head1 NAME

App::Beckley::Controller::Root - Root Controller for App::Beckley

=head1 DESCRIPTION

[enter your description here]

=cut

use base 'Catalyst::Controller';

use Imager;

# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
__PACKAGE__->config->{namespace} = '';

=head1 METHODS

=cut

=head2 default

=cut

sub index : Path Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->redirect('http://www.magazines.com');
}

sub default : Path {
    my ( $self, $c ) = @_;
    $c->response->redirect('http://www.magazines.com');
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Cory Watson

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
