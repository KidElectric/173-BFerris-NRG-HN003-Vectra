print('Loading libraries')
start_time <- Sys.time()
suppressPackageStartupMessages({
    library(data.table)
    library(ggplot2)
    library(ggpubr)
    library(dplyr)
    library(stringr)
    library(rstatix)
    library(tidyr)
    library(phenoptr)
    }
)
print('Library load finished')
args = commandArgs(trailingOnly=TRUE)
fn <- args[1] #input file
slurm <- args[2]
print(fn)
fn.base <- str_split_fixed(fn,'_cell_seg',n=2)[1]
print(fn.base)
results <- args[3] #output directory
print(results)
cd8.t <- list('Phenotype-CD3' = 'CD3+',
              'Phenotype-CD8' = 'CD8+',
              'Phenotype-FOXP3' = 'other'
              )

treg <- list('Phenotype-CD3' = 'CD3+',
             'Phenotype-CD8' = 'other',
             'Phenotype-FOXP3' = 'FOXP3+')

panck <- list('Phenotype-CD3' = 'other',
              'Phenotype-FOXP3' = 'other',
              'Phenotype-CD8' = 'other',
              'Phenotype-CK' = 'CK+')

cell.defs <- list('panck' = panck,
                  'cd8.t' = cd8.t,
                  'treg' = treg)

labs <- c('CK','PDL1','CD3','CD8','PD1','FOXP3')
pheno.conf <- 25
keep.cols <- c('Sample Name', 'fn', 'Cell ID',
               'cell.type','all.tumor.stroma', 'tissue.compartment',
               'pdl1.expression', 'pd1.expression','combined.pheno',
               'is.pdl1.cell','is.panck.cell')

df <- data.frame(c())
dist = 35

csd <- read.csv(file.path(slurm,fn),
           sep = '\t',
           check.names=FALSE) #check.names=FALSE will prevent replacing spaces with periods\
clean.csd <- csd[csd[,'Tissue Category'] != 'Blank',]
clean.csd$combined.pheno <- ''
for (label in labs){
    pheno.col = sprintf('Phenotype-%s',label)
    conf.col = sprintf('Confidence-%s',label)
    pheno = clean.csd[,pheno.col]
    conf = clean.csd[,conf.col]
    pheno[pheno=='other'] = ''
    pheno[conf < pheno.conf] = ''
    clean.csd$combined.pheno <- paste0(clean.csd$combined.pheno,pheno)
    pheno[pheno == ''] <- 'other'
    clean.csd[,pheno.col] <- pheno
}

# Rename cells with no labeling:    
clean.csd$combined.pheno[clean.csd$combined.pheno == ''] = 'other'
clean.csd$tissue <- clean.csd[,'Tissue Category']

sub <- clean.csd
dst <- phenoptr::distance_matrix(sub) # Compute this just once and re-use it
tmr <- sub$tissue == 'Tumor'
str <- sub$tissue == 'Stroma'

#Define outer margin
sd.1 <- dst[tmr,]
close.1 <- (sd.1 > 0) & (sd.1 <= dist)
outer.margin <- (colSums(close.1) >= 1) & str

#Define inner margin
sd.2 <- dst[str,]
close.2 <- (sd.2 > 0) & (sd.2 <= dist)
inner.margin <- (colSums(close.2) >= 1) & tmr

#Distal & central
distal <- (str & !outer.margin)
central <- (tmr & !inner.margin)

#Add fields
sub$tissue.compartment[distal] <- 'distal.stroma'
sub$tissue.compartment[central] <- "central.tumor"
sub$tissue.compartment[inner.margin] <- 'inner.tumor.inv.margin'   
sub$tissue.compartment[outer.margin] <- 'outer.tumor.inv.margin'
sub$pdl1.expression <- sub[,'Entire Cell PD-L1 (Opal 520) Mean (Normalized Counts, Total Weighting)']
sub$pd1.expression <- sub[,'Entire Cell PD-1 (Opal 620) Mean (Normalized Counts, Total Weighting)']
sub$cell.type <- 'other'
sub$is.pdl1.cell <- sub[,'Phenotype-PDL1'] == 'PDL1+'
sub$is.panck.cell <- sub[,'Phenotype-CK'] == 'CK+'
sub$all.tumor.stroma <- sub$tissue
sub$fn <- fn
for (cell in names(cell.defs)) {
    # print(cell)
    idx <- rep_len(TRUE, dim(sub)[1])
    def <- cell.defs[[cell]]
    for (col in names(def)){
        # print(col)
        idx <- idx & (sub[col] == def[[col]])
    }
    # print(sum(idx))
    sub[idx, 'cell.type'] <- cell
}
df<- rbind(df,sub[,keep.cols])

fn <- file.path(results,sprintf('%s-clean-%dcell-measurements_%dcol.csv',fn.base,dim(df)[1],dim(df)[2]))
print(fn)
write.csv(df,fn)
head(df)
stop_time <- Sys.time()
print(paste('Time elapsed:',(stop_time - start_time)/60,'minutes'))