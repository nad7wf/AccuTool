# Demo 1

### Description

This demo shows the user how to use the AccuTool to select the Tagging SNP with the strongest association to a real phenotype. By design, the AccuTool does not account for population structure, so this analysis should only be performed on the set of markers contained within a phenotype-associated region identified from a MLM-GWAS. To illustrate this, we use phenotype data for early pod shatter available downloaded the Germplasm Resources Information Network (GRIN).

### Instructions

From the _demo_1_ folder, download the _Pdh1_phenotype.csv_ file and the _Pdh1_GWAS_statistics.csv_. If you open the phenotype file in Excel, you should see the following format:
```
PI	Pheno
ZJ-Y314	NA
PI_578357	NA
PI_366120	NA
PI_562565	NA
PI_339871A	NA
HN022_PI404198B	2
HN023_PI424608A	2
HN037_PI200508	1
HN038_PI248515	1
HN054_PI437169B	2
HN056_PI437863A	2
HN057_PI438258	2
```
The first column corresponds to the line name for each of the Soy775 accessions, and the second column is the phenotype designation of each line, where 1 is Wild-type, 2 is Mutant, and NA for any line where the phenotype status is unknown. The AccuTool currently only supports a binary phenotype designation.

Similarly, you can view the statistics file, derived from running MLM-GWAS, to get a sense of the format:
```
Chr	Pos	P-val
1	24952	0.977590557
1	26003	0.718829728
1	29671	0.450812625
1	30712	0.49116528
1	37018	0.079049794
1	38482	0.834196223
```
You will notice that this file contains all the SNP50k markers for the entire genome, regardless their association to the phenotype. This is fine, as the AccuTool with filter these positions based on the genomic interval you specify in the input menu.

With these input files downloaded, click (here)[https://soykb.org/Accuracy] to navigate to the AccuTool.

In the _Menu_ tab, specify the following inputs, leaving all others as the default settings:
```
__Chromosome:__ 1
__Genomic interval:__ 29680000 to 30100000
__Reference Phenotype:__ MUT
__Choose Phenotype File (.csv):__ Pdh1_phenotype.csv
__Choos GWAS Statistics File (.csv):__ Pdh1_GWAS_statistics.csv
__Return only SNP50k positions:__ Yes
```
Click the _Calculate Accuracy_ button and allow the AccuTool time to process the genomic interval.
