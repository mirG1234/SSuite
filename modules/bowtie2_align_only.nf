#!/usr/bin/env nextflow

process BOWTIE2_ALIGN_ONLY {

    //container "community.wave.seqera.io/library/bowtie2:2.5.4--d51920539234bea7"
    container "file://${params.apptainer_dir}/bowtie2.sif"
    publishDir "${params.outdir}/bowtie2/sample_id", mode: 'copy'

    // NOTE: SAMPLE_ID CORRESPONDS TO CONTIG or ASSEMBLY ID
    input:
    tuple val(sample_id), path(index_files), val(reads_id), path(reads)

    output:
    tuple val(sample_id), val(reads_id), path("${sample_id}_vs_${reads_id}.sam"), emit: sam

    script:
    """
    bowtie2 -p ${task.cpus} \
        -x ${sample_id} \
        -1 ${reads[0]} -2 ${reads[1]} \
        -S ${sample_id}_vs_${reads_id}.sam
    """
}
