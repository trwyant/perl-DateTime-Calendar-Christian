
use 5.008004;

use ExtUtils::MakeMaker;
WriteMakefile(
    NAME		    => 'DateTime::Calendar::Christian',
    VERSION_FROM	=> 'lib/DateTime/Calendar/Christian.pm',
    PREREQ_PM		=> { DateTime => 0.1402,
                         DateTime::Calendar::Julian => 0.04,
                         Params::Validate => 0.52,
                       },
    ABSTRACT        => 'Dates in the Christian (combined Julian/Gregorian) calendar',
    AUTHOR          => 'Eugene van der Pijll <pijll@gmx.net>',
);
