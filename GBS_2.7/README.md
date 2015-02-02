### Getting the folded sfs for Tim with GBS v 2.7 data

This is pretty much the same workflow as GBS v 1.0 with a few modifications

-  Get the data as hmp.gz: 
```
wget http://www.panzea.org/dynamic/derivative_data/genotypes/AllZeaGBSv2.7_publicSamples_imputedV3b_agpv3.hmp.gz
```

- First this GBS data is what Tassel calls "unsorted" I think apparently to save file space. Sorting it does take a bit of time (30 minutes) and about 8 CPUs on bigmemh for about 35 minutes (I ran it on the weekend at night), and 64 Gb of mem as specified in tassel. Any less and it'll crap out.

```
module load gcc jdk/1.8 tassel/5

for file in *.gz
do
        echo "$file: " $(run_pipeline.pl -Xmx64g -SortGenotypeFilePlugin -inputFile AllZeaGBSv2.7_publicSamples_imputedV3b_agpv3.hmp.gz -outputFile sortedGBS -fileType Hapmap)
done
```

- Gzip that output "sortedGBS", because it's a huge file (don't do it on the headnode).

- Next up decide what samples you want to **include/exclude** from the GBS data. First check the metadata - that's the "AllZeaGBSv2.7_public.csv" in the repo. Read that into R and run the ["get_list_GBS.R"](https://github.com/kate-crosby/sfsGBS/blob/master/GBS_2.7/get_list_GBS.R).

- As in the R script - export that as a .csv or .txt - this is the (keep_list.csv or keep_list.txt) [https://github.com/kate-crosby/sfsGBS/blob/master/GBS_2.7/keep_list.csv] - as long as you append the end to .txt for Tassel and check for header or rownames before you'll be fine (get the row.names and header out of there). I also threw out the scaffolds in this R script above.

- Pass this list to Tassel and run to export as VCF (note that I'm just doing a quick rm or mv of the .gz files as we go along here):

```
module load gcc jdk/1.8 tassel/5

for file in *.gz
do
        echo "$file: " $(run_pipeline.pl -Xmx64g -fork1 -h $file -includeTaxaInfile keep_list.txt -export -exportType VCF -runfork1)
done

```

- Tassel will output your VCF reduced file list with the correct number of rows you can double check with the R script above - in this case 4021 samples.

- Next run VCFtools to get the allele frequencies at a site (again this is my absolute path to vcf tools - adjust yours accordingly)

```
~/bin/vcftools_0.1.12b/bin/vcftools --gzvcf sorted_4021.vcf.gz --freq --out all_chr_GBS_2.7_SFS_analysis
```

- I appended headers to seven column output (should be 6 but the data is not perfect) -so the seventh is the column where a site was not perfectly imputed (in this case if there is a seventh column a frequency was way less than 0.01 of the total allele frequency at a site - I ran with it). I cut the seventh column and wrote as new.txt. This file gets passed to the (sfs.R)[https://github.com/kate-crosby/sfsGBS/blob/master/GBS_2.7/sfs.R]

- That's it. Folded SFS is the last line of the script.
