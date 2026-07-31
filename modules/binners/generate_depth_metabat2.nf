#!/usr/bin/env nextflow

process GENERATE_DEPTH_METABAT2 {

    // define container image
        // container "oras://community.wave.seqera.io/library/metabat2:2.18--e67c47d4c0457dda"
        container "file://${params.apptainer_dir}/metabat2.sif"
        publishDir "${params.outdir}/metabat2_bins", mode: 'copy'

    input:
    tuple val(sample_id), path(bam_files), path(bai_files)

    output:
    tuple val(sample_id), path("${sample_id}_depth.txt"), emit: depth

    script:
    """
         jgi_summarize_bam_contig_depths \
            --outputDepth ${sample_id}_depth.txt \
            ${bam_files}
    """
}
