use strict;
BEGIN { $^W = 1 }

use Test::More tests => 13;
use DateTime::Calendar::Christian;

#########################

my ($d, $d2);

$d = DateTime::Calendar::Christian->new( year  => 1582,
                                         month => 10,
                                         day   => 4,
                                         hour  => 22 );

$d2 = $d->clone;
$d2->add( hours => 3 );
is( $d2->datetime, '1582-10-15T01:00:00', 'adding hours around calendar change' );
$d2->subtract( hours => 3 );
is( $d2->datetime, '1582-10-04J22:00:00', 'subtracting hours around calendar change' );

$d2 = $d->clone;
$d2->add( days => 3 );
is( $d2->ymd, '1582-10-17', 'adding days around calendar change' );
$d2->subtract( days => 3 );
is( $d2->ymd, '1582-10-04', 'subtracting days around calendar change' );

$d2 = $d->clone;
$d2->add( months => 3 );
is( $d2->ymd, '1583-01-14', 'adding months around calendar change' );
$d2->subtract( months => 3 );
is( $d2->ymd, '1582-10-04', 'subtracting months around calendar change' );

$d2 = $d->clone;
$d2->add( years => 3 );
is( $d2->ymd, '1585-10-14', 'adding years around calendar change' );
$d2->subtract( years => 3 );
is( $d2->ymd, '1582-10-04', 'subtracting years around calendar change' );

$d2 = $d->clone;
$d2->add( years => 300 );
is( $d2->ymd, '1882-10-14', 'adding centuries around calendar change' );
$d2->subtract( years => 300 );
is( $d2->ymd, '1582-10-04', 'subtracting centuries around calendar change' );

$d = DateTime::Calendar::Christian->new( year  => 1285,
                                         month => 1,
                                         day   => 1 );

$d->add( years => 300 );
is( $d->ymd, '1585-01-11', 'adding centuries around calendar change' );
$d->subtract( years => 300 );
is( $d->ymd, '1285-01-01', 'subtracting centuries around calendar change' );

my $r = DateTime->new( year  => 1752,
                       month => 9,
                       day   => 14 );

# George Washington's birthday
$d = DateTime::Calendar::Christian->new(
                       year  => 1732,
                       month => 2,
                       day   => 11,
                       reform_date => $r );

# George Washington's 60th birthday
$d->add( years => 60 );
is( $d->ymd, '1792-02-22', "Washington's birthday" );
