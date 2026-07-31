#!/usr/bin/env nextflow

process BOWTIE2 {

    container "oras://community.wave.seqera.io/library/bowtie2:2.5.4--2ec535d45cd82f0b"
    //container "file://${params.apptainer_dir}/bowtie2.sif"
    publishDir "${params.outdir}/bowtie2", mode: 'symlink'

    input:
    tuple path(read1), path(read2)
    path index_zip

    output:
    tuple path("*_1.fastq.gz"), path("*_2.fastq.gz"), emit: decontam_reads

    script:

    """
    tar -xzvf $index_zip
    bowtie2 -x ${index_zip.simpleName} \
    -1 ${read1} -2 ${read2} \
    --very-sensitive-local \
    --un-conc-gz non_human_reads \
    -p 10 \
    -S /dev/null
    
    """
}
