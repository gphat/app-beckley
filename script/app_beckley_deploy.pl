#!/usr/bin/perl -w
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";
use App::Beckley;

App::Beckley->model('Write')->schema->deploy({ add_drop_table => 1 });
