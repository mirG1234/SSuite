#!/usr/bin/env nextflow

process BOWTIE2_BUILD {

    // define container image
    //container "community.wave.seqera.io/library/bowtie2:2.5.4--d51920539234bea7"
    container "file://${params.apptainer_dir}/bowtie2.sif"
    publishDir "${params.outdir}/bowtie2", mode: 'copy'

    input:
    tuple val(sample_id), path(contigs)

    output:
    tuple val(sample_id), path("*.bt2"), emit: index

    script:
    """
    bowtie2-build --threads ${task.cpus} ${contigs} ${sample_id}
    """
}
