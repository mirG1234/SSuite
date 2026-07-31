#!/usr/bin/env nextflow

process STANDARDIZE_BINS {
    tag "${sample_id} - ${binner}"

    publishDir "${params.outdir}/standardized_bins", mode: 'copy'

    input:
    tuple val(sample_id), val(binner), path(raw_bins)

    output:
    tuple val(sample_id), path("${sample_id}_${binner}_standard_bins"), emit: bins

    script:
    def out_dir = "${sample_id}_${binner}_standard_bins"
    """
    mkdir -p ${out_dir}

    # Track bin count to keep numbering clean
    count=1

    for f in ${raw_bins}; do
        if [ -f "\$f" ]; then
            # Copy file into the new folder with a perfectly uniform name
            cp "\$f" "${out_dir}/${sample_id}.${binner}.bin.\${count}.fa"
            count=\$((count + 1))
        fi
    done
    """
}
