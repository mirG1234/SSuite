#!/usr/bin/env nextflow

process BWAMEM2 {

    //container "community.wave.seqera.io/library/bwa-mem2_samtools:b7ce408fd27b2698"
    container "file://${params.apptainer_dir}/bwamem2.sif"
    publishDir "${params.outdir}/bwa-mem2", mode: 'symlink'

    input:
    tuple val(sample_id), path(read1), path(read2)
    path index_zip

    output:
     tuple val(sample_id), path("${sample_id}_D_R{1,2}.fastq.gz"), emit: decontam_reads

    script:
    """
    tar -xzvf $index_zip
    bwa-mem2 mem -t 10 ${index_zip.simpleName}.fa \
    ${read1} ${read2} | samtools view -@ 10 -b \
    -f 12 -F 256 - | samtools sort -n -@ 10 - | samtools fastq -@ 10 \
    -1 ${sample_id}.D.R1.fastq -2 ${sample_id}.D.R2.fastq \
    -0 /dev/null -s /dev/null -n -
    
    """
}

//-f 12 -F 256 - | samtools sort -n -@ 10 - | samtools fastq -@ 10 \
