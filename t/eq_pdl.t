use strict;
use warnings;
use Test::More;
use PDL;
use Test::PDL qw( eq_pdl );
my @warns; $SIG{__WARN__} = sub {push @warns, @_};

sub run_eq_pdl
{
	my $scalar = eq_pdl(@_);
	my @list = eq_pdl(@_);
	cmp_ok(scalar @list, '==', 2, 'eq_pdl() returns a list with two elements in list context');
	cmp_ok $scalar, '==', $list[0], '... and first element matches the return value in scalar context';
	return @list;
}

my ( $got, $expected, $ok, $diag );

( $ok, $diag ) = run_eq_pdl();
ok !$ok, 'rejects missing arguments';
is $diag, 'received value is not a ndarray';

$got = pdl( 9,-10 );
( $ok, $diag ) = run_eq_pdl( $got );
ok !$ok, 'rejects missing arguments';
is $diag, 'expected value is not a ndarray';

$expected = 3;
$got = 4;
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'rejects non-piddle arguments';
is $diag, 'received value is not a ndarray';

$expected = 3;
$got = long( 3,4 );
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'rejects non-piddle arguments';
is $diag, 'expected value is not a ndarray';

$expected = short( 1,2 );
$got = -2;
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'rejects non-piddle arguments';
is $diag, 'received value is not a ndarray';

$expected = long( 3,4 );
$got = pdl( 3,4 );
( $ok, $diag ) = run_eq_pdl( $got, $expected, { require_equal_types => 0 } );
ok $ok, 'all else being equal, compares equal on differing types when \'require_equal_types\' is false';
is $diag, '';

$expected = long( 3,4 );
$got = pdl( 3,4 );
( $ok, $diag ) = run_eq_pdl( $got, $expected, { require_equal_types => 1 } );
ok !$ok, 'catches type mismatch, but only when \'require_equal_types\' is true';
is $diag, 'types do not match (\'require_equal_types\' is true)';

$expected = long( 3 );
$got = long( 3,4 );
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'catches dimensions mismatches (number of dimensions)';
is $diag, 'dimensions do not match in number';

$expected = zeroes( double, 3,4 );
$got = zeroes( double, 3,4,1 );
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'does not treat degenerate dimensions specially';
is $diag, 'dimensions do not match in number';

$expected = long( [ [3,4],[1,2] ] );
$got = long( [ [3,4,5], [1,2,3] ] );
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'catches dimensions mismatches (extent of dimensions)';
is $diag, 'dimensions do not match in extent';

$expected = long( 4,5,6,-1,8,9 )->inplace->setvaltobad( -1 );
$got = long( 4,5,6,7,-1,9 )->inplace->setvaltobad( -1 );
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'catches bad value pattern mismatch';
is $diag, 'bad value patterns do not match';

$expected = long( 4,5,6,7,8,9 );
$got = long( 4,5,6,7,-8,9 );
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'catches value mismatches for integer data';
is $diag, 'values do not match';

$expected = pdl( 4,5,6,7,8,9 );
$got = pdl( 4,5,6,7,-8,9 );
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'catches value mismatches for floating-point data';
is $diag, 'values do not match';

$expected = pdl( 4,5,6,7,8,9 );
$got = pdl( 4,5,6,7,8.001,9 );
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'approximate comparison for floating-point data fails correctly at documented default tolerance of 1e-6';
is $diag, 'values do not match';

$expected = pdl( 4,5,6,7,8,9 );
$got = pdl( 4,5,6,7,8.0000001,9 );
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok $ok, 'approximate comparison for floating-point data succeeds correctly at documented default tolerance of 1e-6';
is $diag, '';

$expected = pdl( 4,5,6,7,8,9 );
$got = pdl( 4,5,6,7,8.001,9 );
( $ok, $diag ) = run_eq_pdl( $got, $expected, { atol => 1e-2 } );
ok $ok, 'approximate comparison for floating-point data succeeds correctly at user-specified tolerance of 1e-2';
is $diag, '';

$expected = pdl( 0,1,2,3,4 );
$got = sequence 5;
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok $ok, 'succeeds when it should succeed';
is $diag, '';

$expected = null;
$got = null;
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok $ok, 'null == null';
is $diag, '';

$got = zeroes(0);
$expected = null;
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok $ok, 'null == empty';
is $diag, '';

$expected = null;
$got = pdl( 1,2,3 );
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'pdl( ... ) != null';
is $diag, 'received a non-empty ndarray while expecting an empty one';

$expected = pdl( 1,2,3 );
$got = null;
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok !$ok, 'null != pdl( ... )';
is $diag, 'received an empty ndarray while expecting a non-empty one';

################################################################################
note 'mixed-type comparisons';

$expected = double( 0,1,2.001,3,4 );
$got = long( 0,1,2,3,4 );

( $ok, $diag ) = run_eq_pdl( $got, $expected, { atol => 1e-2, require_equal_types => 0 } );
ok $ok, 'succeeds correctly for long/double';
is $diag, '';

( $ok, $diag ) = run_eq_pdl( $got, $expected, { atol => 1e-6, require_equal_types => 0 } );
ok !$ok, 'fails correctly for long/double';
is $diag, 'values do not match';

$expected = short( 0,1,2,3,4 );
$got = float( 0,1,2.001,3,4 );

( $ok, $diag ) = run_eq_pdl( $got, $expected, { atol => 1e-2, require_equal_types => 0 } );
ok $ok, 'succeeds correctly for float/short';
is $diag, '';

( $ok, $diag ) = run_eq_pdl( $got, $expected, { atol => 1e-6, require_equal_types => 0 } );
ok !$ok, 'fails correctly for float/short';
is $diag, 'values do not match';

$expected = float( 0,-1,2.001,3,49999.998 );
$got = double( 0,-0.9999,1.999,3,49999.999 );

( $ok, $diag ) = run_eq_pdl( $got, $expected, { atol => 1e-2, require_equal_types => 0 } );
ok $ok, 'succeeds correctly for double/float';
is $diag, '';

( $ok, $diag ) = run_eq_pdl( $got, $expected, { atol => 1e-6, require_equal_types => 0 } );
ok !$ok, 'fails correctly for double/float';
is $diag, 'values do not match';

################################################################################
note 'tests with values of significantly different magnitudes, no zeroes';
$expected = double( 1e+3, 1, 1e-3 );
$got = double( 1.001e+3, 1.001, 1.001e-3 );

( $ok, $diag ) = run_eq_pdl( $got, $expected, { atol => 0.999 } );
ok !$ok, 'still fails with an absolute tolerance of 0.999';
is $diag, 'values do not match';

( $ok, $diag ) = run_eq_pdl( $got, $expected, { atol => 1 } );
ok $ok, 'passes with an absolute tolerance of 1';
is $diag, '';

################################################################################
note 'miscellaneous';

$expected = long( 4,5,6,7,8,9 );
$expected->badflag( 1 );
$got = long( 4,5,6,7,8,9 );
$got->badflag( 0 );
( $ok, $diag ) = run_eq_pdl( $got, $expected );
ok $ok, "isn't fooled by differing badflags";
is $diag, '';

is "@warns", "", "no warnings";
done_testing;
