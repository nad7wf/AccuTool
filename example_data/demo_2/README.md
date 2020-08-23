# Demo 2

## Description

The USDA Soybean Germplasm Collection contains over 20,000 soybean accessions have been genotyped using the SNP50k array, however, the ability to identify accessions containing a causal mutation for a gene of interest is dependent on choosing a marker with high selection accuracy. This tutorial illustrates how the AccuTool can be used to identify the best proxy SNP for a causal mutation from among the SNP50k marker set.

## Instructions

Download and unzip the _demo_2_input_files.zip_ folder. You can open the example statistics file derived from running MLM-GWAS to get a sense of the format:
```
Chr	Pos		P-val
13	16500223	0.74386
13	16500375	0.81042
13	16500740	0.66233
13	16500747	0.66666
13	16500844	0.96345
```
With this input file downloaded, click [here](http://soykb.org/Accuracy) to navigate to the AccuTool.

In the _Menu_ tab, specify the following inputs, leaving all others as default:
```
Chromosome:				13
Genomic interval: 			16500000 to 19500000
Reference Phenotype:	 		MUT
Chromosome of tagging variant:		13
Position of tagging variant:		17316756
Choose GWAS Statistics File (.csv): 	Flower_color_GWAS_statistics.csv
Return only SNP50k positions: 		Yes
```
Here, in place of a tagging variant, we specify the position of the causal mutation (or in this case, a near-perfect proxy to the causal mutation - see [publication](../../README.md#citation) for details). This modification allows us to calculate the accuracy of each SNP50k marker in the region against the causal mutation. 

Click the _Calculate Accuracy_ button. After processing, you will see a table in the _Results_ tab with 18 columns of information (see [Documentation](../../README.md#output-fields) for a description of the information contained in each column). This table can be sorted according to any column by clicking on the column header, once to sort in ascending order, twice for descending. Double-clicking the Avg_Accuracy column header will sort the table by descending accuracy values and place the best proxy SNP for the flower color causal mutation (ss715616657) at the top.
```
Chr	Pos		Avg_Accuracy (%)	Comb_Accu_Pess (%)	p.value		SoySNP50k_ID	Gene		Effect				WT_Accu (%)	Num_of_WT_Lines	Missing_Genotype_WT (%)	MUT_Accu (%)	Num_of_MUT_Lines	Missing_Genotype_MUT (%)	Missing_Phenotype (%)	Multiple_ALT	REF	ALT
13	17309969	96.6			88			1.52E-09	ss715616657	.		C|intergenic_region		93.9		468		1.7			99.2		257			1.9				6.5					T	C
13	17307263	96.4			86.6			1.03E-09	ss715616658	Glyma.13g072000	C|downstream_gene_variant	93.6		468		3			99.2		257			3.5				6.5					A	C
13	18046553	92			82.3			0.02716		ss715616090	Glyma.13g076400	C|intron_variant		88.4		468		2.6			95.5		257			4.3				6.5					A	C
13	18327972	92			84.1			0.54678		ss715615785	Glyma.13g077600	A|downstream_gene_variant	89.6		468		1.1			94.4		257			2.3				6.5					G	A
```
Sorting the same results table instead by the GWAS-derived p.value column reveals that in fact the SNP50k marker with the best p.value (ss715616654) has poor accuracy values. In this case, using the GWAS-derived tagging SNP to identify accessions containing the causal mutation would result in poorer selection accuracy than using the proxy SNP with the highest accuracy value.
```
Chr	Pos		Avg_Accuracy (%)	Comb_Accu_Pess (%)	p.value		SoySNP50k_ID	Gene		Effect				WT_Accu (%)	Num_of_WT_Lines	Missing_Genotype_WT (%)	MUT_Accu (%)	Num_of_MUT_Lines	Missing_Genotype_MUT (%)	Missing_Phenotype (%)	Multiple_ALT	REF	ALT
13	17316431	67.2			53.3			1.34E-22	ss715616654	Glyma.13g072100	A|synonymous_variant|P353P	34.4		468		1.3			100		257			1.2				6.5					C	A
13	17307263	96.4			86.6			1.03E-09	ss715616658	Glyma.13g072000	C|downstream_gene_variant	93.6		468		3			99.2		257			3.5				6.5					A	C
13	17309969	96.6			88			1.52E-09	ss715616657	.		C|intergenic_region		93.9		468		1.7			99.2		257			1.9				6.5					T	C
13	16757016	68.8			71.4			2.55E-05	ss715616744	Glyma.13g067700	C|synonymous_variant|L102L	97.8		468		0.9			39.8		257			3.1				6.5					T	C
```
These results can be downloaded by navigating back to the _Menu_ tab and clicking the _Download Results_ button.
