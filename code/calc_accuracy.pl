#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;
use Scalar::Util qw(looks_like_number);

### This script takes a VCF file, a phenotype assignment file, a statistics file outputted from GWAS, and a file of script parameters, and calculates variant "accuracy" with respect to the phenotype.


### Capture script paramenters from input file.
my $geno_file = shift @ARGV;
my $pheno_geno_file = shift @ARGV;
my $pheno_file = shift @ARGV;
my $pos_start = shift @ARGV;
my $pos_end = shift @ARGV;
my $ref_pheno = shift @ARGV;
my $avg_acc_start = shift @ARGV;
my $avg_acc_end = shift @ARGV;
my $pess_acc_start = shift @ARGV;
my $pess_acc_end = shift @ARGV;
my $wt_acc_start = shift @ARGV;
my $wt_acc_end = shift @ARGV;
my $mut_acc_start = shift @ARGV;
my $mut_acc_end = shift @ARGV;
my $only_p = shift @ARGV;
my $only_mod = shift @ARGV;
my $only_snp50k = shift @ARGV;
my $stats_file;

if (scalar @ARGV > 0) {
	$stats_file = shift @ARGV;
}

### Generate phenotype hash.
my %pheno_hash;

### Capture number of lines with each phenotype for accuracy calculations later.
my $wt_allele_counter = 0;
my $mut_allele_counter = 0;
my $total_allele_counter = 0;
my $missing_pheno_counter = 0;


### Capture phenotype assignment from input phenotype file.
if ($pheno_file =~ /\.csv/) {

	open (my $pheno_handle, '<', "$pheno_file") or die $!;
	my $dummy1 = <$pheno_handle>;
	
	while (<$pheno_handle>) {
		$_ =~ s/\r//g;
	        chomp(my @row = split(/,/, $_));
	
		if ($row[1] ne 'NA') {
			$pheno_hash{$row[0]} = $row[1];
			if ($row[1] == 1) {
				$wt_allele_counter++;
				$total_allele_counter++;
			} elsif ($row[1] == 2) {
				$mut_allele_counter++;
				$total_allele_counter++;
			}
		} elsif ($row[1] eq 'NA') {
			$missing_pheno_counter++;
		}
	}
	
	close $pheno_handle;

### If tagging SNP is provided, generate phenotype from genotype position.
} elsif (looks_like_number($pheno_file)) {

	open (my $geno_handle, '-|', "gzip -dc $pheno_geno_file | awk -F '\t' '\$2 == $pheno_file' | (gzip -dc $pheno_geno_file | head -1; cat -)") or die $!;
	chomp(my @pheno_header = split(/\t/, <$geno_handle>));
	chomp(my @pheno_pos_row = split(/\t/, <$geno_handle>));
	close $geno_handle;
	
	### Check if tagging variant exists in Soy775 file.
	if (!defined @pheno_pos_row) {
		print "Tagging variant does not exist in Soy775 accession panel!\n";
		exit;
	}

	for (my $ii = 9; $ii < @pheno_pos_row; $ii++) {
		if ($pheno_pos_row[$ii] =~ /^([\d\.])/) {
			$pheno_pos_row[$ii] = $1;
		}

		if (looks_like_number($pheno_pos_row[$ii])) {
			if ($ref_pheno == 1) {
				if ($pheno_pos_row[$ii] == 0) {
					$pheno_pos_row[$ii] = 1;
					$wt_allele_counter++;
					$total_allele_counter++;
				} elsif ($pheno_pos_row[$ii] != 0) {
					$pheno_pos_row[$ii] = 2;
					$mut_allele_counter++;
					$total_allele_counter++;
				}
			} elsif ($ref_pheno == 2) {
				if ($pheno_pos_row[$ii] == 0) {
					$pheno_pos_row[$ii] = 2;
					$mut_allele_counter++;
					$total_allele_counter++;
				} elsif ($pheno_pos_row[$ii] != 0) {
					$pheno_pos_row[$ii] = 1;
					$wt_allele_counter++;
					$total_allele_counter++;
				}
			}
			$pheno_hash{$pheno_header[$ii]} = $pheno_pos_row[$ii];
		} elsif ($pheno_pos_row[$ii] =~ /^\./) {
			$missing_pheno_counter++;
		}
	}
}

### Capture p-values from input statistics file.
my %stats_hash;
if (defined $stats_file) {
	open (my $stats_handle, '<', "$stats_file") or die $!;
	my $dummy1 = <$stats_handle>;
	while (<$stats_handle>) {
		$_ =~ s/\r//g;
	        chomp(my @row = split(/,/, $_));	
	        $stats_hash{$row[0]}{$row[1]} = $row[2];
	}
	close $stats_handle;
}

