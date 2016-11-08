package DateTime::Calendar::Christian;

use 5.008004;

use strict;
use warnings;

our $VERSION = '0.05';

use DateTime 0.1402;
use DateTime::Calendar::Julian 0.04;

use Carp;
use Params::Validate qw/ validate SCALAR OBJECT /;

use overload ( 'fallback' => 1,
               '<=>' => '_compare_overload',
               'cmp' => '_compare_overload',
               '-' => '_subtract_overload',
               '+' => '_add_overload',
             );

my %reform_dates;
$reform_dates{$_->[0]} = DateTime->new( year  => $_->[1],
                                        month => $_->[2],
                                        day   => $_->[3] )
    for [ italy      => 1582, 10, 15 ], # including some other catholic
                                        # countries (spain, portugal, ...)
        [ france     => 1582, 12, 20 ],
        [ belgium    => 1583,  1,  1 ],
        [ holland    => 1583,  1,  1 ], # or 1583-1-12?
        [ liege      => 1583,  2, 21 ],
        [ augsburg   => 1583,  2, 24 ],
        [ treves     => 1583, 10, 15 ],
        [ bavaria    => 1583, 10, 16 ],
        [ tyrolia    => 1583, 10, 16 ],
        [ julich     => 1583, 11, 13 ],
        [ cologne    => 1583, 11, 14 ], # or 1583-11-13?
        [ wurzburg   => 1583, 11, 15 ],
        [ mainz      => 1583, 11, 22 ],
        [ strasbourg_diocese => 1583, 11, 27 ],
        [ baden      => 1583, 11, 27 ],
        [ carynthia  => 1583, 12, 25 ],
        [ bohemia    => 1584,  1, 17 ],
        [ lucerne    => 1584,  1, 22 ],
        [ silesia    => 1584,  1, 23 ],
        [ westphalia => 1584,  7, 12 ],
        [ paderborn  => 1585,  6, 27 ],
        [ hungary    => 1587, 11,  1 ],
        [ transylvania=>1590, 12, 25 ],
        [ prussia    => 1610,  9,  2 ],
        [ hildesheim => 1631,  3, 26 ],
        [ minden     => 1668,  2, 12 ],
        [ strasbourg => 1682,  2, 16 ],
        [ denmark    => 1700,  3,  1 ],
        [ germany_protestant => 1700,  3,  1 ],
        [ gelderland => 1700,  7, 12 ],
        [ faeror     => 1700, 11, 28 ], # or 1700-11-27?
        [ iceland    => 1700, 11, 28 ],
        [ utrecht    => 1700, 12, 12 ],
        [ zurich     => 1701,  1, 12 ],
        [ friesland  => 1701,  1, 12 ], # or 1701-01-13?
        [ drente     => 1701,  5, 12 ], # or 1701-01-12?
        [ uk         => 1752,  9, 14 ],
        [ bulgaria   => 1915, 11, 14 ], # or 1916-04-14?
        [ russia     => 1918,  2, 14 ],
        [ latvia     => 1918,  2, 15 ],
        [ romania    => 1919,  4, 14 ], # or 1924-10-14?
        ;
# Dates are from http://www.polysyllabic.com/GregConv.html and
# http://privatewww.essex.ac.uk/~kent/calisto/guide/changes.htm
# Only those dates that both sites agree on are included at the moment.

{
    my $DefaultReformDate;
    sub DefaultReformDate
    {
        my $class = shift;

        if (@_)
        {
            $DefaultReformDate = shift;
            unless (ref $DefaultReformDate) {
                my $area = lc $DefaultReformDate;
                $DefaultReformDate = $reform_dates{$area}
                    or croak "Unknown calendar '$area'";
            }
        }

        return $DefaultReformDate;
    }
}
__PACKAGE__->DefaultReformDate('Italy');

sub _init_reform_date {
    my ($base, $self, $rd) = @_;

    if ($rd && ref $rd) {
        $self->{reform_date} = DateTime->from_object( object => $rd );
    } elsif ($rd) {
        $self->{reform_date} = $reform_dates{ lc $rd }
            or croak "Unknown calendar region '$rd'";
    } elsif (ref $base && $base->isa('DateTime::Calendar::Christian')) {
        $self->{reform_date} = $base->{reform_date}
    } else {
        $self->{reform_date} = $base->DefaultReformDate;
    }
}


