use strict;
BEGIN { $^W = 1 }

use Test::More tests => 8;
use DateTime::Calendar::Christian;

#########################

my ($d, $d2, $d3, $dur);

$d = DateTime::Calendar::Christian->new( year  => 1582,
                                         month => 10,
                                         day   => 4 );

$dur = DateTime::Duration->new( days => 2 );

$d2 = $d + $dur;
is( $d2->ymd, '1582-10-16', '+' );

$d3 = $d2 - $dur;
is( $d3->ymd, '1582-10-04', '-' );

$d += $dur;
is( $d->ymd, '1582-10-16', '+=' );

$d -= $dur;
is( $d->ymd, '1582-10-04', '-=' );

$dur = $d3 - $d;
isa_ok( $dur, 'DateTime::Duration', 'dt1 - dt2' );
is( $dur->days, 0, 'subtracting datetimes' );

$dur = $d2 - $d;
is( $dur->days, 2, 'subtracting datetimes' );

ok( $d < $d2, '<' );
