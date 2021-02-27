############################# Dockerfile ####################################
FROM biocontainers/biocontainers:v1.2.0_cv1


######################## METADATA ###########################################

LABEL base_image="biocontainers:v1.2.0_cv1"
LABEL version="3"
LABEL software="gcta"
LABEL software.version="gcta_1.93.2"
LABEL about.summary="A tool for Genome-wide Complex Trait Analysis includes plink "
LABEL about.tags="Genomics"
LABEL about.provides="gcta 1.93.2"

################## BEGIN INSTALLATION ######################

ENV ZIP=gcta_1.93.2_src.zip
ENV URL=https://cnsgenomics.com/software/gcta/
ENV DST=/home/biodocker/bin

RUN wget $URL/$ZIP -O $DST/$ZIP && \
    unzip $DST/$ZIP -d $DST && \
    rm $DST/$ZIP

ENV PLINKZIP=plink_linux_x86_64_20181202.zip
ENV PLINKURL=http://s3.amazonaws.com/plink1-assets

RUN wget $PLINKURL/$PLINKZIP -O $DST/$PLINKZIP && \
    unzip $DST/$PLINKZIP -d $DST && \
    rm $DST/$PLINKZIP

##### Scripts used in gcta analyses
RUN cd /home/biodocker/ && \
	git clone https://github.com/akmanning/genomewide_heritability.git && \
	cd genomewide_heritability && \
	git pull origin master

##################### INSTALLATION END #####################

# File Author / Maintainer
MAINTAINER Alisa Manning <amanning@broadinstitute.org>