sub new {
    my $class = shift;
    my %args = validate( @_,
                         { year   => { type => SCALAR, default => undef },
                           month  => { type => SCALAR, default => 1 },
                           day    => { type => SCALAR, default => 1 },
                           hour   => { type => SCALAR, default => 0 },
                           minute => { type => SCALAR, default => 0 },
                           second => { type => SCALAR, default => 0 },
                           nanosecond => { type => SCALAR, default => 0 },
                           locale  => { type => SCALAR | OBJECT,
                                          default => $class->DefaultLocale },
                           time_zone => { type => SCALAR | OBJECT,
                                          default => 'floating' },
                           reform_date => { type => SCALAR | OBJECT,
                                            default => undef },
                         }
                       );

    my $self = {};

    $class->_init_reform_date( $self, delete $args{reform_date} );

    $class = ref $class if ref $class;
    bless $self, $class;

    if (defined $args{year}) {
        $self->{date} = DateTime::Calendar::Julian->new(%args);
        if ($self->{date} >= $self->{reform_date}) {
            $self->{date} = DateTime->new(%args);
            $self->_adjust_calendar;
        }
    }

    return $self;
}

sub _adjust_calendar {
    my $self = shift;

    if ($self->is_gregorian and $self->{date} < $self->{reform_date}) {
        $self->{date} = DateTime::Calendar::Julian->from_object(
                                                object => $self->{date} );
    } elsif ($self->is_julian and $self->{date} >= $self->{reform_date}) {
        $self->{date} = DateTime->from_object( object => $self->{date} );
    }
}

sub is_julian {
    return $_[0]{date}->isa('DateTime::Calendar::Julian');
}

sub is_gregorian {
    return ! $_[0]->is_julian;
}

sub from_epoch {
    my $class = shift;
    my %args = @_;

    my $self = {};

    $class->_init_reform_date( $self, delete $args{reform_date} );

    $class = ref $class if ref $class;
    bless $self, $class;

    $self->{date} = DateTime->from_epoch(%args);
    $self->_adjust_calendar;

    return $self;
}

sub now { shift->from_epoch( epoch => (scalar time), @_ ) }
 
sub today { shift->now(@_)->truncate( to => 'day' ) }

sub from_object {
    my $class = shift;
    my %args = @_;

    my $self = {};

    $class->_init_reform_date( $self, delete $args{reform_date} );

    $class = ref $class if ref $class;
    bless $self, $class;

    my $object = $args{object};
    $self->{date} = DateTime->from_object( object => $object );
    $self->_adjust_calendar;

    return $self;
}

# This method assumes that both current month and next month exists.
# There can be problems when the number of missing days is larger than
# 27.
sub last_day_of_month {
    my ($class, %p) = @_;
    my $month = $p{month};
    # First, determine the first day of the next month.
    $p{day} = 1;
    $p{month}++;
    if ($p{month} > 12) {
        $p{month} -= 12;
        $p{year}++;
    }
    my $self = $class->new( %p );

    if ($self->month != $p{month}) {
        # Apparently, month N+1 does not have a day 1.
        # This means that this date is removed in the calendar reform,
        # and the last day of month N is the last day before the reform.

        $self = $self->from_object( object => $self->{reform_date} );
    }

    # Subtract one. That should be the last day of the month.
    $self->subtract( days => 1 );

    return $self;
}

sub clone {
    my $self = shift;

    my $new = {};
    $new->{reform_date} = $self->{reform_date}->clone;
    $new->{date} = $self->{date}->clone if exists $self->{date};
    bless $new, ref $self;
}

sub is_leap_year {
    my $self = shift;

    my $year = $self->year;
    # This could go wrong if the number of missing days is more than
    # about 300, and reform_date lies at the beginning of the next year.
    if ($year != $self->{reform_date}->year) {
        return $self->{date}->is_leap_year;
    }

    # Difficult case: $year is in the year of the calendar reform
    # Test if Feb 29 exists
    my $d = eval { $self->new( year  => $year,
                               month => 2,
                               day   => 29,
                             ) };
    return defined($d) && $d->month == 2 && $d->day == 29;
}

sub _add_overload {
    my ($dt, $dur, $reversed) = @_;

    if ($reversed) {
        ($dur, $dt) = ($dt, $dur);
    }

    my $new = $dt->clone;
    $new->add_duration($dur);
    return $new;
}

