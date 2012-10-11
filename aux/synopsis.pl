use strict;
use warnings;
use Path::Class;
use Capture::Tiny qw( capture );
use Log::Any::App qw( $log ), -file => 0, -level => 'debug';

# write synopsis to file
my $module = file( 'lib', 'Test', 'PDL.pm' );
my $synopsis = get_synopsis( $module );
my $out_file = file( 'aux', 'pod.t' );
write_synopsis( $out_file, $synopsis );

# execute synopsis
my( $stdout, $stderr ) = capture { system $^X, '-Mlib=lib', $out_file };
$log->info( "stdout=\n$stdout" );
$log->info( "stderr=\n$stderr" );

sub get_synopsis
{
	my $module = shift;
	my $fh = $module->openr;
	chomp( my @text = map { s/^\t//; $_ } grep { /^=head1 SYNOPSIS/ .. /^=cut/ } <$fh> );
	splice @text, 0, 2;		# delete =head1 line and following blank line
	splice @text, -1;		# delete =cut line
	my $synopsis = join "\n", @text;
	$log->debug( "synopsis=\n$synopsis" );
	return $synopsis;
}

sub write_synopsis
{
	my( $file, $synopsis ) = @_;
	my $fh = $file->openw;
	print $fh $synopsis;
}
