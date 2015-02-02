# Write a short R script to remove the duplicates from the GBS v_2.7

rm(list=ls())
library(data.table)

GBS <- read.csv("AllZeaGBSv2.7_public.csv", header=T)
dt <- data.table(GBS)

# Subset out NAM - because everybody is B73!!!

dt <- subset(dt, Project != "NAM")
dt <- subset(dt, GermplasmSet != "W22 x Teosinte BC2S3")
dt <- subset(dt, GermplasmSet != "IBM")
dt <- subset(dt, GermplasmSet != "Maize-BREAD;CIMMYT Collection")

# Get only the unique runs for now by row - we can go back and judge later if this is a problem
# i.e. perhaps quality might be an issue
setkey(dt, "DNASample")
dt.u <- unique(dt, by = "DNASample")

# Generate just a .txt of the actual GBS name for Tassel to include/exclude

keep_list <- subset(dt.u, select = "FullName")

write.table(keep_list, "keep_list.txt")

write.csv(keep_list, "keep_list.csv", row.names=F)