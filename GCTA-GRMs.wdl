
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

task filepath {
	String chrLabel

	command {
		echo ${chrLabel}
	}

	runtime {
		docker: "tmajarian/alpine_wget@sha256:f3402d7cb7c5ea864044b91cfbdea20ebe98fc1536292be657e05056dbe5e3a4"
	}

	output {
		String chrLabelout = "${chrLabel}"
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

	scatter (grmbin in chrgrm.grmbin) {
    	call filepath { input: chrLabel =  sub(sub(grmbin,".bed",""),"gs://","") }
    }
  
	call grm {
		input: analysisLabel=analysisLabel, chrLabels=filepath.chrLabelout, grmids=chrgrm.grmid, grmsnps=chrgrm.grmsnp, grmbins=chrgrm.grmbin, memory=memory, disksize=disksize,threads=threads
	}
	
}