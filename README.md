# AccuTool

### Introduction

A causal mutation conferring phenotypic variation and its tagging variant, detected in a genome-wide association study (GWAS), are related through a common founder effect. This relationship can be exploited to facilitate candidate gene identification by defining the set of mutations in strong association with the tagging variant. Our lab has created the AccuTool to enable researchers to perform this post-GWAS analysis without the need for any bioinformatic or computer programming knowledge.

### Description

The AccuTool is a web-based tool used to explore the landscape of association between a single genomic position (or phenotype) and whole genome sequence (WGS)-derived variant positions within a user-defined region of a chromosome. The tool calculates this association based on a panel of 775 genetically-diverse, publicly available resequenced soybean accessions, which have been remapped to the Wm82.a2.v1 reference genome. This measure of association (aka "Accuracy") between the tagging variant and any given WGS variant is the percentage of total lines with either the reference or alternate haplotype at these two positions. Please see "Output fields" below for a brief description of the different Accuracy parameters, or the publication for a more in-depth description.

The AccuTool is available at: http://soykb.org/Accuracy.

### Instructions for Use

The AccuTool has a simple-to-use interface containing two tabs: a "Menu" tab where the user specifies input parameters, and the "Results" tab where the output is displayed. The user does not need to provide any genomic data - all genomic data for the Soy775 accession panel is already contained on the web server.

Required input:
* Chromosome number of the genomic interval
* Start and end coordinates of the genomic interval
* Specify whether the Reference genome should be considered Wild-type (WT) or Mutant (Mut)
* A .csv file of phenotype assignments for some or all of the Soy775 accession panel (see "Example_Data" for template)
<br>OR<br>  
* The chromosome and genomic position of a tagging variant

Optional input:
* A file of p-values derived from the output of GWAS (see "Example_Data" for template)
* A range of Accuracy values with which to filter genomic positions
* A range of p-values with which to filter genomic positions
* Option to show only those positions with a p-value
* Option to show only the "high impact" variants (i.e. those variants predicted to cause an amino acid change in a gene product)
* Option to show only the SNP50k positions

Once all desired inputs have been provided, click the "Calculate Accuracy" button. This will expand the "Results" tab, where, once processed, a table of the relevant genomic positions and their results will be displayed.

Output fields:
* Chr: chromosome of genomic position
* Pos: genomic position
* Avg_Accu_Real: mean of the WT_Accu and MUT_Accu values
* Comb_Accu_Pess: percentage of total lines with either reference or alternate haplotypes (any line with missing data is considered recombinant/not a match)
* p.value: user-supplied p-value (where applicable)
* SoySNP50k_ID: SNP50k ss###### ID number of the position (where applicable)
* Gene: Glyma model that the position falls within or around (where applicable)
* Effect: Impact of variant, as determined by SNPEff software.
* WT_Accu: percentage of WT lines with the correct WT haplotype (or phenotype-genotype association)
* Num_of_WT_Lines: number of lines with the WT allele of the tagging variant (or WT phenotype)
* Missing_Genotype_WT: percentage of WT lines with missing genotype data at that position
* MUT_Accu: percentage of MUT lines with the correct MUT haplotype (or phenotype-genotype association)
* Num_of_MUT_Lines: number of lines with the MUT allele of the tagging variant (or MUT phenotype)
* Missing_Genotype_MUT: percentage of MUT lines with missing genotype data at that position
* Missing_Phenotype: percentage of total lines with missing data for the tagging variant (or missing a phenotype assignment)
* Multiple_ALT: an asterisk indicates that this genomic position has multiple alternate alleles (one allele per table row)
* REF: genomic sequence of the reference genome
* ALT: genomic sequence of the alternate
