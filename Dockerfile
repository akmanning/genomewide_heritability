############################# Dockerfile ####################################
FROM biocontainers/biocontainers:v1.0.0_cv4

######################## METADATA ###########################################

LABEL base_image="biocontainers:v1.0.0_cv4"
LABEL version="2"
LABEL software="gcta"
LABEL software.version="1.91.7beta"
LABEL about.summary="A tool for Genome-wide Complex Trait Analysis includes plink "
LABEL about.tags="Genomics"
LABEL about.provides="gcta 1.91.7beta"

################## BEGIN INSTALLATION ######################

ENV ZIP=gcta_1.91.7beta.zip
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

# CHANGE WORKDIR TO /DATA
WORKDIR /data

# DEFINE DEFAULT COMMAND
CMD ["gcta64"]

##################### INSTALLATION END #####################

# File Author / Maintainer
MAINTAINER Alisa Manning <amanning@broadinstitute.org>