sub _subtract_overload {
    my ($date1, $date2, $reversed) = @_;

    if ($reversed) {
        ($date2, $date1) = ($date1, $date2);
    }

    if (UNIVERSAL::isa($date2, 'DateTime::Duration')) {
        my $new = $date1->clone;
        $new->add_duration( $date2->inverse );
        return $new;
    } else {
        my $date3 = DateTime->from_object( object => $date2 );
        return $date1->{date}->subtract_datetime($date3);
    }
}

sub add { shift->add_duration( DateTime::Duration->new(@_) ) }

sub subtract { return shift->subtract_duration( DateTime::Duration->new(@_) ) }

sub subtract_duration { return $_[0]->add_duration( $_[1]->inverse ) }

sub subtract_datetime {
    my $self = shift;
    my $dt = shift;

    return $self->{date} - $dt->{date};
}

sub add_duration {
    my ($self, $dur) = @_;

    my $start_jul = $self->is_julian;

    # According to the papal bull and the English royal decree that
    # introduced the Gregorian calendar, dates should be calculated as
    # if the change did not happen; this makes date math very easy in
    # most cases...
    $self->{date}->add_duration($dur);
    $self->_adjust_calendar;

    my $dd;
    if ($start_jul and $self->is_gregorian) {

        # The period after reform_date has been calculated in Julian
        # instead of in Gregorian; this may have introduced extra leap
        # days; the date should be set back.
        $dd = $self->gregorian_deviation($self->{date}) -
              $self->gregorian_deviation($self->{reform_date});
    } elsif (not $start_jul and $self->is_julian) {

        # The period before reform_date has been calculated in Gregorian
        # instead of in Julian; we may have to introduce extra leap
        # days; the date should be set back
        $dd = $self->gregorian_deviation($self->{reform_date}) -
              $self->gregorian_deviation($self->{date});
    }

    $self->{date}->subtract( days => $dd ) if $dd;
}

sub gregorian_deviation {
    my ($class, $date) = @_;

    $date ||= $class;

    $date = DateTime::Calendar::Julian->from_object( object => $date );
    return $date->gregorian_deviation;
}

sub reform_date { $_[0]->{reform_date} }

# Almost the same as DateTime::week
sub week
{
    my $self = shift;

    unless ( defined $self->{date}{local_c}{week_year} )
    {
        my $doy = $self->day_of_year;
        my $dow = $self->day_of_week;

        # Convert to closest Thursday:
        $doy += 4-$dow;

        $self->{date}{local_c}{week_number} =
                int(($doy + 6) / 7);

        if ( $self->{date}{local_c}{week_number} == 0 )
        {
            $self->{date}{local_c}{week_year} = $self->year - 1;
            $self->{date}{local_c}{week_number} =
                $self->_weeks_in_year( $self->{date}{local_c}{week_year} );
        }
        elsif ( $self->{date}{local_c}{week_number} >
                $self->_weeks_in_year( $self->year ) )
        {
            $self->{date}{local_c}{week_number} = 1;
            $self->{date}{local_c}{week_year} = $self->year + 1;
        }
        else
        {
            $self->{date}{local_c}{week_year} = $self->year;
        }
    }

    return @{ $self->{date}{local_c} }{ 'week_year', 'week_number' }
}

# This routine assumes that the month December actually exists.
# There can be problems if the number of missing days is larger than 30.
sub _weeks_in_year
{
    my $self = shift;
    my $year = shift;

    my $dec_31 = $self->last_day_of_month( year => $year, month => 12 );

    my $days_in_yr = $dec_31->day_of_year;
    my $dow = $dec_31->day_of_week;

    return int(($days_in_yr +
                ($dow >= 4 ? 7 - $dow : - $dow)) / 7
                + 0.5);
}

sub set {
    my $self = shift;

    my %p = @_;
    croak "Cannot change reform_date with set()"
        if exists $p{reform_date};

    my %old_p = 
        ( reform_date => $self->{reform_date},
          map { $_ => $self->$_() }
            qw( year month day hour minute second nanosecond
                locale time_zone )
        );

    my $new_dt = (ref $self)->new( %old_p, %p );

    %$self = %$new_dt;

    return $self;
}

sub set_time_zone {
    my $self = shift;

    $self->{date}->set_time_zone(@_);
    $self->_adjust_calendar;
}

