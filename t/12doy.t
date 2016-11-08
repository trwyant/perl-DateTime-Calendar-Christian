use 5.008004;

use strict;
use warnings;

use Test::More 0.88;	# Because of done_testing();
use DateTime::Calendar::Christian;

#########################

sub test_dates {
    my $r = DateTime->new( year => 1752, month => 9, day => 14 );
    foreach my $test ( @_ )
    {
        my @args = @{ $test->[0] };
        my @results = @{ $test->[1] };

        my $dt = DateTime::Calendar::Christian->new(
                                year  => $args[0],
                                month => $args[1],
                                day   => $args[2],
                                reform_date => $r,
                              );

        is( $dt->day_of_year, $results[0], "doy of @args" );
        is( $dt->day_of_year_0, $results[0]-1, "doy_0 of @args" );
    }
}

my @tests = ( [ [ 1752,  1,  1 ], [   1 ] ],
              [ [ 1752,  1, 31 ], [  31 ] ],
              [ [ 1752,  2, 28 ], [  59 ] ],
              [ [ 1752,  2, 29 ], [  60 ] ],
              [ [ 1752,  3,  1 ], [  61 ] ],
              [ [ 1752,  9,  2 ], [ 246 ] ],
              [ [ 1752,  9, 14 ], [ 247 ] ],
              [ [ 1752, 12, 31 ], [ 355 ] ],
            );

test_dates( @tests );

done_testing;

# ex: set textwidth=72 :