### Read in SNP50k IDs for selected chromosome.
my $chr_num;
if ($geno_file =~ /Chr(\d{2})/) {
	$chr_num = $1;
}

my %snp_id_hash;
open (my $snpid_handle, '-|', "awk -F '\t' '\$1 == $chr_num' SNP50k_IDs.txt") or die $!;
while (<$snpid_handle>) {
	chomp(my @row = split(/\t/, $_));
	$snp_id_hash{$row[0]}{$row[1]} = $row[2];
}

### Define single-letter amino acid code.
my %aa = (
	"Gly" => "G",
	"Ala" => "A",
	"Leu" => "L",
	"Met" => "M",
	"Phe" => "F",
	"Trp" => "W",
	"Lys" => "K",
	"Gln" => "Q",
	"Glu" => "E",
	"Ser" => "S",
	"Pro" => "P",
	"Val" => "V",
	"Ile" => "I",
	"Cys" => "C",
	"Tyr" => "Y",
	"His" => "H",
	"Arg" => "R",
	"Asn" => "N",
	"Asp" => "D",
	"Thr" => "T"
);

### Parse VCF file and output accuracy calculations.
open (my $vcf_handle, '-|', "gzip -dc $geno_file | awk -F '\t' '\$2 >= $pos_start && \$2 <= $pos_end' | (gzip -dc $geno_file | head -1; cat -)") or die $!;

### Capture total line number in genotype file for calculating combined pessemissitic accuracy later.
my $total_line_counter = 0;

### Capture VCF header position information.
chomp(my @header = split(/\t/, <$vcf_handle>));
for (my $ii = 9; $ii < @header; $ii++) {
	$total_line_counter++;
	if (exists $pheno_hash{$header[$ii]}) {
        	$pheno_hash{$ii} = delete $pheno_hash{$header[$ii]};
	}
}

### Loop through VCF file, capture SNPEff output, and perform accuracy calculations.
print join("\t", ('Chr', 'Pos', 'Avg_Accuracy (%)', 'Comb_Accu_Pess (%)', 'p.value', 'SoySNP50k_ID', 'Gene', 'Effect', 'WT_Accu (%)', 'Num_of_WT_Lines', 'Missing_Genotype_WT (%)', 'MUT_Accu (%)', 'Num_of_MUT_Lines', 'Missing_Genotype_MUT (%)', 'Missing_Phenotype (%)', 'Multiple_ALT', 'REF', 'ALT')), "\n";


