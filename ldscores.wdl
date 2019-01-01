task ldscores {
	File vcf
	String label
	Int? threads = 6
	Float? memory
	Int? disksize
	
	command {
		mv {$label}.vcf.bgz {$label}.vcf.gz
		/home/biodocker/bin/plink --vcf {$label}.vcf.gz --make-bed --out {$label}
		cp {$label}.bim {$label}_old.bim
		awk '{b="chr"$1"-"$4"-"$5"-"$6; print $1"\t"b"\t"$3"\t"$4"\t"$5"\t"$6;}' {$label}_old.bim > {$label}.bim
		/home/biodocker/bin/gcta_1.91.7beta/gcta64 --bfile {$label} --ld-score-region 200 --out {$label}_segment --threads {$threads}
	}
	runtime {
		docker: "akmanning/genomewide_heritability:latest"
		disks: "local-disk ${disksize} SSD"
		memory: "${memory}G"
	}
	output { 
		File out_bim = "${label}.bim"
		File out_bed = "${label}.bam"
		File out_fam = "${label}.fam"
		File out_nosex = "${label}.nosex"
		File out_log = "${label}.log"
		File out_ldscorelog = "${label}_segment.log"
		File out_ldscores = "${label}_segment.score.ld"
	}
}

workflow w {
	Array[File] these_vcf
	String this_label
	Int? this_threads = 6
	Float? this_memory = 30.0
	Int? this_disksize = 200
	
	scatter(this_vcf in these_vcf) {
		call ldscores { 
			input: vcf=this_vcf, label=this_label, memory=this_memory, disksize=this_disksize,threads=this_threads}
	}

	output {
		Array[File] this_out_bim = ldscores.out_bim
		Array[File] this_out_bed = ldscores.out_bed
		Array[File] this_out_fam = ldscores.out_fam
		Array[File] this_out_nosex = ldscores.out_nosex
		Array[File] this_out_log = ldscores.out_log
		Array[File] this_out_ldscorelog = ldscores.out_ldscorelog
		Array[File] this_out_ldscores = ldscores.out_ldscores
	}
}