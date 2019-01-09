task ldms {
	File bed
	File bim
	File fam
	Fire ldscore
	File outcome
	File covar
	File qcovar
	Float prevalence
	String label
	Int? threads = 6
	Float? memory
	Int? disksize
	
	command <<<
			# Generate SNP lists
			R --vanilla --args ${label} ${ldscore} < /genomewide_heritability/GCTA-LDMS.R

			# Make GRM based on each snp list
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group1_maf0.05.txt --make-grm --out score.snp_group1_maf0.05
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group2_maf0.05.txt --make-grm --out score.snp_group2_maf0.05
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group3_maf0.05.txt --make-grm --out score.snp_group3_maf0.05
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group4_maf0.05.txt --make-grm --out score.snp_group4_maf0.05

			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group1_maf0.01.txt --make-grm --out score.snp_group1_maf0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group2_maf0.01.txt --make-grm --out score.snp_group2_maf0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group3_maf0.01.txt --make-grm --out score.snp_group3_maf0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group4_maf0.01.txt --make-grm --out score.snp_group4_maf0.01

			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group1_maflt0.01.txt --make-grm --out score.snp_group1_maflt0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group2_maflt0.01.txt --make-grm --out score.snp_group2_maflt0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group3_maflt0.01.txt --make-grm --out score.snp_group3_maflt0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${label} --extract score.snp_group4_maflt0.01.txt --make-grm --out score.snp_group4_maflt0.01

			# Run REML to get heritability of each GRM
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --reml --prevalence ${prevalence} --pheno ${outcome} --covar ${covar} --qcovar {$qcovar} --out ${label}_multGRMs  --mgrm snp_groups_multGRMs.txt --threads ${threads}

			tar czvf ${label}.score.snp.tar.gz score.snp* 
	>>>
	runtime {
		docker: "akmanning/genomewide_heritability:gcta"
		disks: "local-disk ${disksize} SSD"
		memory: "${memory}G"
	}
	output { 
		File score.snp = ${label}.score.snp.tar.gz
		
		File out_reml_log = "${label}_multGRMs.log"
		File out_reml_hsq = "${label}.hsq"
		
	}
}


workflow w {
	File bed
	File bim
	File fam
	File ldscore
	File outcome
	File covar
	File qcovar
	Float prevalence
	String label
	Int? threads = 6
	Float? memory
	Int? disksize
	
	call ldms { 
		input: label=this_label, bed=this_bed, bim=this_bim, fam=this_fam, ldscore=this_ldscore, outcome=this_outcome, covar=this_covar, qcovar=this_qcovar, prevalence=this_prevalence, memory=this_memory, disksize=this_disksize,threads=this_threads
		}
	
}