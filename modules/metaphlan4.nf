#!/usr/bin/env nextflow

process METAPHLAN4 {

    //container "community.wave.seqera.io/library/metaphlan:4.1.1--7ee0a2cf07a38170"
    container "file://${params.apptainer_dir}/metaphlan4.sif"
    publishDir "${params.outdir}/metaphlan4", mode: 'copy'

    input:
    tuple val(sample_id), path(read1), path(read2)
    path index_zip

    output:
    tuple val(sample_id), path("*.taxprofile"), emit: taxa_profile
    path("*.bowtie2.bz2"), emit: bowtie2out

    script:
    """
    tar -xzvf $index_zip
    metaphlan ${read1},${read2} \
    --bowtie2db ${index_zip.simpleName} \
    -x mpa_vOct22_CHOCOPhlAnSGB_202403 -t rel_ab_w_read_stats \
    --unclassified_estimation --add_viruses \
    --input_type fastq -o ${sample_id}.taxprofile \
    --bowtie2out ${sample_id}.bowtie2.bz2 --nproc 10
    
    """
}

//metaphlan RAW/SRR14076335_1.fastq.gz --input_type fastq -s SAMS/SRR14076335.sam.bz2 
// --bowtie2out BOWTIE2/SRR14076335.bowtie2.bz2 
// -o BUGS/SRR14076335_profile.tsv --add_viruses 
// --unclassified_estimation  --index mpa_vOct22_CHOCOPhlAnSGB_202403 
// --bowtie2db ./CHOCO/ -t rel_ab_w_read_stats --nproc 6 
