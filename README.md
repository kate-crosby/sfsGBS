## Folded site frequency spectrum using imputed GBS maize data for Tim

Get data from PANZEA
```
wget http://www.panzea.org/dynamic/derivative_data/genotypes/AmesUSInbreds_AllZeaGBSv1.0_imputed-130508.zip
```

Reformat the hmp.txt.gz data to plink format by chromosome with TASSEL:
```
for file in *.gz
do
        echo "$file: " $(run_pipeline.pl -Xmx15g -fork1 -h $file -export -exportType Plink -runfork1)
done
```

Merge the plink files to make one file - as opposed to 10 chromosomal files:

```
plink --file AmesUSInbreds_AllZeaGBSv1.0_imputed_20130508_chr10.plk --merge-list allfiles.txt --recode --out pedmapmerged
```

Reformat plink to vcf 4.1 because TASSEL's vcf is vcf 4.0 or something weird and screws things up.

```
plink --file pedmapmerged --make-bed --out GBSv_1
plink --bfile GBSv_1 --recode vcf --out GBSv_1
```

Use vcftools (can use plink too) to calculate allele frequency counts (note this is my absolute path from home dir)

```
~/bin/vcftools_0.1.12b/bin/vcftools --gzvcf GBSv_1.vcf.gz --freq --out all_chr_GBS_SFS_analysis
```
Append .txt to the all_chr_GBS_SFS_analysis.frq file and rename column headers in vi.


Reformat data further with R and plot, see 'sfs.R' 
