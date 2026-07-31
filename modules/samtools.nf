#!/usr/bin/env nextflow

process SAMTOOLS {

    //container "community.wave.seqera.io/library/bowtie2:2.5.4--d51920539234bea7"
    container "file://${params.apptainer_dir}/samtools.sif"
    publishDir "${params.outdir}/samtools/sample_id", mode: 'copy'

    // NOTE: SAMPLE_ID CORRESPONDS TO CONTIG/ASSEMBLY ID
    input:
    tuple val(sample_id), val(reads_id), path(sams)

    output:
    tuple val(sample_id), path("${prefix}.sorted.bam"), path("${prefix}.sorted.bam.bai"), emit: bam_with_index

    script:
    prefix = "${sample_id}_vs_${reads_id}"
    """
    ## generate sorted .bam and .bai files (indexed)
    samtools sort -@ ${task.cpus} \
        -o ${prefix}.sorted.bam \
        ${prefix}.sam

    # Index the final sorted BAM file
    samtools index "${prefix}.sorted.bam"
    """
}
