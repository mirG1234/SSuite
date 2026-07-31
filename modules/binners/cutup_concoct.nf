#!/usr/bin/env nextflow

process CUTUP_CONCOCT {

    container "file://${params.apptainer_dir}/concoct.sif"

    input:
    tuple val(sample_id), path(fasta)

    output:
    tuple val(sample_id), path("${sample_id}_10K.fa"), emit: cutup_fa
    tuple val(sample_id), path("${sample_id}_10K.bed"), emit: cutup_bed

    script:

    """
    # Cut up the assembly into 10KB fragments
    cut_up_fasta.py ${fasta} \
        -c 10000 \
        -o 0 \
        --merge_last \
        -b "${sample_id}_10K.bed" > "${sample_id}_10K.fa" ## outputs a BED file mapping fragments to original contig names
    """
}
