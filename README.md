# AccuTool

## Introduction

A causal mutation conferring phenotypic variation and its tagging variant, detected in a genome-wide association study (GWAS), are related through a common founder effect. This relationship can be exploited to facilitate candidate gene identification by defining the set of mutations in strong association with the tagging variant. Our team has created the AccuTool to enable researchers to perform this post-GWAS analysis without the need for any bioinformatics or computer programming knowledge.

## Description

The AccuTool is a web-based tool used to explore the landscape of association between a single genomic position (or phenotype) and whole genome sequence (WGS)-derived variant positions within a user-defined region of a chromosome. The tool calculates this association based on a panel of 775 genetically-diverse, publicly available resequenced soybean accessions, which have been remapped to the Wm82.a2.v1 reference genome. This measure of association between the tagging variant and any given WGS variant (a parameter we call "Accuracy") is the percentage of total lines with either the Wild-type (WT) or Mutant (MUT) haplotype at these two positions. See [Output fields](#output-fields) below for a brief description of the different Accuracy parameters, or the [publication](#citation) for a more in-depth description.

The AccuTool is available at: http://soykb.org/AccuTool. Demo data files and step-by-step instructions are available by clicking on _example_data_ above.

## Web Interface

The AccuTool has a simple-to-use interface containing two tabs: a _Menu_ tab where the user specifies input parameters, and the _Results_ tab where the output is displayed. The user does not need to provide any genomic data - all genomic data for the Soy775 accession panel is already contained on the web server.

### Required input
* Chromosome number of the desired genomic interval
* Start and end coordinates of the genomic interval
* Specify whether the reference genome should be considered WT or MUT
* A _.csv_ file of phenotype assignments for some or all of the Soy775 accession panel
<br>_OR_<br>  
* The chromosome and genomic position of a tagging variant

### Optional input
* A _.csv_ file of p-values derived from the output of GWAS
* A range of Accuracy values with which to filter genomic positions
* Option to return only those positions with a user-supplied p-value
* Option to return only the amino acid-modifying variants (i.e. those variants predicted to cause an amino acid change in a gene product)
* Option to return only the SNP50k positions

Once all desired inputs have been provided, click the _Calculate Accuracy_ button. This will expand the _Results_ tab, where, once processed, a table of the relevant WGS variants and their results will be displayed. These results can be downloaded as a tab-delimited text file by clicking the _Download Results_ button in the _Menu_ tab.

### Output fields
* __Chr:__ chromosome of genomic position
* __Pos:__ genomic position
* __Avg_Accuracy:__ mean of the WT_Accu and MUT_Accu values (see WT_Accu and MUT_Accu below for description)
* __Comb_Accu_Pess:__ percentage of total lines with either WT or MUT haplotypes (any line with missing data is considered recombinant/not a match)
* __p.value:__ user-supplied p-value (where applicable)
* __SoySNP50k_ID:__ SNP50k ID number of the position (where applicable)
* __Gene:__ Glyma model that the variant impacts (where applicable)
* __Effect:__ Impact of variant, as predicted by SNPEff software
* __WT_Accu:__ percentage of WT lines with the correct WT haplotype (or phenotype-genotype association)
* __Num_of_WT_Lines:__ number of lines with the WT allele of the tagging variant (or WT phenotype)
* __Missing_Genotype_WT:__ percentage of WT lines with missing genotype data at that position
* __MUT_Accu:__ percentage of MUT lines with the correct MUT haplotype (or phenotype-genotype association)
* __Num_of_MUT_Lines:__ number of lines with the MUT allele of the tagging variant (or MUT phenotype)
* __Missing_Genotype_MUT:__ percentage of MUT lines with missing genotype data at that position
* __Missing_Phenotype:__ percentage of total lines with missing data for the tagging variant (or missing a phenotype assignment)
* __Multiple_ALT:__ an asterisk indicates that this genomic position has multiple alternate alleles (one allele per table row)
* __REF:__ genomic sequence of the reference allele
* __ALT:__ genomic sequence of the alternate allele

## Software and Data Development

The AccuTool was developed using [Perl](https://www.perl.org/), [R](https://www.r-project.org/about.html), and [R Shiny](https://shiny.rstudio.com/). Variant calling for the Soy775 accession panel was performed using the [PGen](http://soykb.org/Pegasus/) workflow and the [Wm82.a2.v1](https://phytozome.jgi.doe.gov/pz/portal.html#!info?alias=Org_Gmax) reference genome, and predicted variant effects were obtained using [SNPEff](https://pcingola.github.io/SnpEff/). VCF data for the full Soy775 accession panel can be downloaded by clicking [here](https://de.cyverse.org/dl/d/BA00FC63-C844-4FD3-BDF9-581EB11642A2/Soy775.vcf.gz).

## Citation

If you use the AccuTool in your research, please cite:```include paper citation here```
