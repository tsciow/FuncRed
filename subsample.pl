#! /usr/bin/perl
use strict;

sub usage () {
	print << "EOF";
	FunctionalRedundancySubsampling.pl:
	Get equal numbers of read entries to feed into 

	USAGE:
	Subsampling.pl TableFile output_file
EOF
	exit;

};

sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}


if ($#ARGV < 1){
	usage();
}
my $infile = shift @ARGV;
open(infile, $infile) || die "Could not open input file !\n";
my $output = shift @ARGV;# name for output file
my %occur;#hash: sample-name -> number of occurences/counts
while(<infile>){
	chomp;
	my @felder= split /\t/, $_;
	$occur{trim($felder[8])}++;
}
my $lowest = (sort {$occur{$a} <=> $occur{$b}} keys %occur)[0];
seek (infile, 0,0);
open (outfile,">".$output);
my %curr_occur;##hash: sample-name -> number of occurences/counts
while(<infile>){
	my @felder= split /\t/, $_;
	if ($curr_occur{trim($felder[8])} < $occur{$lowest}){
		print outfile $_;
	}
	$curr_occur{trim($felder[8])}++;
}
close (infile);
close (outfile);

