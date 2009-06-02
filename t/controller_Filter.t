use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'App::Beckley' }
BEGIN { use_ok 'App::Beckley::Controller::Filter' }

ok( request('/filter')->is_success, 'Request should succeed' );


