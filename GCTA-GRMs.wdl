
task chrgrm {
	File bed
	File bim
	File fam
	File variantlist
	String plinklabel
	String label
	Int? threads = 6
	Float? memory
	Int? disksize
	
	command <<<
			pwd
			ls
			ls /cromwell_root/
            echo ${plinklabel}
            ls -l ${plinklabel}*
            head ${plinklabel}.bim
			# Make GRM based on snp list
			/home/biodocker/bin/gcta_1.91.7beta/gcta64 --threads ${threads} --bfile ${plinklabel} --extract ${variantlist} --make-grm --out ${label}
			ls
	>>>
	runtime {
		docker: "akmanning/genomewide_heritability:gcta"
		disks: "local-disk ${disksize} SSD"
		memory: "${memory}G"
	}
	output { 
		File grmid = "${label}.grm.id"
		File grmsnp = "${label}.grm.id"
		File grmbin = "${label}.grm.id"
		File grmlog = "${label}.log"

	}
}

task grm {
	Array[String] chrLabels
	Array[File] grmids
	Array[File] grmsnps
	Array[File] grmbins
	String analysisLabel
	Int? threads = 6
	Float? memory
	Int? disksize
	
	command <<<
		pwd
		ls
		ls /cromwell_root/
		/home/biodocker/bin/gcta_1.91.7beta/gcta64 --mgrm ${write_lines(chrLabels)} --threads ${threads} --make-grm-bin --out ${analysisLabel}	
		ls
	>>>
	runtime {
		docker: "akmanning/genomewide_heritability:gcta"
		disks: "local-disk ${disksize} SSD"
		memory: "${memory}G"
	}
	output { 
		File grmid = "${analysisLabel}.grm.id"
		File grmsnp = "${analysisLabel}.grm.id"
		File grmbin = "${analysisLabel}.grm.id"
		File grmlog = "${analysisLabel}.log"
		
		
	}
}


workflow w {
	Array[File] bedFiles
	Array[File] bimFiles
	Array[File] famFiles
	Array[String] chrLabels
	File variantlist
	String analysisLabel
	String plinklabel
	Int? threads = 6
	Float? memory
	Int? disksize
	
	Array[Int] chrs = range(length(chrLabels))
	
	scatter (chr in chrs) {
		call chrgrm { 
			input: plinklabel=sub(sub(bedFiles[chr],".bed",""),"gs://",""), label=chrLabels[chr], bed=bedFiles[chr], bim=bimFiles[chr], fam=famFiles[chr], variantlist=variantlist, memory=memory, disksize=disksize,threads=threads
		}
	}
	call grm {
		input: analysisLabel=analysisLabel, chrLabels=chrLabels, grmids=chrgrm.grmid, grmsnps=chrgrm.grmsnp, grmbins=chrgrm.grmbin, memory=memory, disksize=disksize,threads=threads
	}
	
}