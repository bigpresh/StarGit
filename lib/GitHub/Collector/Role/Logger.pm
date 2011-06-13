package GitHub::Collector::Role::Logger;

use Moose::Role;
use Log::Dispatchouli;

has logger => (
    is      => 'rw',
    isa     => 'Log::Dispatchouli',
    lazy    => 1,
    default => sub {
        my $logger = Log::Dispatchouli->new(
            {
                ident     => 'GitHub::Collector',
                facility  => 'user',
                to_stdout => 1,
            }
        );
    },
    handles => {
        log   => 'log',
        debug => 'log_debug',
        fatal => 'log_fatal',
        error => 'log_error',
    },
);

1;
