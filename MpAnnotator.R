# Rscript to annotate genes based on Gene ID (v5.1)
# Originally by Ryohei Thomas Nakano, PhD; nakano@mpipz.mpg.de
# 23 Dec 2021
# Usage: Rscript MpAnnotator.R [path_to_input_file (mendatory; has to be *.txt)] [output_file (optional) - 1: simplified, 2: concatenated, 3: full, 0: all of these three]

options(warn=-1)

# clean up
rm(list=ls())

# ===== Set Up ===== #
# packages
check <- require(stringr, quietly=T, warn.conflicts=T)){
		if(!check) stop("This script requires the package \"stringr\". Please install it first.")

# paths
args <- commandArgs(trailingOnly=T)
		if(length(args) == 0) stop("Please specify the input file.")
		if(length(args) > 2) stop("Unknown option is given. Please only give the input file path and the output option (optional).")
		if(length(args) == 2 & !(args[2] %in% c(0, 1, 2, 3))) stop("Unknown option is given. Please choose the output option from 0, 1, 2, and 3 (see README for details).")

input <- args[1]
		if(length(args) > 0 & !str_detect(input, ".txt$")) stop("Please specify a correct input file (*.txt).")


# ===== Loading Data ===== #
# load reference data
data <- "/biodata/dep_psl/common/MpAnnotator/data/"
# data <- "/path/to/your/ref_data/directory/" # This in an alternative, in case you don't want to work on the cluster. You can copy reference data from the path above and save to your local directory. Give the path to your reference data directory here and it should work.

RLK <- read.table(paste(data, "MpLRRRLK.txt", sep=""),                                        header=T, row.names=NULL, sep="\t", comment.char="", quote="",   stringsAsFactors=F)
ref <- read.table(paste(data, "Marchantia_Step0_Combined_Annotations_v5.1_v3.1.csv", sep=""), header=T, row.names=NULL, sep=",",  comment.char="", quote="\"", stringsAsFactors=F)

colnames(RLK) <- paste("LRR_RLK-", colnames(RLK), sep="")

# load input data and QC
IDs <- read.table(input, header=F, sep="\t", row.names=NULL, comment.char="", quote="", stringsAsFactors=F)

		if(ncol(IDs) > 1) stop("Please do not include more than one column.")

IDs <- IDs$V1
		if(!str_detect(IDs[1], "^Mp|^Mapoly")) stop("Please do not include any header row. Please only put Gene IDs.")
		if(sum(str_detect(IDs, "^Mapoly")) == length(IDs)) stop("This script only accept IDs in v5.1. v3.1 IDs are not accepted.")
		if(sum(str_detect(IDs, "^Mp")) != length(IDs)) stop("There are some IDs that do not match with v5.1 format. Please check and modify the input file.")






# ===== Main Script ===== #

# expand concatenated inputs
df <- do.call(rbind, lapply(IDs, function(x){
	temp <- unlist(str_split(x, ";"))
	out <- data.frame(concatenated_ID=x, ID=temp, stringsAsFactors=F)
	return(out)
}))

# merge with gene annotations
idx <- match(df$ID, ref$GeneID_v5.1)
df <- cbind(df, ref[idx,-1])

# merge with LRR-RLK annotations
idx <- match(df$ID, RLK$'LRR_RLK-gene_id_5.1')
df <- cbind(df, RLK[idx, 3:ncol(RLK)])

# concatenate annotations
df_merge <- do.call(rbind, lapply(unique(df$concatenated_ID), function(x){
	idx <- df$concatenated_ID == x
	
	if(sum(idx) == 1){
		return(df[idx,])
	} else {
		temp <- df[idx,]
		merge <- as.data.frame(t(apply(temp, 2, paste, collapse=";")))
		merge[, 1:2] <- x
		return(merge)
	}
}))

# simplify by taking the front-end ID
idx <- str_replace(df$concatenated_ID, ";.*", "") == df$ID
df_simple <- df[idx,]

# export full version
if(length(args) < 2 | args[2] %in% c(0,1)) write.table(df_simple, file=str_replace(input, ".txt", "-annotation_simplified.txt"),   sep="\t", col.names=T, row.names=F, quote=F, na="")
if(length(args) < 2 | args[2] %in% c(0,2)) write.table(df_merge,  file=str_replace(input, ".txt", "-annotation_concatenated.txt"), sep="\t", col.names=T, row.names=F, quote=F, na="")
if(length(args) < 2 | args[2] %in% c(0,3)) write.table(df,        file=str_replace(input, ".txt", "-annotation_full.txt"),         sep="\t", col.names=T, row.names=F, quote=F, na="")



# ===== Finishing ===== #
message("Done")





