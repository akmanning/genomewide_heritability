task snplist {
	File ldscore
	command {
			ls -lh
			R --vanilla -e "source('https://raw.githubusercontent.com/akmanning/genomewide_heritability/master/GCTA-LDMS.R')" --args ${ldscore} 
			tar czvf score.snp.tar.gz score.snp*
			ls -lh
	}
	output { 
		File score_snp = "score.snp.tar.gz"
		File multi_grms = "snp_groups_multGRMs.txt"
	
	}
	runtime {
		docker: "r-base:latest"
		disks: "local-disk 50 SSD"
		memory: "10G"
	}
}

task ldms {
	File bed
	File bim
	File fam
	File score_snp
	File multi_grms
	File outcome
	File covar
	File qcovar
	Float prevalence
	String label
	Int? threads = 6
	Float? memory
	Int? disksize
	
	command <<<
			ls -lh
			
			tar xzvf ${score_snp}
			ls -lh
			
			# Make GRM based on each snp list
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group1_maf0.05.txt --make-grm --out score.snp_group1_maf0.05
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group2_maf0.05.txt --make-grm --out score.snp_group2_maf0.05
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group3_maf0.05.txt --make-grm --out score.snp_group3_maf0.05
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group4_maf0.05.txt --make-grm --out score.snp_group4_maf0.05

			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group1_maf0.01.txt --make-grm --out score.snp_group1_maf0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group2_maf0.01.txt --make-grm --out score.snp_group2_maf0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group3_maf0.01.txt --make-grm --out score.snp_group3_maf0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group4_maf0.01.txt --make-grm --out score.snp_group4_maf0.01

			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group1_maflt0.01.txt --make-grm --out score.snp_group1_maflt0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group2_maflt0.01.txt --make-grm --out score.snp_group2_maflt0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group3_maflt0.01.txt --make-grm --out score.snp_group3_maflt0.01
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile /cromwell_root/${label} --extract score.snp_group4_maflt0.01.txt --make-grm --out score.snp_group4_maflt0.01
			ls -lh
			# Run REML to get heritability of each GRM
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --reml --prevalence ${prevalence} --pheno ${outcome} --covar ${covar} --qcovar {qcovar} --out multiGRMs  --mgrm ${multi_grms} --threads ${threads}
			ls -lh

			tar czvf score.snp.tar.gz score.snp* 
			ls -lh
	>>>
	runtime {
		docker: "akmanning/genomewide_heritability:gcta"
		disks: "local-disk ${disksize} SSD"
		memory: "${memory}G"
	}
	output { 
		File grms = "score.snp.tar.gz"
		
		File out_reml_log = "multiGRMs.log"
		File out_reml_hsq = "multiGRMs.hsq"
		
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
	
	call snplist {
		input: ldscore=ldscore
	}
	call ldms { 
		input: label=sub(sub(bed,".bed",""),"gs://",""), bed=bed, bim=bim, fam=fam, score_snp=snplist.score_snp, multi_grms=snplist.multi_grms, outcome=outcome, covar=covar, qcovar=qcovar, prevalence=prevalence, memory=memory, disksize=disksize,threads=threads
		}
	
}