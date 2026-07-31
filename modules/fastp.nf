#!/usr/bin/env nextflow

process FASTP {

    //container "community.wave.seqera.io/library/fastp:0.24.1--6214360065b44e0b"
    container "file://${params.apptainer_dir}/fastp.sif"
    publishDir "${params.outdir}/fastp", mode: 'symlink'

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("*.T.R1.fastq"), path("*.T.R2.fastq"), emit: trimmed_reads
    path "*.fastp.html", emit: html_report

    script:
    """
    fastp -i ${reads[0]} -I ${reads[1]} \
        -o ${sample_id}.T.R1.fastq \
        -O ${sample_id}.T.R2.fastq \
        --thread 8 --html ${sample_id}.fastp.html

    """
}
