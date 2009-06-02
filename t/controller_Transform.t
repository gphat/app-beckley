use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'App::Beckley' }
BEGIN { use_ok 'App::Beckley::Controller::Transform' }

ok( request('/transform')->is_success, 'Request should succeed' );


