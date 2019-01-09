commandArgs(trailingOnly=TRUE)

ld_scores_file <- commandArgs(trailingOnly=TRUE)[1]

lds_seg = read.table(ld_scores_file,header=T,colClasses=c("character",rep("numeric",8)))
quartiles=summary(lds_seg$ldscore_SNP)

lb1 = which(lds_seg$ldscore_SNP <= quartiles[2])
lb2 = which(lds_seg$ldscore_SNP > quartiles[2] & lds_seg$ldscore_SNP <= quartiles[3])
lb3 = which(lds_seg$ldscore_SNP > quartiles[3] & lds_seg$ldscore_SNP <= quartiles[5])
lb4 = which(lds_seg$ldscore_SNP > quartiles[5])

lb1_snp = lds_seg$SNP[lb1]
lb2_snp = lds_seg$SNP[lb2]
lb3_snp = lds_seg$SNP[lb3]
lb4_snp = lds_seg$SNP[lb4]


#write.table(lb1_snp, "score.snp_group1.txt", row.names=F, quote=F, col.names=F)
#write.table(lb2_snp, "score.snp_group2.txt", row.names=F, quote=F, col.names=F)
#write.table(lb3_snp, "score.snp_group3.txt", row.names=F, quote=F, col.names=F)
#write.table(lb4_snp, "score.snp_group4.txt", row.names=F, quote=F, col.names=F)

# MAF>=0.05
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP <= quartiles[2] & lds_seg$freq >= 0.05)], "score.snp_group1_maf0.05.txt", row.names=F, quote=F, col.names=F)
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP > quartiles[2] & lds_seg$ldscore_SNP <= quartiles[3] & lds_seg$freq >= 0.05)], "score.snp_group2_maf0.05.txt", row.names=F, quote=F, col.names=F)
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP > quartiles[3] & lds_seg$ldscore_SNP <= quartiles[5] & lds_seg$freq >= 0.05)], "score.snp_group3_maf0.05.txt", row.names=F, quote=F, col.names=F)
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP > quartiles[5] & lds_seg$freq >= 0.05)], "score.snp_group4_maf0.05.txt", row.names=F, quote=F, col.names=F)

# MAF>=0.01
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP <= quartiles[2] & lds_seg$freq < 0.05 & lds_seg$freq >= 0.01)], "score.snp_group1_maf0.01.txt", row.names=F, quote=F, col.names=F)
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP > quartiles[2] & lds_seg$ldscore_SNP <= quartiles[3] & lds_seg$freq < 0.05 & lds_seg$freq >= 0.01)], "score.snp_group2_maf0.01.txt", row.names=F, quote=F, col.names=F)
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP > quartiles[3] & lds_seg$ldscore_SNP <= quartiles[5] & lds_seg$freq < 0.05 & lds_seg$freq >= 0.01)], "score.snp_group3_maf0.01.txt", row.names=F, quote=F, col.names=F)
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP > quartiles[5] & lds_seg$freq < 0.05 & lds_seg$freq >= 0.01)], "score.snp_group4_maf0.01.txt", row.names=F, quote=F, col.names=F)

# MAF>=0.01
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP <= quartiles[2] & lds_seg$freq < 0.01 )], "score.snp_group1_maflt0.01.txt", row.names=F, quote=F, col.names=F)
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP > quartiles[2] & lds_seg$ldscore_SNP <= quartiles[3] & lds_seg$freq < 0.01)], "score.snp_group2_maflt0.01.txt", row.names=F, quote=F, col.names=F)
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP > quartiles[3] & lds_seg$ldscore_SNP <= quartiles[5] & lds_seg$freq < 0.01)], "score.snp_group3_maflt0.01.txt", row.names=F, quote=F, col.names=F)
write.table(lds_seg$SNP[which(lds_seg$ldscore_SNP > quartiles[5] & lds_seg$freq < 0.01)], "score.snp_group4_maflt0.01.txt", row.names=F, quote=F, col.names=F)

snp.lists <- c("score.snp_group1_maf0.05",
               "score.snp_group2_maf0.05",
               "score.snp_group3_maf0.05",
               "score.snp_group4_maf0.05",
               "score.snp_group1_maf0.01",
               "score.snp_group2_maf0.01",
               "score.snp_group3_maf0.01",
               "score.snp_group4_maf0.01",
               "score.snp_group1_maflt0.01",
               "score.snp_group2_maflt0.01",
               "score.snp_group3_maflt0.01",
               "score.snp_group4_maflt0.01")

write.table(snp.lists,file="snp_groups_multGRMs.txt", row.names=F, quote=F, col.names=F)