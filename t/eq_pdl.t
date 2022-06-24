use strict;
use warnings;
use Test::More;
use PDL;
use Test::PDL qw( eq_pdl );
use Test::NoWarnings qw(had_no_warnings); $Test::NoWarnings::do_end_test = 0;

my ( $got, $expected, $diag );

$got = pdl( 9,-10 );
ok !eq_pdl(), 'rejects missing arguments';
ok !eq_pdl( $got ), 'rejects missing arguments';

$expected = 3;
$got = 4;
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'rejects non-piddle arguments';
is $diag, 'received value is not a ndarray';

$expected = 3;
$got = long( 3,4 );
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'rejects non-piddle arguments';
is $diag, 'expected value is not a ndarray';

$expected = short( 1,2 );
$got = -2;
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'rejects non-piddle arguments';
is $diag, 'received value is not a ndarray';

$expected = long( 3,4 );
$got = pdl( 3,4 );
ok eq_pdl( $got, $expected, { EQUAL_TYPES => 0 } ), 'all else being equal, compares equal on differing types when EQUAL_TYPES is false';

$expected = long( 3,4 );
$got = pdl( 3,4 );
ok !eq_pdl( $got, $expected, { EQUAL_TYPES => 1, REASON => \$diag } ), 'catches type mismatch, but only when EQUAL_TYPES is true';
is $diag, 'types do not match (EQUAL_TYPES is true)';

$expected = long( 3 );
$got = long( 3,4 );
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'catches dimensions mismatches (number of dimensions)';
is $diag, 'dimensions do not match in number';

$expected = zeroes( double, 3,4 );
$got = zeroes( double, 3,4,1 );
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'does not treat degenerate dimensions specially';
is $diag, 'dimensions do not match in number';

$expected = long( [ [3,4],[1,2] ] );
$got = long( [ [3,4,5], [1,2,3] ] );
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'catches dimensions mismatches (extent of dimensions)';
is $diag, 'dimensions do not match in extent';

$expected = long( 4,5,6,-1,8,9 )->inplace->setvaltobad( -1 );
$got = long( 4,5,6,7,-1,9 )->inplace->setvaltobad( -1 );
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'catches bad value pattern mismatch';
is $diag, 'bad value patterns do not match';

$expected = long( 4,5,6,7,8,9 );
$got = long( 4,5,6,7,-8,9 );
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'catches value mismatches for integer data';
is $diag, 'values do not match';

$expected = pdl( 4,5,6,7,8,9 );
$got = pdl( 4,5,6,7,-8,9 );
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'catches value mismatches for floating-point data';
is $diag, 'values do not match';

$expected = pdl( 4,5,6,7,8,9 );
$got = pdl( 4,5,6,7,8.001,9 );
# remember that approx() remembers the tolerance across invocations, so we
# explicitly specify the tolerance at each invocation
ok !all( approx $got, $expected, 1e-6 ), 'differ by more than 0.000001';
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'approximate comparison for floating-point data fails correctly at documented default tolerance of 1e-6';
is $diag, 'values do not match';

$expected = pdl( 4,5,6,7,8,9 );
$got = pdl( 4,5,6,7,8.0000001,9 );
ok all( approx $got, $expected, 1e-6 ), 'differ by less than 0.000001';
ok eq_pdl( $got, $expected ), 'approximate comparison for floating-point data succeeds correctly at documented default tolerance of 1e-6';

$expected = pdl( 4,5,6,7,8,9 );
$got = pdl( 4,5,6,7,8.001,9 );
ok all( approx $got, $expected, 1e-2 ), 'differ by less than 0.01';
ok eq_pdl( $got, $expected, { TOLERANCE => 1e-2 } ), 'approximate comparison for floating-point data succeeds correctly at user-specified tolerance of 1e-2';

$expected = pdl( 0,1,2,3,4 );
$got = sequence 5;
ok eq_pdl( $got, $expected ), 'succeeds when it should succeed';

$expected = null;
$got = null;
ok eq_pdl( $got, $expected ), 'null == null';

$got = zeroes(0);
$expected = null;
ok eq_pdl( $got, $expected ), 'null == empty';

$expected = null;
$got = pdl( 1,2,3 );
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'pdl( ... ) != null';
is $diag, 'types do not match (EQUAL_TYPES is true)';

$expected = pdl( 1,2,3 );
$got = null;
ok !eq_pdl( $got, $expected, { REASON => \$diag } ), 'null != pdl( ... )';
is $diag, 'types do not match (EQUAL_TYPES is true)';

note 'mixed-type comparisons';

$expected = double( 0,1,2.001,3,4 );
$got = long( 0,1,2,3,4 );

ok all( approx $got, $expected, 1e-2 ), 'differ by less than 0.01';
ok eq_pdl( $got, $expected, { TOLERANCE => 1e-2, EQUAL_TYPES => 0 } ), 'succeeds correctly for long/double';

ok !all( approx $got, $expected, 1e-6 ), 'differ by more than 0.000001';
ok !eq_pdl( $got, $expected, { TOLERANCE => 1e-6, EQUAL_TYPES => 0, REASON => \$diag } ), 'fails correctly for long/double';
is $diag, 'values do not match';

$expected = short( 0,1,2,3,4 );
$got = float( 0,1,2.001,3,4 );

ok all( approx $got, $expected, 1e-2 ), 'differ by less than 0.01';
ok eq_pdl( $got, $expected, { TOLERANCE => 1e-2, EQUAL_TYPES => 0 } ), 'succeeds correctly for float/short';

ok !all( approx $got, $expected, 1e-6 ), 'differ by more than 0.000001';
ok !eq_pdl( $got, $expected, { TOLERANCE => 1e-6, EQUAL_TYPES => 0, REASON => \$diag } ), 'fails correctly for float/short';
is $diag, 'values do not match';

$expected = float( 0,-1,2.001,3,49999.998 );
$got = double( 0,-0.9999,1.999,3,49999.999 );

ok all( approx $got, $expected, 1e-2 ), 'differ by less than 0.01';
ok eq_pdl( $got, $expected, { TOLERANCE => 1e-2, EQUAL_TYPES => 0 } ), 'succeeds correctly for double/float';

ok !all( approx $got, $expected, 1e-6 ), 'differ by more than 0.000001';
ok !eq_pdl( $got, $expected, { TOLERANCE => 1e-6, EQUAL_TYPES => 0, REASON => \$diag } ), 'fails correctly for double/float';
is $diag, 'values do not match';

note 'miscellaneous';

$expected = long( 4,5,6,7,8,9 );
$expected->badflag( 1 );
$got = long( 4,5,6,7,8,9 );
$got->badflag( 0 );
ok eq_pdl( $got, $expected ), "isn't fooled by differing badflags";

had_no_warnings;
done_testing;
