use strict;
use warnings;
use Test::More tests => 13;
use Test::Deep;
use Test::Exception;

# force reloading Test::PDL on next 'require' + wipe functions living in the
# Test::PDL namespace to avoid redefinition warnings
sub wipe
{
	delete $INC{ 'Test/PDL.pm' };
	delete $Test::PDL::{ $_ } for qw( import _approx _comparison_fails
					  _dimensions_match is_pdl set_options );
}

# we should start out without an 'is_pdl' function
ok ! __PACKAGE__->can( 'is_pdl' );

# use Test::PDL '';
package t1;
require Test::PDL;
::cmp_deeply \%Test::PDL::OPTIONS, {
	TOLERANCE   => ::code( sub { abs( $_[0]/1e-6 - 1 ) < 1e-6 ? 1 : ( 0, 'tolerance beyond specified value' ) } ),
	EQUAL_TYPES => 1,
};
::ok ! __PACKAGE__->can( 'is_pdl' );
::wipe;

# use Test::PDL;
package t1;
require Test::PDL;
Test::PDL->import();
::cmp_deeply \%Test::PDL::OPTIONS, {
	TOLERANCE   => ::code( sub { abs( $_[0]/1e-6 - 1 ) < 1e-6 ? 1 : ( 0, 'tolerance beyond specified value' ) } ),
	EQUAL_TYPES => 1,
};
::ok __PACKAGE__->can( 'is_pdl' );
::wipe;

# use Test::PDL -equal_types => 0;
package t2;
require Test::PDL;
Test::PDL->import( -equal_types => 0 );
::cmp_deeply \%Test::PDL::OPTIONS, {
	TOLERANCE   => ::code( sub { abs( $_[0]/1e-6 - 1 ) < 1e-6 ? 1 : ( 0, 'tolerance beyond specified value' ) } ),
	EQUAL_TYPES => 0,
};
::ok __PACKAGE__->can( 'is_pdl' );
::wipe;

# use Test::PDL -tolerance => 1e-8;
package t3;
require Test::PDL;
Test::PDL->import( -tolerance => 1e-8 );
::cmp_deeply \%Test::PDL::OPTIONS, {
	TOLERANCE   => ::code( sub { abs( $_[0]/1e-8 - 1 ) < 1e-6 ? 1 : ( 0, 'tolerance beyond specified value' ) } ),
	EQUAL_TYPES => 1,
};
::ok __PACKAGE__->can( 'is_pdl' );
::wipe;

# use Test::PDL -tolerance => 1e-8, -equal_types => 0, 'is_pdl';
package t4;
require Test::PDL;
Test::PDL->import( -tolerance => 1e-8, -equal_types => 0, 'is_pdl' );
::cmp_deeply \%Test::PDL::OPTIONS, {
	TOLERANCE   => ::code( sub { abs( $_[0]/1e-8 - 1 ) < 1e-6 ? 1 : ( 0, 'tolerance beyond specified value' ) } ),
	EQUAL_TYPES => 0,
};
::ok __PACKAGE__->can( 'is_pdl' );
::wipe;

# use Test::PDL -whatever => 42;
package t5;
require Test::PDL;
::throws_ok { Test::PDL->import( -whatever => 42 ) } qr/\binvalid option WHATEVER\b/;
::ok ! __PACKAGE__->can( 'is_pdl' );
::wipe;
