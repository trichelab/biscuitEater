#' Summarize methylation over provided regions
#'
#' Used for bsseq objects. Mostly a local wrapp for getMeth.
#'
#' @param bsseq   The bsseq object to summarize
#' @param segs    Regions to summarize over (GRanges object, no GRangesList yet)
#' @param dropNA  Whether to drop rows if more than half of samples are NA
#'                  (DEFAULT: FALSE)
#' @param impute  Whether to impute NAs/NaNs (DEFAULT: FALSE)
#'
#' @return        A matrix of regional methylation fractions
#'
#' @importFrom matrixStats rowSums2
#' @import impute
#' @import bsseq
#'
#' @examples
#'
#'   orig_bed <- system.file("extdata", "MCF7_Cunha_chr11p15.bed.gz",
#'                           package="biscuiteer")
#'   orig_vcf <- system.file("extdata", "MCF7_Cunha_header_only.vcf.gz",
#'                           package="biscuiteer")
#'   bisc <- readBiscuit(BEDfile = orig_bed, VCFfile = orig_vcf,
#'                       merged = FALSE)
#'
#'   reg <- GRanges(seqnames = rep("chr11",5),
#'                  strand = rep("*",5),
#'                  ranges = IRanges(start = c(0,2.8e6,1.17e7,1.38e7,1.69e7),
#'                                   end= c(2.8e6,1.17e7,1.38e7,1.69e7,2.2e7))
#'                 )
#'   summary <- summarizeBsSeqOver(bsseq = bisc, segs = reg, dropNA = TRUE)
#'
#' @export
#'
summarizeBsSeqOver <- function(bsseq,
                               segs,
                               dropNA = FALSE,
                               impute = FALSE) { 
  segs <- subsetByOverlaps(segs, bsseq)
  res <- bsseq::getMeth(bsseq, regions=segs, what="perRegion", type="raw")
  rownames(res) <- as.character(segs)
  if (dropNA) {
    res <- res[matrixStats::rowSums2(is.na(res)) < (ncol(res)/2), , drop=FALSE]
  }
  if (impute && any(is.nan(res))) {
    res <- matrix(fexpit(impute.knn(flogit(as.matrix(res)))$data))
  }
  return(res)
} 
