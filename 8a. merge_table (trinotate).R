library(dplyr)
library(magrittr)

setwd("~/R/Analysis/1_Test/cDNA")

count.table <- read.table("kallisto.isoform.TMM.EXPR.txt",header=T)
report <- read.csv("trinotate_annotation_report.csv",sep="\t",quote = "",header=T)

count.table$transcript_id <- rownames(count.table)
report <- report[,-1]
report.modified <- report %>% distinct(transcript_id, .keep_all = TRUE) 

merge <- merge(count.table, report.modified, by.x='transcript_id', by.y='transcript_id',x.all=TRUE)
write.csv(merge, "count.table.kallisto.csv")
