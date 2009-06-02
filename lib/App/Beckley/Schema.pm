package App::Beckley::Schema;
use strict;

use base qw(DBIx::Class::Schema);

my @classes = qw(
    Asset
);

__PACKAGE__->load_classes({ 'App::Beckley::Schema' => \@classes });

1;