LOOP: while (<$vcf_handle>) {
	chomp(my @row = split(/\t/, $_));
	
	my $pval;
	if (exists $stats_hash{$row[0]}{$row[1]}) {
		$pval = $stats_hash{$row[0]}{$row[1]};
	} else {
		$pval = 'NA';
	}

	my $snp50k_id;
	if (exists $snp_id_hash{$row[0]}{$row[1]}) {
		$snp50k_id = $snp_id_hash{$row[0]}{$row[1]};
	} else {
		$snp50k_id = '.';
	}

	### Skip if "Show only SNP50k positions" is 'yes' and position is not a 50k position.
	next if ($only_snp50k eq 'Yes' && $snp50k_id eq '.');
	
	### Capture alt allele order.
	my %alt;
	my @alt_alleles = split(/,/, $row[4]);
	unshift @alt_alleles, $row[3];
	
	for (my $ii = 1; $ii < @alt_alleles; $ii++) {
		$alt{$ii}{$alt_alleles[$ii]} = undef;
	}

	### Capture effect info.
	$row[7] =~ s/ANN=//;
	my @info_fields = split(/,/, $row[7]);
	
	foreach my $info_subfield (@info_fields) {
		my @ann_field = split(/\|/, $info_subfield);

		### If <DEL> allele was not properly annotated by SNPEff, insert "N/A" placeholder.
		if (! defined $ann_field[6]) {
			foreach my $allele_num (keys %alt) {
				if (exists $alt{$allele_num}{'<DEL>'}) {
					my $fixed_effect = join("|", ('<DEL>', "NA"));
					$alt{$allele_num}{'<DEL>'} = $fixed_effect;
				}
			}
		} elsif ($ann_field[1] =~ /(chromosome|duplication|inversion|inframe_insertion|disruptive_inframe_insertion|inframe_deletion|disruptive_inframe_deletion|exon_loss_variant|frameshift_variant|feature_ablation|duplication|gene_fusion|bidirectional_gene_fusion|rearranged_at_DNA_level|missense_variant|protein_protein_contact|structural_interaction_variant|rare_amino_acid_variant|splice_acceptor_variant|splice_donor_variant|stop_lost|start_lost|stop_gained|upstream_gene_variant|downstream_gene_variant|3_prime_UTR_variant|5_prime_UTR_variant|intron_variant|synonymous_variant)/) {
			
			my $gene;
			if ($ann_field[4] =~ /(Glyma\.\d+g\d+)/) {
				$gene = $1;
			}
			my $var = $ann_field[0];
			my $effect = $ann_field[1];
			
			foreach my $allele_num (keys %alt) {
				if ((exists $alt{$allele_num}{$var} && !defined $alt{$allele_num}{$var}) 
					|| (exists $alt{$allele_num}{$var} && !defined $alt{$allele_num}{$var})) {
					
					### If mutation causes an amino acid change, capture that change in the effect output.
					if (defined $ann_field[10] && $ann_field[10] =~ /p\.([A-Z]{3})(\d+)([A-Z]{3})/i) {
						
						my $aa_1 = $1;
						my $aa_pos = $2;
						my $aa_2 = $3;
						$aa_1 = $aa{$aa_1} if exists $aa{$aa_1};
						$aa_2 = $aa{$aa_2} if exists $aa{$aa_2};
						my $aa_change = $aa_1 . $aa_pos . $aa_2;
						
						if (exists $alt{$allele_num}{$var}) {
							my $fixed_effect = join("|", ($var, $effect, $aa_change, $gene));
							$alt{$allele_num}{$var} = $fixed_effect;
						}
					}

					### Otherwise leave the amino acid change out.
					else {
						if (exists $alt{$allele_num}{$var}) {
							my $fixed_effect = join("|", ($var, $effect, $gene));
							$alt{$allele_num}{$var} = $fixed_effect;
						}
					}
				}
			}
		}

		### If higher impact annotation already exists in %alt for a given variant allele, don't overwrite with a lower impact annotation.
		else {

			### Add non-genic effects to %alt.
			foreach my $allele_num (keys %alt) {
				if (exists $alt{$allele_num}{$ann_field[0]} && !defined $alt{$allele_num}{$ann_field[0]}) {
					my $var = $ann_field[0];
					my $effect = $ann_field[1];
					my $fixed_effect = join("|", ($var, $effect));
					$alt{$allele_num}{$var} = $fixed_effect;
				}
			}
		}
	}

	### Join variant effects in corrected order.
	my @combined_effects;
	foreach my $allele_num (sort {$a <=> $b} keys %alt) {
		foreach my $var (keys %{$alt{$allele_num}}) {
			if (defined $alt{$allele_num}{$var}) {

				### Throw out any nonmodifying variants if filter for modifying variants is set to 'Yes.'
				if ($only_mod eq 'Yes' && $alt{$allele_num}{$var} !~ /(chromosome|duplication|inversion|inframe_insertion|disruptive_inframe_insertion|inframe_deletion|disruptive_inframe_deletion|exon_loss_variant|frameshift_variant|feature_ablation|duplication|gene_fusion|bidirectional_gene_fusion|rearranged_at_DNA_level|missense_variant|protein_protein_contact|structural_interaction_variant|rare_amino_acid_variant|splice_acceptor_variant|splice_donor_variant|stop_lost|start_lost|stop_gained)/) {
					next LOOP;
				} else {
					push @combined_effects, $alt{$allele_num}{$var};
				}
			}
		}
	}
	
	$row[7] = join(",", @combined_effects);

	### Calculate phenotype accuracy.
	my %geno_pheno;
	my @row_alleles = split(/,/, $row[4]);
	$geno_pheno{$row[3]} = $ref_pheno;
	
	if ($ref_pheno == 1) {
		foreach my $row_allele (@row_alleles) {
			$geno_pheno{$row_allele} = 2;
		}
	} elsif ($ref_pheno == 2) {
		foreach my $row_allele (@row_alleles) {
			$geno_pheno{$row_allele} = 1;
		}
	}

	### Calculate geno/pheno accuracy.
	my $wt_acc_counter = 0;
	my $missing_wt_counter = 0;
	my $mut_acc_counter = 0;
	my $missing_mut_counter = 0;
	my $total_acc_counter = 0;
	my $total_missing_counter = 0;

	for (my $ii = 9; $ii < @row; $ii++) {
		if (exists $pheno_hash{$ii}) {
			if ($row[$ii] =~ /^(\d)/) {
				my $var_num = $1;

				### When ref geno matches ref pheno and ref is WT.
				if ($var_num == 0 && $pheno_hash{$ii} == $ref_pheno && $ref_pheno == 1) {
					$wt_acc_counter++;
					$total_acc_counter++;

				### When ref geno matches ref pheno and ref is Mut.
				} elsif ($var_num == 0 && $pheno_hash{$ii} == $ref_pheno && $ref_pheno == 2) {
					$mut_acc_counter++;
					$total_acc_counter++;

				### When alt geno matches alt pheno and alt is Mut (ref is WT).
				} elsif ($var_num != 0 && $pheno_hash{$ii} != $ref_pheno && $ref_pheno == 1) {
					$mut_acc_counter++;
					$total_acc_counter++;

				### When alt geno matches alt pheno and alt is WT (ref is Mut).
				} elsif ($var_num != 0 && $pheno_hash{$ii} != $ref_pheno && $ref_pheno == 2) {
					$wt_acc_counter++;
					$total_acc_counter++;

				}
			} elsif ($row[$ii] =~ /^(\.)/) {
				my $var_num = $1;

				### When pheno is WT but geno is missing.
				if ($var_num eq '.' && $pheno_hash{$ii} == 1) {
					$missing_wt_counter++;
					$total_missing_counter++;

				### When pheno is Mut but geno is missing.
				} elsif ($var_num eq '.' && $pheno_hash{$ii} == 2) {
					$missing_mut_counter++;
					$total_missing_counter++;
				}
			}
		}
	}

	### Calculate accuracy values.
	my $wt_acc;
	my $mut_acc;
	my $total_pess_acc;

	if ($wt_allele_counter == $missing_wt_counter) {
		$wt_acc = 0;
	} else {
		$wt_acc = sprintf "%.1f", (($wt_acc_counter / ($wt_allele_counter - $missing_wt_counter)) * 100);
	}

	if ($mut_allele_counter == $missing_mut_counter) {
		$mut_acc = 0;
	} else {
		$mut_acc = sprintf "%.1f", (($mut_acc_counter / ($mut_allele_counter - $missing_mut_counter)) * 100);
	}

	if ($total_allele_counter == $total_missing_counter) {
		$total_pess_acc = 0;
	} else {
		$total_pess_acc = sprintf "%.1f", (($total_acc_counter / $total_line_counter) * 100);
	}
	
	my $avg_acc = sprintf "%.1f", (($wt_acc + $mut_acc) / 2);
	my $missing_pheno_perc = sprintf "%.1f", (($missing_pheno_counter / ($missing_pheno_counter + $total_allele_counter)) * 100);
	my $missing_wt_perc = sprintf "%.1f", (($missing_wt_counter / $wt_allele_counter) * 100);
	my $missing_mut_perc = sprintf "%.1f", (($missing_mut_counter / $mut_allele_counter) * 100);

	### If all accuracy calculations are within filter range, print position to output file.
	if (($avg_acc >= $avg_acc_start && $avg_acc <= $avg_acc_end)
		&& ($wt_acc >= $wt_acc_start && $wt_acc <= $wt_acc_end)
		&& ($mut_acc >= $mut_acc_start && $mut_acc <= $mut_acc_end)
		&& ($total_pess_acc >= $pess_acc_start && $total_pess_acc <= $pess_acc_end)) {

		### Generate final output row.
		$row[2] =~ s/\./ /;
		@row = (@row[0, 1], $avg_acc, $total_pess_acc, $pval, $snp50k_id, $row[7], $wt_acc, $wt_allele_counter, $missing_wt_perc, $mut_acc, $mut_allele_counter, $missing_mut_perc, $missing_pheno_perc, $row[2], @row[3, 4]);

		### Strip Glyma name off of INFO column and create a GENE column.
		if ($row[6] =~ /(Glyma\.\d+g\d+)/) {
			my $gene = $1;
			my $link = '<a href=\'https://www.soybase.org/sbt/search/search_results.php?category=FeatureName&version=Glyma2.0&search_term=' . $gene . '\', target=\'_blank\'>' . $gene . '</a>';
			$row[6] =~ s/\|$gene//g;
			splice @row, 6, 0, $link;
		} else {
			splice @row, 6, 0, '.';
		}

		### Print corrected line to stdout.
		print join("\t", @row), "\n";
	}
}

close $vcf_handle;
exit;
