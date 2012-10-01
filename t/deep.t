use strict;
use warnings;
use Test::More tests => 31;
use Test::Deep;
use Test::PDL qw( :deep eq_pdl eq_pdl_diag );
use Test::Builder::Tester;
use Test::Exception;
use PDL;

isa_ok test_pdl( 1,2,3 ), 'Test::Deep::PDL';
for my $name ( qw( byte short ushort long longlong float double ) ) {
	no strict 'refs';
	my $sub = "test_$name";
	isa_ok $sub->( 1,2,3 ), 'Test::Deep::PDL';
}

{
	my $pdl1     = pdl( 1,2,3.13 );
	my $got      = { name => 'Histogram', data => $pdl1 };
	my $pdl2     = pdl( 1,2,3.13 );
	my $expected = { name => 'Histogram', data => $pdl2 };
	throws_ok { ok $pdl1 == $pdl2 } qr/multielement piddle in conditional expression at /, '== dies with an error message';
	throws_ok { is $pdl1, $pdl2 } qr/multielement piddle in conditional expression at /, 'is() dies with an error message';
	throws_ok { is_deeply $got, $expected } qr/^multielement piddle in conditional expression at /, 'is_deeply() dies with the same error message';
}

{
	my $pdl      = pdl( 1,2,3.13 );
	my $got      = { name => 'Histogram', data => $pdl };
	my $expected = { name => 'Histogram', data => $pdl };
	throws_ok { ok $pdl == $pdl } qr/^multielement piddle in conditional expression at /, 'even shallow reference comparisons do not work with ==';
	throws_ok { is_deeply $got, $expected } qr/^multielement piddle in conditional expression at /, '... neither with is_deeply()';
}

{
	my $pdl      = pdl( 1,2,3.13 );
	my $got      = { name => 'Histogram', data => $pdl };
	my $expected = { name => 'Histogram', data => $pdl };
	test_out 'ok 1';
	cmp_deeply $got, $expected;
	test_test 'cmp_deeply() without test_pdl() performs only shallow reference comparison';
}

{
	my $pdl      = pdl( 1,2,3.13 );
	my $got      = { name => 'Histogram', data => $pdl };
	my $expected = { name => 'Histogram', data => $pdl->copy };
	test_out 'not ok 1';
	test_fail +4;
	test_diag 'Compared ${$data->{"data"}}';
	test_err  "/#    got : '\\d+'/",
		  "/# expect : '\\d+'/";
	cmp_deeply $got, $expected;
	test_test 'but shallow reference comparison is not powerful enough';
}

{
	my @vals = ( 9,9,9,9 );
	my $got = { data => pdl( @vals ) };
	my $expected = { data => test_pdl( @vals ) };
	test_out 'ok 1';
	cmp_deeply $got, $expected;
	test_test 'succeeds when it should succeed, with values supplied (default type)';
	test_out 'ok 1';
	cmp_deeply $got, { data => code( sub { eq_pdl_diag shift, pdl(@vals) } ) };
	test_test '... and it\'s the same thing as using code()';
}

{
	my $pdl1 = short( -9,-9,-9,-9 );
	my $pdl2 = $pdl1;
	ok eq_pdl( $pdl1, $pdl2 ), 'pdls are equal to begin with';
	my $got = { data => $pdl1 };
	my $expected = { data => test_pdl( $pdl2 ) };
	test_out 'ok 1';
	cmp_deeply $got, $expected;
	test_test 'succeeds when it should succeed, with pdl supplied';
	test_out 'ok 1';
	cmp_deeply $got, { data => code( sub { eq_pdl_diag shift, $pdl2 } ) };
	test_test '... and it\'s the same thing as using code()';
}

{
	my $got = { data => short( -9,-9,-9,-9 ) };
	my $expected = { data => test_short( -9,-9,-9,-9 ) };
	test_out 'ok 1';
	cmp_deeply $got, $expected;
	test_test 'succeeds when it should succeed, with pdl supplied inline';
	test_out 'ok 1';
	cmp_deeply $got, { data => code( sub { eq_pdl_diag shift, short(-9,-9,-9,-9) } ) };
	test_test '... and it\'s the same thing as using code()';
}

{
	my $pdl1 = 2;
	my $pdl2 = pdl( 3,4,9.999 );
	ok !eq_pdl( $pdl1, $pdl2 ), 'pdls are unequal to begin with';
	my $got = { data => $pdl1 };
	my $expected = { data => test_pdl( $pdl2 ) };
	test_out 'not ok 1';
	test_fail +5;
	test_diag 'Comparing $data->{"data"} as a piddle:',
		  'received value is not a PDL';
	test_err  "/#    got : \\('2'\\)/",
		  '/# expect : Double\s+D\s+\[3\].*/';
	cmp_deeply $got, $expected;
	test_test 'fails with correct message and diagnostics when received value is not a piddle';
	test_out 'not ok 1';
	test_fail +6;
	test_diag 'Ran coderef at $data->{"data"} on',
		  '',
		  "'2'",
		  'and it said',
		  'received value is not a PDL';
	cmp_deeply $got, { data => code( sub { eq_pdl_diag shift, $pdl2 } ) };
	test_test '... but the diagnostics are better than with code()';
}

{
	my $pdl1 = pdl( 3,4,9.999 );
	my $pdl2 = pdl( 3,4,10 );
	ok !eq_pdl( $pdl1, $pdl2 ), 'pdls are unequal to begin with';
	my $got = { data => $pdl1 };
	my $expected = { data => test_pdl( $pdl2 ) };
	test_out 'not ok 1';
	test_fail +5;
	test_diag 'Comparing $data->{"data"} as a piddle:',
		  'values do not match';
	test_err  '/#    got : Double\s+D\s+\[3\].*/',
		  '/# expect : Double\s+D\s+\[3\].*/';
	cmp_deeply $got, $expected;
	test_test 'fails with correct message and diagnostics on value mismatch';
	test_out 'not ok 1';
	test_fail +6;
	test_diag 'Ran coderef at $data->{"data"} on',
		  '';
	test_err  '/# PDL=SCALAR\(0x[0-9A-Fa-f]+\)/';
	test_diag 'and it said',
		  'values do not match';
	cmp_deeply $got, { data => code( sub { eq_pdl_diag shift, $pdl2 } ) };
	test_test '... but the diagnostics are better than with code()';
}

{
	my $pdl1 = short( 3,4,-6 );
	my $pdl2 = long( 3,4,10 );
	ok !eq_pdl( $pdl1, $pdl2 ), 'pdls are unequal to begin with';
	my $got = { data => $pdl1 };
	my $expected = { data => test_pdl( $pdl2 ) };
	test_out 'not ok 1';
	test_fail +5;
	test_diag 'Comparing $data->{"data"} as a piddle:',
		  'types do not match (EQUAL_TYPES is true)';
	test_err  '/#    got : Short\s+D\s+\[3\].*/',
		  '/# expect : Long\s+D\s+\[3\].*/';
	cmp_deeply $got, $expected;
	test_test 'fails with correct message and diagnostics on type mismatch';
	test_out 'not ok 1';
	test_fail +6;
	test_diag 'Ran coderef at $data->{"data"} on',
		  '';
	test_err  '/# PDL=SCALAR\(0x[0-9A-Fa-f]+\)/';
	test_diag 'and it said',
		  'types do not match (EQUAL_TYPES is true)';
	cmp_deeply $got, { data => code( sub { eq_pdl_diag shift, $pdl2 } ) };
	test_test '... but the diagnostics are better than with code()';
}
