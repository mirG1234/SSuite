#!/usr/bin/env nextflow

process GENERATE_COVERAGE_METABINNER {

    // define container image
        // container "oras://community.wave.seqera.io/library/metabinner:1.4.4--f8cf05c1ca43286d"
        container "file://${params.apptainer_dir}/metabinner.sif"
        publishDir "${params.outdir}/metabinner", mode: 'copy'

    input:
    tuple val(sample_id), path(depth_file)

    output:
    tuple val(sample_id), path("${sample_id}_coverage.tsv"), emit: coverage

    script:
    """
    # gen_coverage_file.sh handles the conversion from JGI depth format
    # gen_coverage_file.sh ${depth_file} ${sample_id}_coverage.tsv

    # 1. Keeps the header row (NR==1) OR any row where column 2 (length) is >= 1000bp
    # 2. Slices out column 1 (Contig ID) and column 4 through the end (Raw Coverages)
    awk '{if (NR==1 || \$2 >= 1000) print \$0}' ${depth_file} | cut -f 1,4- > ${sample_id}_coverage.tsv

    """
}
