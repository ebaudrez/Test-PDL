use strict;
use warnings;
use Test::More;

eval { require Capture::Tiny };
plan skip_all => 'Capture::Tiny not found' if $@;

plan tests => 6;

# test that eq_pdl() doesn't produce any output so it can safely be used in non-test code
{
	my $rc;
	my( $stdout, $stderr ) = Capture::Tiny::capture( sub {
			my @cmd = ( $^X, '-Ilib', '-MTest::PDL=eq_pdl', '-e', 'eq_pdl(3,4)' );
			$rc = system @cmd;
		} );
	cmp_ok $rc, '==', 0;
	is $stdout, '';
	is $stderr, '';
}

# test that eq_pdl_diag() doesn't produce any output so it can safely be used in non-test code
{
	my $rc;
	my( $stdout, $stderr ) = Capture::Tiny::capture( sub {
			my @cmd = ( $^X, '-Ilib', '-MTest::PDL=eq_pdl_diag', '-e', 'eq_pdl_diag(3,4)' );
			$rc = system @cmd;
		} );
	cmp_ok $rc, '==', 0;
	is $stdout, '';
	is $stderr, '';
}
