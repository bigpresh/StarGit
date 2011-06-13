use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'StarGit',
    AUTHOR       => q{franck cuny <franck@lumberjaph.net>},
    VERSION_FROM => 'lib/StarGit.pm',
    ABSTRACT     => 'Explore your GitHub galaxy',
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002
        ? ( 'LICENSE' => 'perl' )
        : () ),
    PL_FILES  => {},
    PREREQ_PM => {
        'Test::More'                  => 0,
        'YAML'                        => 0,
        'Dancer'                      => 1.3051,
        'Plack'                       => 0.9974,
        'MongoDB'                     => 0.43,
        'Template'                    => 0,
        'Moose'                       => 2.0007,
        'MooseX::App::Cmd'            => 0.06,
        'Try::Tiny'                   => 0.09,
        'JSON'                        => 2.53,
        'DateTime'                    => 0.70,
        'MooseX::ConfigFromFile'      => 0.03,
        'Log::Dispatchouli'           => 2.005,
        'Net::HTTP::Spore'            => 0,
        'Cache::Memcached'            => 0,
        'Plack::Middleware::ETag'     => 0.03,
        'MooseX::Role::Parameterized' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'StarGit-*' },
);
