use strict;
use warnings;
use Test::More;
use Test::Deep;
use Test::Exception;
use Test::NoWarnings qw( clear_warnings had_no_warnings ); $Test::NoWarnings::do_end_test = 0;
use PDL::Types 'types';

# silly workaround for spurious warning message generated by List::MoreUtils
# 0.33_005; note that we do not depend on List::MoreUtils directly, but
# probably some module that we depend on does require it
#
# and another workaround for a warning message emitted by PDL::Core in version
# 2.006_03
had_no_warnings;
require List::MoreUtils;
require PDL::Core;
require Test::PDL;
clear_warnings;

# we should start out without an 'is_pdl' function
ok ! __PACKAGE__->can( 'is_pdl' );

# use Test::PDL '';
package t1;
::cmp_deeply \%Test::PDL::OPTIONS, {
	TOLERANCE   => ::code( sub { abs( $_[0]/1e-6 - 1 ) < 1e-6 ? 1 : ( 0, 'tolerance beyond specified value' ) } ),
	EQUAL_TYPES => 1,
};
::ok ! __PACKAGE__->can( 'is_pdl' );

# use Test::PDL;
package t2;
Test::PDL->import();
::cmp_deeply \%Test::PDL::OPTIONS, {
	TOLERANCE   => ::code( sub { abs( $_[0]/1e-6 - 1 ) < 1e-6 ? 1 : ( 0, 'tolerance beyond specified value' ) } ),
	EQUAL_TYPES => 1,
};
::ok __PACKAGE__->can( 'is_pdl' );

# use Test::PDL -equal_types => 0;
package t3;
Test::PDL->import( -equal_types => 0 );
::cmp_deeply \%Test::PDL::OPTIONS, {
	TOLERANCE   => ::code( sub { abs( $_[0]/1e-6 - 1 ) < 1e-6 ? 1 : ( 0, 'tolerance beyond specified value' ) } ),
	EQUAL_TYPES => 0,
};
$Test::PDL::OPTIONS{EQUAL_TYPES} = 1; # explicitly reset so no need reload
::ok __PACKAGE__->can( 'is_pdl' );

# use Test::PDL -tolerance => 1e-8;
package t4;
Test::PDL->import( -tolerance => 1e-8 );
::cmp_deeply \%Test::PDL::OPTIONS, {
	TOLERANCE   => ::code( sub { abs( $_[0]/1e-8 - 1 ) < 1e-6 ? 1 : ( 0, 'tolerance beyond specified value' ) } ),
	EQUAL_TYPES => 1,
};
::ok __PACKAGE__->can( 'is_pdl' );

# use Test::PDL -tolerance => 1e-8, -equal_types => 0, 'is_pdl';
package t5;
Test::PDL->import( -tolerance => 1e-8, -equal_types => 0, 'is_pdl' );
::cmp_deeply \%Test::PDL::OPTIONS, {
	TOLERANCE   => ::code( sub { abs( $_[0]/1e-8 - 1 ) < 1e-6 ? 1 : ( 0, 'tolerance beyond specified value' ) } ),
	EQUAL_TYPES => 0,
};
::ok __PACKAGE__->can( 'is_pdl' );

# use Test::PDL -whatever => 42;
package t6;
::throws_ok { Test::PDL->import( -whatever => 42 ) } qr/\binvalid option WHATEVER\b/;
::ok ! __PACKAGE__->can( 'is_pdl' );

::had_no_warnings;
::done_testing;
