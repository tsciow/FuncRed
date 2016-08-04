#! /usr/bin/perl
use strict;

sub usage () {
	print << "EOF";
	FunctionalRedundancy.pl:
	Calculate TFC for different taxonomic levels.

	USAGE:
	FunctionalRedundancy.pl TableFile output_file tax_levels_of_interest ....
	Example:
	FunctionalRedundancy.pl MyTable.txt Myoutput 1 2 3 4
	writes Myoutput taking MyTable.txt as input calculating TFC on genus, family, order and class level (1,2,3,4)

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


if ($#ARGV < 2){
	usage();
}

my %tax_level_names =(0 => "species", 1 => "genus" , 2 => "family", 3 => "order" , 4 => "class" , 5 => "phylum" , 6 => "superkingdom");

###########################################################################################
#
# Read input file and store in Hash of Hashes of Hashes of Hashes
#		sample->tax_level->kegg->taxon->counts_summed_up
#
#

my %total_table;#HoHoHoH kegg->tax_level->taxon->sample->counts_sum

open(infile, shift @ARGV) || die "Could not open input file !\n";
my $output = shift @ARGV;# name for output file
my @tax_level_of_interest = @ARGV;
my %all_kegg;#hash to store all kegg-nrs present in any sample/taxon
my %sample_group;# hash sample -> sample-group (in fact replicate-> actual sample)
while(<infile>){
	chomp;
	my @felder= split /\t/, $_;
	$sample_group{trim($felder[8])}=trim($felder[9]);#sampleID -> sample-group
	foreach my $tax_interest (@tax_level_of_interest){
		$total_table{trim($felder[8])}{$tax_interest}{trim($felder[7])}{trim($felder[$tax_interest])}++;
	}
	$all_kegg{$felder[7]}++;
}
close (infile);

open (OUT, ">".$output);

my @samples = keys %total_table;#all samples present in input file
for my $i (0 .. ($#samples-1)){ # go through all samples and compare to the ones following
	for my $j ($i+1 .. ($#samples)){
#make sure we don't compare replicates of one sample
		if ($sample_group{$samples[$i]} ne $sample_group{$samples[$j]}){# %sample_group: hash sample -> sample-group (in fact replicate-> actual sample) filled from last column of input file
			print "\n",$samples[$i],"\t",$samples[$j];
			print OUT "\n========================================================================\n",$samples[$i]," vs. ",$samples[$j],"\ntaxlevel\tTFC\tFC\tFR\n";

			foreach my $tax_interest (@tax_level_of_interest){# tax levels of interest abarbeiten
				my @kegg = keys %all_kegg;
				my %Y;#HoHoH kegg->taxon->sample->Y
				my %X;#HoHoH kegg->taxon->sample->X
				my %total_counts;#hash taxon->total summed up number of reads
				my %all_taxa;#hash to store all taxa present in this sample/tax_interest_level-Combi
				foreach my $kegg_nr (@kegg){
					foreach my $tmp_taxon1 (keys %{ $total_table{$samples[$i]}{$tax_interest}{$kegg_nr} }){
						$X{$kegg_nr}{$tmp_taxon1}{$samples[$i]}+=$total_table{$samples[$i]}{$tax_interest}{$kegg_nr}{$tmp_taxon1};
						$all_taxa{$tmp_taxon1}++;
						$total_counts{$tmp_taxon1}+=$total_table{$samples[$i]}{$tax_interest}{$kegg_nr}{$tmp_taxon1};
					}
					foreach my $tmp_taxon2 (keys %{ $total_table{$samples[$j]}{$tax_interest}{$kegg_nr} }){
						$Y{$kegg_nr}{$tmp_taxon2}{$samples[$j]}+=$total_table{$samples[$j]}{$tax_interest}{$kegg_nr}{$tmp_taxon2};
						$all_taxa{$tmp_taxon2}++;
						$total_counts{$tmp_taxon2}+=$total_table{$samples[$j]}{$tax_interest}{$kegg_nr}{$tmp_taxon2};
					}
				}
##################################################################################
#
#		Calculation and Output
#
#

				my %TFC_XminusY;#H taxon->sum(X-Y)
				my $FC_XminusY = 0;# sum(X-Y) for FC 
				my %TFC_XplusY;#H taxon->sum(X+Y)
				my $FC_XplusY = 0;#sum(X+Y ) for FC
				my @tmp_taxa = keys %all_taxa;
				my $FC_X;
				my $FC_Y;
				foreach my $kegg_nr (@kegg){
					$FC_X=0;
					$FC_Y=0;
					foreach my $tmp_taxon (@tmp_taxa){
						my $tmp_x;
						my $tmp_y;
						if (exists $X{$kegg_nr}{$tmp_taxon}{$samples[$i]}){
							$tmp_x=$X{$kegg_nr}{$tmp_taxon}{$samples[$i]};
						}
						else{
							$tmp_x=0;
						}
						if (exists $Y{$kegg_nr}{$tmp_taxon}{$samples[$j]}){
							$tmp_y=$Y{$kegg_nr}{$tmp_taxon}{$samples[$j]};
						}
						else{
							$tmp_y=0;
						}
	
						$TFC_XminusY{$tmp_taxon}+=abs($tmp_x - $tmp_y);
						$FC_X+=$tmp_x;
						$FC_Y+=$tmp_y;
						$TFC_XplusY{$tmp_taxon}+=$tmp_x + $tmp_y;
					}
					$FC_XplusY+=$FC_X+$FC_Y;
					$FC_XminusY+=abs($FC_X - $FC_Y);
				}
				my $FC;
				my $TFC = 0;
				my $FR;
				my @tmp_taxa3 = keys %all_taxa;
				foreach my $tmp_taxon3 (@tmp_taxa3){
					if ($TFC_XplusY{$tmp_taxon3} != 0){
						$TFC+=($TFC_XplusY{$tmp_taxon3}/$FC_XplusY)*($TFC_XminusY{$tmp_taxon3}/$TFC_XplusY{$tmp_taxon3});
					}
				}
				$FC=$FC_XminusY/$FC_XplusY;
				$FR=$TFC-$FC;
				print OUT $tax_level_names{$tax_interest},"\t",(sprintf("%.6f",$TFC)),"\t",(sprintf("%.6f",$FC)),"\t",(sprintf("%.6f", abs($FR))),"\n";
			}
		}
	}
}
close (OUT);
