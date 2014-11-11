#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Benchmark qw( timestr timeit);
use Time::HiRes qw( time );
use List::Util qw(sum);
use Data::Dumper;

main();


sub main {

    my ( $fastaq_filename, $benchmark_module, $number_of_runs, $clean, $file_type ) = initialise();
    
    my $benchmark = config( $fastaq_filename, $benchmark_module, $number_of_runs, $file_type );

    
    clean_up( $benchmark ) if $clean;

    
    create_analysis_dir( $benchmark );
    
    if ($benchmark_module eq 'time_hires') {

	for my $kmc( keys %{$benchmark} ) {
	    if ( $kmc =~ m/^k/ ) {
		my @durations;
		
		for (my $i = 0; $i < $number_of_runs; $i++) {
		    my $kmc_bin = $kmc;
		    start_benchmark( $kmc_bin, $benchmark->{$kmc}, $fastaq_filename, $benchmark_module, $number_of_runs, $file_type );
		    push( @durations,$benchmark->{$kmc}->{duration} );
		    
		}
		$benchmark->{$kmc}->{average_duration} = sprintf("%.3f", sum(@durations)/$number_of_runs);
	    }
	}

    }
    else {
	
	for my $kmc( keys %{$benchmark} ) {
	    if ( $kmc =~ m/^k/ ) {
		my $kmc_bin = $kmc;
		start_benchmark( $kmc_bin, $benchmark->{$kmc}, $fastaq_filename, $benchmark_module, $number_of_runs, $file_type );
	    }
	}
    }
    print Dumper( $benchmark );

}


sub start_benchmark {

    my ( $kmc_bin, $kmc, $fastaq_filename, $benchmark_module, $number_of_runs, $file_type ) = @_;
    $kmc->{cmd} = build_cmd( $kmc_bin, $kmc->{kmc_exe}, $kmc->{output_filename}, $kmc->{analysis_dir}, $fastaq_filename, $file_type );

    unless ( $benchmark_module eq 'time_hires' ) {
	$kmc->{time_taken} = run_cmd_and_time_it_with_benchmark( $kmc->{cmd}, $kmc->{output_filename}, $kmc->{analysis_dir}, $number_of_runs );
    }
    else {
	$kmc->{duration} = run_cmd_and_time_it_with_time_hires( $kmc->{cmd}, $kmc->{output_filename}, $kmc->{analysis_dir} );
    }
}

sub run_cmd_and_time_it_with_benchmark {

    my ( $cmd, $output_filename, $analysis_dir, $number_of_runs ) = @_;
    my $time_taken = timestr( timeit( $number_of_runs, sub { `$cmd` } ) );
    return($time_taken);
}

sub run_cmd_and_time_it_with_time_hires {

    my ( $cmd, $output_filename, $analysis_dir ) = @_;
    
    my $start = time();
    my $output = `$cmd`;
    my $end = time();
    
    my $duration = sprintf( "%.3f", $end - $start );
    
    return ( $duration );
}

sub build_cmd {

    my ( $kmc_bin, $exe, $output_filename, $analysis_dir, $fastaq_filename, $file_type ) = @_;
    my $cmd = $exe . " -k100 -m4 -ci10 -cs100000000 -$file_type $fastaq_filename $output_filename $analysis_dir";    
    return ( $cmd );
}

sub config {

    my ( $fastaq_filename, $benchmark_module, $number_of_runs, $file_type ) = @_;
    my %benchmark = (
	commandline_parameters => {
	    fastaq_filename => $fastaq_filename,
	    module => $benchmark_module,
	    number_of_runs => $number_of_runs,
	    file_type => $file_type,
	},
	kmc_original => {
	    kmc_exe => '../kmc_kmc/kmc',
	    analysis_dir => '/home/vagrant/build/kmc_bin/perl_profiler/kk_analysis/',
	    output_filename => 'kk_out.res',
	    cmd => '',
	    duration => '',
	},
	kmc_exe => {
	    kmc_exe => '../kmc_exe/kmc',
	    analysis_dir => '/home/vagrant/build/kmc_bin/perl_profiler/ke_analysis/',
	    output_filename => 'ke_out.res',
	    cmd => '',
	    duration => '',
	},
	kmc_js21 => {
	    kmc_exe => '../kmc_js21/kmc',
	    analysis_dir => '/home/vagrant/build/kmc_bin/perl_profiler/kj_analysis/',
	    output_filename => 'kj_out.res',
	    cmd => '',
	    duration => '',
	},
	kmc_native => {
	    kmc_exe => '../kmc_native/kmc',
	    analysis_dir => '/home/vagrant/build/kmc_bin/perl_profiler/kn_analysis/',
	    output_filename => 'kn_out.res',
	    cmd => '',
	    duration => '',
	},
	kmc_native_certain => {
	    kmc_exe => '../kmc_native_certain/kmc',
	    analysis_dir => '/home/vagrant/build/kmc_bin/perl_profiler/knc_analysis/',
	    output_filename => 'knc_out.res',
	    cmd => '',
	    duration => '',
	}
	);

    return(\%benchmark);
}

sub initialise {

    my ( $fastaq_filename, $benchmark_module, $number_of_runs, $clean );    
    GetOptions ("bm|benchmark_module=s" => \$benchmark_module,
		"f|filename=s" => \$fastaq_filename,
		"r|number_of_runs=i" => \$number_of_runs,
		"c|clean" => \$clean
	) or die("Error in command line arguments\n");
    
    my $file_type = check_fast_a_q($fastaq_filename);

    return( $fastaq_filename, $benchmark_module, $number_of_runs, $clean, $file_type );
}

sub check_fast_a_q {

    my ( $fastaq_filename ) = @_;
    my $file_type;

    my $output = `head -1 $fastaq_filename`;
    $file_type = 'fa' if $output =~ m/^\>/;
    $file_type = 'fq' if $output =~ m/^\@/;

    return( $file_type );
}

sub create_analysis_dir {

    my ( $benchmark ) = @_;
    for my $kmc( keys %{$benchmark} ) {
	if ( $kmc =~ m/^k/) {
	    unless ( -d $benchmark->{$kmc}->{analysis_dir} ) {
		`mkdir $benchmark->{$kmc}->{analysis_dir}`;
	    }
	}
    }
}

sub clean_up {

    my ( $benchmark ) = @_;
    for my $kmc( keys %{$benchmark} ) {
	if ( $kmc =~ m/^k/) {
	    unless ( !-d $benchmark->{$kmc}->{analysis_dir} ) {
		`rm -r $benchmark->{$kmc}->{analysis_dir}`;
	    }
	}
    }
}
