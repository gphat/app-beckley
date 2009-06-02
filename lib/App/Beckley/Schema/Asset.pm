package App::Beckley::Schema::Asset;
use strict;

=head1 NAME

App::Beckley::Schema::Asset

=head1 DESCRIPTION

Assets are artifacts managed by Beckley, such as images or text files.

=head1 DATABASE

See the 'assets' table for all the methods.

=cut

use parent 'DBIx::Class';

__PACKAGE__->load_components(qw(TimeStamp Core));
__PACKAGE__->table('assets');
__PACKAGE__->add_columns(
    asset_id => {
        data_type => 'VARCHAR',
        size => 36,
        is_nullable => 0,
    },
    key => {
        data_type   => 'VARCHAR',
        size        => 64,
        is_nullable => 0
    },
    name => {
        data_type   => 'VARCHAR',
        size        => 255,
        is_nullable => 0
    },
    path => {
        data_type   => 'TEXT',
        is_nullable => 0
    },
    mime_type => {
        data_type   => 'VARCHAR',
        size        => 128,
        is_nullable => 0
    },
    source => {
        data_type => 'TEXT',
        is_nullable => 1,
    },
    active => {
        data_type   => 'TINYINT',
        size        => 1,
        is_nullable => 0
    },
    date_created => {
        data_type => 'DATETIME',
        is_nullable => 0,
        set_on_create => 1,
        timezone => 'America/Chicago'
    },
);
__PACKAGE__->set_primary_key('asset_id');

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->add_index(name => 'idx_key_date', fields => [ qw(key date_created )]);
}

=head1 METHODS

=over 4

=item date_created

Date this Asset was created

=cut
1;
