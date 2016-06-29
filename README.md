# FuncRed
Quantify expressed redundancy of multiple functions between microbial communities

##Input file format
A tab-delimited text file with 9 columns (the first 7 for the taxonomy from species up to phylum, Function (KEGG KO), Sample/Replicate-ID, Sample-group), for example:

	Marinomonas ushuaiensis	Marinomonas	Oceanospirillaceae	Oceanospirillales	Gammaproteobacteria	Proteobacteria	Bacteria	K02954	Bb3 	 Bb
	Tenacibaculum mesophilum	Tenacibaculum	Flavobacteriaceae	Flavobacteriales	Flavobacteriia	Bacteroidetes	Bacteria	K04043	Fb2 	 Fb
	Polaribacter dokdonensis	Polaribacter	Flavobacteriaceae	Flavobacteriales	Flavobacteriia	Bacteroidetes	Bacteria	K03648	Mb1 	 Mb
	Marinomonas sp. MWYL1	Marinomonas	Oceanospirillaceae	Oceanospirillales	Gammaproteobacteria	Proteobacteria	Bacteria	K01869	Fb3 	 Fb
	Marinomonas sp. MWYL1	Marinomonas	Oceanospirillaceae	Oceanospirillales	Gammaproteobacteria	Proteobacteria	Bacteria	K03583	Bb2 	 Bb
	Psychroserpens mesophilus	Psychroserpens	Flavobacteriaceae	Flavobacteriales	Flavobacteriia	Bacteroidetes	Bacteria	K03043	Mb3 	 Mb

##Subsampling
To randomly get equal numbers of reads/entries/"individuals" for each sample/replicate use 

	shuf original_input_file.txt > shuffled_input_file.txt
(for Mac OS X you'll need to install coreutils via "brew install coreutils" or "sudo port install coreutils" and run gshuf instead)

and then 

	subsample.pl shuffled_input_file.txt subsampled_shuffled_input_file.txt

##Usage
FunctionalRedundancy.pl input_file output_file tax_levels_of_interest 

	Example:
	
	FunctionalRedundancy.pl subsampled_shuffled_input_file.txt Myoutput 1 2 3 4
	
	writes Myoutput taking subsampled_shuffled_input_file.txt as input calculating FR on genus, family, order and class level (1,2,3,4)


