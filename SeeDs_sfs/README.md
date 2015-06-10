## New sfs file with SeeDs data

- OPV landraces from Alberto Romero and CIMMYT. Used to estimate effective population size.
- 
### Steps to get the folded sfs

- Ask for the data - comes in hmp.txt.zip format. Gzip and then run tassel 5 to sort the genotypes: 

```
for file in *.gz
do
        echo "$file: " $(run_pipeline.pl -Xmx64g -SortGenotypeFilePlugin -inputFile $file -outputFile sortedGBS$file -fileType Hapmap)
done
```

Run a short script in R to produce a list of unique values, from the metadata information
```
```

Unzip the files, cut the strand column because it's unnecessary for sfs - and recode indels from +/- to 0 for tassel

```
# unzip the files
for file in *.hmp.txt.gz
do
        echo "$file: " $(gunzip $file)
done

# for each unzipped file remove the 5th column - the strand column and out a new file
for file in *.hmp.txt
do
        echo "$file: " $(cut --complement -f 5 $file > no_strand$file)
done

# remove the old files (there's a copy of them anyway)
rm sortedGBSAll_*


# translate the indels into something that tassel understands
for file in *.hmp.txt
do
        echo "$file: "$(sed 's/[+-]/0/g' $file > recode$file)
done
```

- Use tassel to export to vcftools

```
for file in *.gz
do
        echo "$file: " $(run_pipeline.pl -Xmx64g -fork1 -h $file -export -exportType VCF -runfork1)
done
```

- Next use vcftools to remove any site that has an indel more or less than 2 alleles
```
for file in *.gz
do
        echo "$file: " $(~/bin/vcftools_0.1.12b/bin/vcftools --gzvcf $file --min-alleles 2 --max-alleles 2 --recode --out biallelic_$file)
done
```

- And get the frequencies

```
for file in *.gz
do
        echo "$file: "$(~/bin/vcftools_0.1.12b/bin/vcftools --gzvcf $file --freq --out freq$file)
done
```

- Remove the headers from CHROMs 2-10 with ```tail -n +2```
- Append CHROMs 2-10 with cat >>
- Append headers to this larger file in vi
- Run this file ['all_chr_SeeDs_frq.txt'](https://github.com/kate-crosby/sfsGBS/blob/master/SeeDs_sfs/all_chr_SeeDs_frq.txt) with R script ['sfs_SeeDs.R'](https://github.com/kate-crosby/sfsGBS/blob/master/SeeDs_sfs/sfs_SeeDs.R)

- Here's what the plot looks  like sans rescaling: ![alt text] (https://github.com/kate-crosby/sfsGBS/blob/master/SeeDs_sfs/Rplot.png)

