package main;

use 5.008004;

use strict;
use warnings;

# use Test::More 0.88;	# Because of done_testing();

use Test::More 0.40;

plan tests => 6;

note 'Modules required for development';

require_ok 'ExtUtils::Manifest';

require_ok 'Perl::MinimumVersion';

require_ok 'Test::CPAN::Changes';

require_ok 'Test::Kwalitee';

require_ok 'Test::Pod';

require_ok 'Test::Spelling';

1;

# ex: set textwidth=72 :
