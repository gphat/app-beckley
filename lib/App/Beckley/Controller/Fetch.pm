package App::Beckley::Controller::Fetch;

use strict;
use warnings;

=head1 NAME

App::Beckley::Controller::Fetch - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

use base 'Catalyst::Controller';

use File::stat;
use IO::File;
use Data::Dumper;

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

	$c->response->redirect('http://www.magazines.com');
}

sub fetch_root : Chained('/') PathPart('') CaptureArgs(0) {
    my ($self, $c) = @_;

    $c->stash->{processes} = [];
    $c->stash->{names} = [];
    $c->stash->{actions} = [];
    $c->stash->{values} = [];
}

=head2 uuid

Start point for uuid based asset fetch

=cut

sub uuid : Chained('fetch_root') PathPart('fetch/uuid') Args(1) {
    my ($self, $c, $uuid) = @_;

    push(@{ $c->stash->{processes}}, 'load');
    push(@{ $c->stash->{names}}, 'default');
    push(@{ $c->stash->{actions}}, 'uuid');
    push(@{ $c->stash->{values}}, $uuid);

    $c->detach('process');
}

=head2 key

Start point for key based asset fetch

=cut

sub key : Chained('fetch_root') PathPart('fetch/key') Args(1) {
    my ($self, $c, $key) = @_;

    push(@{ $c->stash->{processes}}, 'load');
    push(@{ $c->stash->{names}}, 'default');
    push(@{ $c->stash->{actions}}, 'key');
    push(@{ $c->stash->{values}}, $key);

    $c->detach('process');
}

sub post_fetch : Public {
    my ($self, $c) = @_;

    my $asset = $c->stash->{assets}->{'default'};
    unless(defined($asset)) {
        $c->detach('not_found');
    }

    # Set this now.  It can be changed later.
    $c->res->headers->content_type($asset->mime_type);

    $c->response->headers->last_modified($asset->date_created->epoch);

    my $store = new File::DigestStore(root => $c->config->{'store'});
    $c->log->debug('Retrieving file '.$asset->path) if $c->debug;
    my $file = $store->fetch_file($asset->path);
    $c->log->debug("Retrieving file $file") if $c->debug;

    $c->stash->{'context'}->{'path'} = $file;
}

=head2 head

Doesn't return any content, just the headers.  THis should probably be RESTy

=cut

sub head : Private {
    my ($self, $c) = @_;

    delete($c->stash->{context});
}

=head2 process

Destination method!  This unrolls macros and dispatches to any requested
doodads.  At the end it consults the stash's C<as> key for a hashref. (Named
for the As controller) If it finds one then it will dispatch to C</as/$action>
and pass anything in C<arg>.  So one might set C<as> like this:

  $c->stash->{as} = {
    action => 'image',
    arg => $type
  };

If C<as> is not set then the mime type will be set to the asset's default and
the file will be served unmodified from the filesystem.

