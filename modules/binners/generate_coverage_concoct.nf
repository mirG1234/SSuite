#!/usr/bin/env nextflow

process GENERATE_COVERAGE_CONCOCT {

    //define container image
        // container "oras://community.wave.seqera.io/library/concoct:1.1.0--076c81fe6e260a99"
        container "file://${params.apptainer_dir}/concoct.sif"
        publishDir "${params.outdir}/concoct", mode: 'copy'

    input:
    tuple val(sample_id), path(bed), path(bams), path(bais)

    output:
    tuple val(sample_id), path("${sample_id}_concoct_coverage.tsv"), emit: coverage

    script:
    """
    # Generate the coverage table from the BAM files using the BED file
    concoct_coverage_table.py \
        ${bed} \
        *.bam > "${sample_id}_concoct_coverage.tsv"
    """
}
