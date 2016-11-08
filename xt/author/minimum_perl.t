package main;

use 5.008004;

use strict;
use warnings;

# use Test::More 0.88;	# Because of done_testing();

use Test::More 0.40;

eval {
    require ExtUtils::Manifest;
    1;
} or plan skip_all => 'Unable to load ExtUtils::Manifest';

eval {
    require Perl::MinimumVersion;
    1;
} or plan skip_all => 'Unable to load Perl::MinimumVersion';

my $min_perl = '5.008004';

my $manifest = ExtUtils::Manifest::maniread();

my @to_check;

foreach my $fn ( sort keys %{ $manifest } ) {
    $fn =~ m{ \A xt/ }smx
	and next;
    is_perl( $fn )
	or next;
    push @to_check, $fn;
}

plan tests => scalar @to_check;

foreach my $fn ( @to_check ) {
    my $doc = Perl::MinimumVersion->new( $fn );
    cmp_ok $doc->minimum_version(), 'le', $min_perl,
	"$fn works under Perl $min_perl";
}

done_testing;

sub is_perl {
    my ( $fn ) = @_;
    $fn =~ m/ [.] (?: pm | t | pod | (?i: pl ) ) \z /smx
	and return 1;
    -f $fn
	and -T _
	or return 0;
    open my $fh, '<', $fn
	or return 0;
    local $_ = <$fh>;
    close $fh;
    return m/ perl /smx;
}

1;

# ex: set textwidth=72 :
