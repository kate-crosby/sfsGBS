module load gcc jdk/1.8 tassel/5


# for each unzipped file remove the 5th column - the strand column and out a new file
for file in *.hmp.txt
do
        echo "$file: " $(cut --complement -f 5 $file > no_strand$file)
done

# translate the indels into something that tassel understands
for file in no_strand*.hmp.txt
do
        echo "$file: "$(sed 's/[+-]/0/g' $file > recode$file)
done

for file in recodeno_strandAll*.hmp.txt
do
        echo "$file: " $(run_pipeline.pl -Xmx64g -fork1 -h $file -export -exportType VCF -runfork1)
done

rm no_strand*.hmp.txt

for file in *.vcf
do
	echo "$file: " $(sed '11q;d' $file > header$file.vcf)
done

for file in recodeno_strandAll*.vcf
do
	echo "$file: " $(sed '1,10!d' $file > first$file.vcf)
done

for file in recodeno_strandAll*.vcf
do
	echo "$file: " $(sed -e '1,11d' $file > last$file.vcf)
done


for file in header*.vcf
do
	echo "$file: " $(cat $file | tr '\t' '\n'| awk -F":" '{print $1}'| tr '\n' '\t' > middle$file.vcf)
done

for file in middle*.vcf
do
	echo "$file: " $(cat $file | tr '\t' '\n' > testheader$file)
done

rm recodeno_strand*.vcf

# This is just to make a list of duplicates to remove
for file in testheader*.vcf
do
	echo "$file: " $(uniq -d $file > dups$file.txt)
done

# This adds a line to each middle file, i.e. the header
for file in middle*.vcf
do
	sed -i -e '$a\' $file
done 


## Cat all the files back together and check each one - give a short name
cat first.vcf middle.vcf last.vcf > seeds.vcf


## Use vcftools to completely remove the duplicates example provided here

~/bin/vcftools_0.1.12b/bin/vcftools --vcf seeds10.vcf --remove dupstestheadermiddleheaderrecodeno_strandAll_SeeD_2.7_chr10_no_filter.unimputed.vcf.vcf.vcf.txt --recode --out new_seeds10
~/bin/vcftools_0.1.12b/bin/vcftools --vcf seeds9.vcf --remove dupstestheadermiddleheaderrecodeno_strandAll_SeeD_2.7_chr9_no_filter.unimputed.vcf.vcf.vcf.txt --recode --out new_seeds9
~/bin/vcftools_0.1.12b/bin/vcftools --vcf seeds8.vcf --remove dupstestheadermiddleheaderrecodeno_strandAll_SeeD_2.7_chr8_no_filter.unimputed.vcf.vcf.vcf.txt --recode --out new_seeds8
~/bin/vcftools_0.1.12b/bin/vcftools --vcf seeds7.vcf --remove dupstestheadermiddleheaderrecodeno_strandAll_SeeD_2.7_chr7_no_filter.unimputed.vcf.vcf.vcf.txt --recode --out new_seeds7
~/bin/vcftools_0.1.12b/bin/vcftools --vcf seeds6.vcf --remove dupstestheadermiddleheaderrecodeno_strandAll_SeeD_2.7_chr6_no_filter.unimputed.vcf.vcf.vcf.txt --recode --out new_seeds6
~/bin/vcftools_0.1.12b/bin/vcftools --vcf seeds5.vcf --remove dupstestheadermiddleheaderrecodeno_strandAll_SeeD_2.7_chr5_no_filter.unimputed.vcf.vcf.vcf.txt --recode --out new_seeds5
~/bin/vcftools_0.1.12b/bin/vcftools --vcf seeds4.vcf --remove dupstestheadermiddleheaderrecodeno_strandAll_SeeD_2.7_chr4_no_filter.unimputed.vcf.vcf.vcf.txt --recode --out new_seeds4
~/bin/vcftools_0.1.12b/bin/vcftools --vcf seeds3.vcf --remove dupstestheadermiddleheaderrecodeno_strandAll_SeeD_2.7_chr3_no_filter.unimputed.vcf.vcf.vcf.txt --recode --out new_seeds3
~/bin/vcftools_0.1.12b/bin/vcftools --vcf seeds2.vcf --remove dupstestheadermiddleheaderrecodeno_strandAll_SeeD_2.7_chr2_no_filter.unimputed.vcf.vcf.vcf.txt --recode --out new_seeds2
~/bin/vcftools_0.1.12b/bin/vcftools --vcf seeds1.vcf --remove dupstestheadermiddleheaderrecodeno_strandAll_SeeD_2.7_chr1_no_filter.unimputed.vcf.vcf.vcf.txt --recode --out new_seeds1

## Gzip the new_seeds
for file in new_seeds*.vcf
do
	echo "$file: " $(gzip $file)
done

## Remove any sites with more than 2 alleles but keep the singleton

for file in *.gz
do
        echo "$file: " $(~/bin/vcftools_0.1.12b/bin/vcftools --vcf $file --max-alleles 2 --recode --out min1_$file)
done


for file in min1*.vcf
do
        echo "$file: "$(~/bin/vcftools_0.1.12b/bin/vcftools --vcf $file --freq --out freq$file)
done

# Change dir to freqs directory and remove the headers, cat the files.