# This code assumes there is a month of December of the previous year.
sub day_of_year {
    my $self = shift;

    my $doy = $self->{date}->doy;
    if ($self->year == $self->reform_date->year &&
        $self >= $self->reform_date ) {
        $doy -= $self->gregorian_deviation;
        my $end_of_year = $self->last_day_of_month( year  => $self->year - 1,
                                                    month => 12 );
        $doy = ($self->utc_rd_values)[0] - ($end_of_year->utc_rd_values)[0];
    }
    return $doy;
}

sub day_of_year_0 {
    return shift->day_of_year - 1;
}

# Delegate to $self->{date}

for my $sub (qw/year ce_year month month_0 month_name month_abbr
                day_of_month day_of_month_0 day_of_week day_of_week_0
                day_name day_abbr ymd mdy dmy hour minute second hms
                nanosecond millisecond microsecond
                iso8601 datetime week_year week_number
                time_zone offset is_dst time_zone_short_name locale
                utc_rd_values utc_rd_as_seconds local_rd_as_seconds jd
                mjd strftime epoch utc_year compare _compare_overload/,
             # these should be replaced with a corrected version
             qw/truncate/) {
    no strict 'refs';
    *$sub = sub {
                my $self = shift;
                croak "Empty date object in call to $sub"
                    unless exists $self->{date};
                $self->{date}->$sub(@_)
            };
}

*mon = \&month;
*mon_0 = \&month_0;
*day  = \&day_of_month;
*mday = \&day_of_month;
*day_0  = \&day_of_month_0;
*mday_0 = \&day_of_month_0;
*wday = \&day_of_week;
*dow  = \&day_of_week;
*wday_0 = \&day_of_week_0;
*dow_0  = \&day_of_week_0;
*doy = \&day_of_year;
*doy_0 = \&day_of_year_0;
*date = \&ymd;
*min = \&minute;
*sec = \&second;
*DateTime::Calendar::Christian::time = \&hms;

sub DefaultLocale {
    shift;
    DateTime->DefaultLocale(@_);
}

1;
__END__

=head1 NAME

DateTime::Calendar::Christian - Dates in the Christian calendar

=head1 SYNOPSIS

  use DateTime::Calendar::Christian;

  $dt = DateTime::Calendar::Christian->new( year  => 1752,
                                            month => 10,
                                            day   => 4,
                                            reform_date => $datetime );

=head1 DESCRIPTION

DateTime::Calendar::Christian is the implementation of the combined
Julian and Gregorian calendar.

See L<DateTime> for information about most of the methods.

=head1 BACKGROUND

The Julian calendar, introduced in Roman times, had an average year
length of 365.25 days, about 0.03 days more than the correct number. When
this difference had cummulated to about ten days, the calendar was
reformed by pope Gregory XIII, who introduced a new leap year rule. To
correct for the error that had built up over the centuries, ten days
were skipped in October 1582. In most countries, the change date was
later than that; England went Gregorian in 1752, and Russia didn't
change over until 1918.

=head1 METHODS

This manpage only describes those methods that differ from those of
DateTime. See L<DateTime> for all other methods.

=over 4

=item * new( ... )

Besides the usual parameters ("year", "month", "day", "hour", "minute",
"second", "nanosecond", "fractional_seconds", "locale" and "time_zone"),
this class method takes the
additional "reform_date" parameter. This parameter can be a DateTime
object (or an object that can be converted into a DateTime). This
denotes the first date of the Gregorian calendar. It can also be a
string, containing the name of a location, e.g. 'Italy'. Location names
are not case-sensitive.

If this method is used as an instance method and no "reform_date" is
given, the "reform_date" of the returned object is the same as the one
of the object used to call this constructor. This means you can make
"date generators", that implement a calendar with a fixed reform date:

  $english_calendar = DateTime::Calendar::Christian(
                          reform_date => DateTime->new( year  => 1752,
                                                        month => 9,
                                                        day   => 14 )
                                                   );

or equivalently:

  $english_calendar = DateTime::Calendar::Christian(
                          reform_date => 'UK' );

You can use this generator to create dates with the given reform_date:

  $born = $english_calendar->new( year => 1732, month => 2, day => 22 );
  $died = $english_calendar->new( year => 1799, month => 12, day => 14 );

