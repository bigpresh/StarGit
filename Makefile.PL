use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'StarGit',
    AUTHOR              => q{franck cuny <franck@lumberjaph.net>},
    VERSION_FROM        => 'lib/StarGit.pm',
    ABSTRACT            => 'Explore your GitHub galaxy',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'YAML'       => 0,
        'Dancer'     => 1.3051,
        'Plack'      => 0.9974,
        'MongoDB'    => 0.43,
        'Template'   => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'StarGit-*' },
);
