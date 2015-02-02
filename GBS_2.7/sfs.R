rm(list=ls())

library(stringr)
library(data.table)
GBS.sfs <- read.table("new.txt", header = T,
colClasses=c('factor', 'numeric', 'numeric', 'numeric', 'character', 'character'), 
fill = TRUE, sep ="\t", row.names=NULL)

## Remove the scaffolds

GBS.sfs <- subset(GBS.sfs, CHROM != "scaffold")

#Strip out the 'nitrogenous base:' for the Major and Minor allele columns

major <- GBS.sfs$MAJOR
minor <- GBS.sfs$MINOR

major <- str_replace(major, "C:", "")
major <- str_replace(major, "A:", "")
major <- str_replace(major, "T:", "")
major <- str_replace(major, "G:", "")
major <- str_replace(major, "N:", "")
major <- str_replace(major, "-:", "")
# Make it numeric
major<-as.numeric(major)


#x <- data.table(minor)

#x <- minor[like(minor, ":")]

minor <- str_replace(minor, "C:", "")
minor <- str_replace(minor, "A:", "")
minor <- str_replace(minor, "T:", "")
minor <- str_replace(minor, "G:", "")
minor <- str_replace(minor, "-:", "")
minor <- str_replace(minor, "N:", "")
minor <- str_replace(minor, "+:", "")



#Make it numeric
minor <- as.numeric(minor)


# For the minor allele column which contained zero was designated as NA fill in with 0
minor[is.na(minor)] <- 0

# Make a new data.frame

sfs <- data.frame(GBS.sfs$CHROM, GBS.sfs$POS, GBS.sfs$N_ALLELES, GBS.sfs$N_CHR, major, minor)

# Use N_CHR column (indicates the amount of chromosomes you have data available for at that locus - diploid so
# double 4476)

# Make some summary columns - remove division if needed

ind.major <- (sfs[,4] * sfs[,5])/2
ind.major <- round(ind.major, digits = 0)

ind.minor <- (sfs[,4] * sfs[,6])/2
ind.minor <- round(ind.minor, digits = 0)

# Add these columns

sfs <- data.frame(sfs, ind.minor, ind.major)

# Because Tim likes the 'base' package - ps. this is the folded site frequency spectrum
hist(ind.minor, main="Folded SFS with GBS v.2.7", xlab="Minor Allele Frequency")
