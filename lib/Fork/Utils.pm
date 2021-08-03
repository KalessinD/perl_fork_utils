package Fork::Utils;

use 5.012;
use warnings;
use base qw/ Exporter /;
use Config ();
use POSIX ();
use Carp qw/ croak /;

our $VERSION = '0.06';
our @EXPORT_OK = qw/ safe_exec /;

sub safe_exec  {

    my ( %options ) = @_;
    my ( $code, $args, $sigset, $replace_mask ) = @options{ qw/code args sigset replace_mask/ };

    croak( 'Argument $code must be a CODE reference.' ) if ( ref( $code ) ne 'CODE' );
    croak( 'Argument $args must be an ARRAY reference.' ) if ( $args && ref( $args ) ne 'ARRAY' );
    croak( 'Argument $sigset must be an ARRAY reference.' ) if ( $sigset && ref( $sigset ) ne 'ARRAY' );

    state $sig_nums  = [ split( /\s+/, $Config::Config{'sig_num'} ) ];
    state $sig_names = [ split( /\s+/, $Config::Config{'sig_name'} ) ];
    my %signame2signum = ();

    for my $i ( 0 .. $#{$sig_nums} ) {
        $signame2signum{ $sig_names->[ $i ] } = $sig_nums->[ $i ];
    }

    my $new_sig_set = new POSIX::SigSet ();
    my $old_sig_set = new POSIX::SigSet ();

    $new_sig_set->emptyset();
    $old_sig_set->emptyset();

    $sigset = [] if ( ! $sigset ); # let's use empty mask by default

    foreach my $sig_name ( grep { $_ } @{ $sigset } ) {
        $new_sig_set->addset( $signame2signum{ $sig_name } ) if ( $signame2signum{ $sig_name } );
    }

    if ( ! $replace_mask ) { # add signals into the current mask
        POSIX::sigprocmask( POSIX::SIG_BLOCK, $new_sig_set, $old_sig_set );
    } else { # replace the current signla mask
        POSIX::sigprocmask( POSIX::SIG_SETMASK, $new_sig_set, $old_sig_set );
    }

    my $result = eval{ $code->( @{ $args || [] } ); };
    my $error = $@;

    # we don't use POSIX::SIG_UNBLOCK because we can occasionally unblock some signals that were blocked previously
    POSIX::sigprocmask( POSIX::SIG_SETMASK, $old_sig_set );

    $@ = $error; # restore the error if it was replaced by POSIX::sigprocmask

    return( $result );
}

1;
__END__

=head1 NAME

Fork::Utils - a set of useful methods to work with processes and signals on Linux

=head1 SYNOPSIS

    use Fork::Utils qw/ safe_exec /;
    use POSIX ();

    my $sig_action = sub { printf("SIG%s was received\n", $_[0]); };

    $SIG{TERM} = $SIG{INT} = $SIG{QUIT} = $SIG{ALRM} = $sig_action;

    alarm(1);

    my $result = safe_exec(
        args => [ @params ],
        code => sub {

            my @args = @_;

            my $pending_sigset = new POSIX::SigSet ();

            sleep(2);

            if ( POSIX::sigpending( $pending_sigset ) == -1 ) {
              die("sigpending error has occurred");
            }

            if ( $pending_sigset->ismember( POSIX::SIGTERM ) ) {
                printf("%s is pending\n", 'SIGTERM');
            }

            if ( $pending_sigset->ismember( POSIX::SIGINT ) ) {
                printf("%s is pending\n", 'SIGINT');
            }

            if ( $pending_sigset->ismember( POSIX::SIGQUIT ) ) {
                printf("%s is pending\n", 'SIGQUIT');
            }

            if ( $pending_sigset->ismember( POSIX::SIGALRM ) ) {
                printf("%s is pending\n", 'SIGALRM');
            }
        },
        sigset => [qw/ ALRM TERM INT QUIT /]
    );

    if (my $error = $@) {
        STDERR->print("Error: $error\n");
    }

    alarm(0);

    printf("Good bye\n");

The possible output of program is shown below (just press Ctrl+c during the execution to get this certain output):

    SIGINT is pending
    SIGALRM is pending
    SIGINT was received
    SIGALRM was received
    Good bye

=head1 DESCRIPTION

This package provides some methods that can be helpful while working with child-processes and signals.

=head2 safe_exec

Accepts a hash with arguments, one of them is a code reference which ought to
be executed in safe context.  "Safe context" means a context which can't be
accidentally interrupted by some signals.

This method receives a list of signals required to be blocked while code
execution. Once the code is executed the original signal mask will be restored.

Any signal (except KILL and STOP) can be blocked.

The signal names can be taken from C<$Config{'sig_names'}>.

It returns as a result, a code reference which can be called as
C<< $code->( @$args ) >>.

Be aware that in the current implementation this method can't return the list.
The return value looks like the one shown below:

    my $result = $code->( @$args );

In case of any error in the executed code reference the standard C<$@> variable will be set.

=over

=item code

A code reference to be executed in a safe context.

=item args

An array reference of arguments required to be passed into C<code> (see above).

=item sigset

An array reference of signal names to be blocked while executing the C<code> (see above)

=item replace_mask

A flag, turned off by default.

If it's off then passed signals will be added to the current signal mask,
otherwise the mask will be replaced with a new one built with the specified
signals.

=back

=head1 AUTHOR

Chernenko Dmitiry cdn@cpan.org

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under the terms of the the Artistic License (2.0).

=cut
