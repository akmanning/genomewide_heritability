
import "https://raw.githubusercontent.com/akmanning/genomewide_heritability/master/GCTA-GRMs.wdl" as GRMWDL


workflow variantslists {
	Array[File] bedFiles
	Array[File] bimFiles
	Array[File] famFiles
	Array[String] chrLabels
	Array[File] variantlists
	Int? threads = 6
	Float? memory
	Int? disksize
		
    scatter (variantlist in variantlists) {
    	call GRMWDL.w {
    		input:
    			bedFiles = bedFiles,
				bimFiles = bimFiles,
				famFiles = famFiles,
				chrLabels = chrLabels,
				variantlist = variantlist,
    			threads = threads,
				memory = memory,
				disksize = disksize
	
    	}
    	
    }
    
}