When a date is given that was skipped during a calendar reform, it is
assumed that it is a Gregorian date, which is then converted to the
corresponding Julian date. This behaviour may change in future
versions. If a date is given that can be both Julian and Gregorian, it
will be considered Julian. This is a bug.

The supported reform date location names are:

 Italy -------------- 1582-10-15 # and some other Catholic countries
 France ------------- 1582-12-20
 Belgium ------------ 1583-1-1
 Holland ------------ 1583-1-1   # or 1583-1-12?
 Liege -------------- 1583-2-21
 Augsburg ----------- 1583-2-24
 Treves ------------- 1583-10-15
 Bavaria ------------ 1583-10-16
 Tyrolia ------------ 1583-10-16
 Julich ------------- 1583-11-13
 Cologne ------------ 1583-11-14 # or 1583-11-13?
 Wurzburg ----------- 1583-11-15
 Mainz -------------- 1583-11-22
 Strasbourg_Diocese - 1583-11-27
 Baden -------------- 1583-11-27
 Carynthia ---------- 1583-12-25
 Bohemia ------------ 1584-1-17
 Lucerne ------------ 1584-1-22
 Silesia ------------ 1584-1-23
 Westphalia --------- 1584-7-12
 Paderborn ---------- 1585-6-27
 Hungary ------------ 1587-11-1
 Transylvania ------- 1590-12-25
 Prussia ------------ 1610-9-2
 Hildesheim --------- 1631-3-26
 Minden ------------- 1668-2-12
 Strasbourg --------- 1682-2-16
 Denmark ------------ 1700-3-1
 Germany_Protestant - 1700-3-1
 Gelderland --------- 1700-7-12
 Faeror ------------- 1700-11-28 # or 1700-11-27?
 Iceland ------------ 1700-11-28
 Utrecht ------------ 1700-12-12
 Zurich ------------- 1701-1-12
 Friesland ---------- 1701-1-12  # or 1701-01-13?
 Drente ------------- 1701-5-12  # or 1701-01-12?
 UK ----------------- 1752-9-14
 Bulgaria ----------- 1915-11-14 # or 1916-04-14?
 Russia ------------- 1918-2-14
 Latvia ------------- 1918-2-15
 Romania ------------ 1919-4-14  # or 1924-10-14?

=item * from_epoch

This method accepts an additional "reform_date" argument. Note that the
epoch is defined for most (all?) systems as a date in the Gregorian
calendar.

=item * reform_date

Returns the date of the calendar reform, as a DateTime object.

=item * is_julian, is_gregorian

Return true or false indicating whether the datetime object is in a
specific calendar.

=item * is_leap_year

This method returns a true or false indicating whether or not the
datetime object is in a leap year. If the object is in the year of the
date reform, this method indicates whether there is a leap day in that
year, irrespective of whether the datetime object is in the same
calendar as the possible leap day.

=item * days_in_year

Returns the number of days in the year. Is equal to 365 or 366, except
for the year(s) of the calendar reform.

=item * gregorian_deviation( [$datetime] )

This method returns the difference in days between the Gregorian and the
Julian calendar. If the parameter $datetime is given, it will be used to
calculate the result; in this case this method can be used as a class
method.

=back

=head1 BUGS

=over 4

=item * There are problems with calendars switch to Gregorian before 200
AD or after about 4000 AD. Before 200 AD, this switch leads to
duplication of dates. After about 4000 AD, there could be entire missing
months. (The module can handle dates before 200 AD or after 4000 AD just
fine; it's just the calendar reform dates that should be inside these
limits.)

=item * There may be functions that give the wrong results for the year
of the calendar reform. The function L<truncate> is a known problem, and
L<today> may be a problem. If you find any more problems, please let me
know.

=back

=head1 SUPPORT

Support for this module is provided via the datetime@perl.org email
list. See http://lists.perl.org/ for more details.

=head1 AUTHOR

Eugene van der Pijll <pijll@gmx.net>

Thomas R. Wyant, III F<wyant at cpan dot org>

=head1 COPYRIGHT

Copyright (c) 2003 Eugene van der Pijll.  All rights reserved.  This
program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

Copyright (C) 2016 Thomas R. Wyamt, III

=head1 SEE ALSO

L<DateTime>, L<DateTime::Calendar::Julian>

datetime@perl.org mailing list

=cut
