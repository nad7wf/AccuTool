# Demo 1

## Description

This demo shows how the AccuTool can be used to select the Tagging SNP with the strongest association to a real phenotype. To illustrate this, we use phenotype data for early pod shatter downloaded from the Germplasm Resources Information Network (GRIN). By design, the AccuTool does not account for population structure, so this analysis should only be performed on the set of SNPs contained within a phenotype-associated region identified from a MLM-GWAS. 

## Instructions

Download and unzip the _demo_1_input_files.zip_ folder. If you open the example phenotype file in Excel, you should see the following format:
```
PI			Pheno
ZJ-Y314			NA
PI_578357		NA
PI_366120		NA
PI_562565		NA
PI_339871A		NA
HN022_PI404198B		2
HN023_PI424608A		2
HN037_PI200508		1
HN038_PI248515		1
HN054_PI437169B		2
HN056_PI437863A		2
HN057_PI438258		2
```
The first column corresponds to the line name for each of the Soy775 accessions, and the second column is the phenotype designation of each line, where _1_ is Wild-type, _2_ is Mutant, and _NA_ is for any line where the phenotype status is unknown. The AccuTool currently only supports a binary phenotype designation.

Similarly, you can view the example statistics file derived from running MLM-GWAS to get a sense of the format:
```
Chr	Pos	P-val
1	24952	0.977590557
1	26003	0.718829728
1	29671	0.450812625
1	30712	0.49116528
1	37018	0.079049794
1	38482	0.834196223
```
You will notice that this file contains all the SNP50k markers for the entire genome, regardless of their association to the phenotype. This is fine, as the AccuTool will filter these positions based on the genomic interval you specify in the input menu.

With these input files downloaded, click [here](http://soykb.org/Accuracy) to navigate to the AccuTool.

In the _Menu_ tab, specify the following inputs, leaving all others as default:
```
Chromosome: 				16
Genomic interval: 			29680000 to 30100000
Reference Phenotype: 			MUT
Choose Phenotype File (.csv): 		Pdh1_phenotype.csv
Choos GWAS Statistics File (.csv): 	Pdh1_GWAS_statistics.csv
Return only SNP50k positions: 		Yes
```
Click the _Calculate Accuracy_ button. After processing, you will see a table in the _Results_ tab with 18 columns of information (see [Documentation](../../README.md#-output-fields) for an explanation of the columns). This table can be sorted according to any column by clicking on the column header, once to sort in ascending order, twice for descending. Double-clicking the _Avg_Accuracy_ column header will sort the table by descending accuracy values and place the best Tagging SNP for early pod shatter (ss715624199) at the top.
```
Chr	Pos		Avg_Accuracy (%)	Comb_Accu_Pess (%)	p.value		SoySNP50k_ID	Gene		Effect				WT_Accu (%)	Num_of_WT_Lines	Missing_Genotype_WT (%)	MUT_Accu (%)	Num_of_MUT_Lines	Missing_Genotype_MUT (%)	Missing_Phenotype (%)	Multiple_ALT	REF	ALT
16	29940504	88.2			20.6			1.21E-07	ss715624199	Glyma.16g141300	G|downstream_gene_variant	87.5		8		0			89		176			2.3				76.3					A	G
16	30009486	87.7			20.6			1.63E-05	ss715624201	Glyma.16g141700	C|downstream_gene_variant	87.5		8		0			87.9		176			1.1				76.3					T	C
16	30059279	87.2			20.4			2.66E-05	ss715624207	.		G|intergenic_region		87.5		8		0			86.8		176			1.1				76.3					A	G
16	29870849	87			20.1			1.12E-04	ss715624192	Glyma.16g141000	C|synonymous_variant|R229R	87.5		8		0			86.6		176			2.3				76.3					T	C
```
These results can be downloaded by navigating back to the _Menu_ tab and clicking the _Download Results_ button.