=cut
sub process : Chained('/') PathPart('process') Args(0) {
    my ($self, $c, @args) = @_;

    if(scalar(@args)) {
        my $con_name = shift(@args);
        # These are here until I get a better way...
        if($con_name eq 'info') {
            $c->detach('info');
        } elsif($con_name eq 'head') {
            $c->detach('head');
        } else {
            my $action = $c->dispatcher->get_action_by_path("$con_name/default");
            if(defined($action)) {
                $c->forward('/'.$action->reverse, \@args);
            }
        }
    }

    my $asset = $c->stash->{context}->{asset};

    unless(defined($c->stash->{processes})) {
        $c->stash->{processes} = [];
        $c->stash->{names} = [];
        $c->stash->{actions} = [];
        $c->stash->{values} = [];
    }

    if($c->req->params->{macro}) {
        $c->forward('unroll_macro', [ $c->req->params->{macro} ]);
    }

    # Get the process to run
    if(defined($c->req->params->{p})) {
        if(ref($c->req->params->{p}) eq 'ARRAY') {
            push(@{ $c->stash->{processes} }, @{ $c->req->params->{p} });
        } else {
            push(@{ $c->stash->{processes} }, $c->req->params->{p});
        }
    }

    if(defined($c->req->params->{n})) {
        if(ref($c->req->params->{n}) eq 'ARRAY') {
            push(@{ $c->stash->{names} }, @{ $c->req->params->{n} });
        } else {
            push(@{ $c->stash->{names} }, $c->req->params->{n});
        }
    }


    # ...and the actions
    if(defined($c->req->params->{a})) {
        if(ref($c->req->params->{a}) eq 'ARRAY') {
            push(@{ $c->stash->{actions} }, @{ $c->req->params->{a} });
        } else {
            push(@{ $c->stash->{actions} }, $c->req->params->{a});
        }
    }

    # ...and finally the values to give to the actions
    if(defined($c->req->params->{v})) {
        if(ref($c->req->params->{v}) eq 'ARRAY') {
            push(@{ $c->stash->{values} }, @{ $c->req->params->{v} });
        } else {
            push(@{ $c->stash->{values} }, $c->req->params->{v});
        }
    }

    if($c->debug) {
        $c->log->debug('Processes:');
        $c->log->debug(Dumper($c->stash->{processes}));
        $c->log->debug('Names:');
        $c->log->debug(Dumper($c->stash->{names}));
        $c->log->debug('Actions:');
        $c->log->debug(Dumper($c->stash->{actions}));
        $c->log->debug('Values:');
        $c->log->debug(Dumper($c->stash->{values}));
    }

    my $count = 0;

    # Call all the steps, as requested
    foreach my $p (@{ $c->stash->{processes} }) {
        my $con = $c->controller($p);
        if($con && $c->stash->{actions}->[$count]) {
            my $name = $c->stash->{names}->[$count];
            my $act = $con->action_for($c->stash->{actions}->[$count]);
            $c->log->debug('Process: '.$p.' Action: '
                .$c->stash->{actions}->[$count]
                .' Value: '.$c->stash->{values}->[$count]
                ." Name: $name"
            ) if $c->debug;
            if($act) {
                $name ||= 'default';
                $c->forward('/'.$act->reverse,
                    [ $name, $c->stash->{values}->[$count] ]
                );
            } else {
                $c->log->warn("Did not find $p:$a");
            }
        }
        $count++;
    }

    unless($c->response->body) {
        # Or just serve it static!
        my $fh = IO::File->new($c->stash->{assets}->{default}->{path}, 'r');
        binmode($fh);
        $c->res->body($fh);
    }
}

=head2 info

Return the asset's info as JSON

=cut

sub info : Private {
    my ($self, $c) = @_;

    my $context = delete($c->stash->{context});
    $c->stash->{id} = $context->{asset}->id;
    $c->stash->{key} = $context->{asset}->key;
    $c->stash->{name} = $context->{asset}->name;
    $c->stash->{mime_type} = $context->{asset}->mime_type;
    $c->stash->{source} = $context->{asset}->source;
    $c->stash->{active} = $context->{asset}->active;
    $c->stash->{date_created} = $context->{asset}->date_created->iso8601;

    my $assets = $c->model('Read::Asset')->search(
        { key => $context->{asset}->key },
        { order_by => \'date_created DESC', }
    );
    return if($assets->count == 0);
    while(my $asset = $assets->next) {
        push(@{ $c->stash->{versions} }, {
            id => $asset->id,
            date_created => $asset->date_created->iso8601
        });
    }
}

sub unroll_macro : Private {
    my ($self, $c, $macro) = @_;

    unless($c->config->{macros}->{$macro}) {
        $c->log->debug("Unknown macro: $macro");
        return;
    }

    $c->log->debug("Unrolling macro: $macro") if $c->debug;

    my $mdata = $c->config->{macros}->{$macro};
    $c->log->debug(Dumper($mdata)) if $c->debug;

    foreach my $act (@{ $mdata->{actions} }) {
        $c->log->debug(Dumper($act));
        push(@{ $c->stash->{processes} }, $act->{p});

        if($act->{n} =~ /^\$\{(\w+)\}$/) {
            $act->{n} = $c->req->params->{$1};
        }
        push(@{ $c->stash->{names} }, $act->{n});
        push(@{ $c->stash->{actions} }, $act->{a});

        if($act->{v} =~ /^\$\{(\w+)\}$/) {
            $act->{v} = $c->req->params->{$1};
        }
        push(@{ $c->stash->{values} }, $act->{v});
    }
}

sub not_found : Private {
    my ($self, $c) = @_;

    $c->response->body('Asset not found');
    $c->response->status(404);
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
