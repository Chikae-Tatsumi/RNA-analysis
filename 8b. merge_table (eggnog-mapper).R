library(dplyr)
library(magrittr)

setwd("~/R/Analysis/1_Test/cDNA")

count.table <- read.table("kallisto.isoform.TMM.EXPR.txt",header=T)
report <- read.table("eggnog_out.emapper.annotations.txt",sep="\t",quote = "",comment.char="?",skip=4, header=T)

count.table$transcript_id <- rownames(count.table)
report$transcript_id <- sub(".p1", "", report$X.query)
report$transcript_id <- sub(".p2", "", report$transcript_id )

merge <- merge(count.table, report, by.x='transcript_id', by.y='transcript_id',all.x=all)
write.csv(merge, "count.table.kallisto_eggnog.csv")