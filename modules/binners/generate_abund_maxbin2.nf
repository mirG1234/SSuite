#!/usr/bin/env nextflow

process GENERATE_ABUND_MAXBIN2 {

   // define container image
        container "file://${params.apptainer_dir}/samtools.sif"
        publishDir "${params.outdir}/maxbin2", mode: 'copy'

    input:
    tuple val(sample_id), path(bam_files), path(bai_files)

    output:
    tuple val(sample_id), path("${sample_id}_abund_list.txt"), path("*.abund"), emit: abund_list

    script:
    """
    # Force the process to crash if samtools or awk fails, instead of failing silently
    set -e
    set -o pipefail

    # Handle multiple BAM inputs robustly by iterating over the file system
    # rather than risking Nextflow string variable substitution bugs
    for bam in *.bam; do
        # 1. Generate index stats
        # 2. Compute abundance: (Mapped Reads / Contig Length)
        samtools idxstats "\${bam}" | awk 'NF && \$1 != "*" {
            abundance = (\$2 > 0) ? (\$3 / \$2) : 0;
            print \$1 "\\t" abundance
        }' > "\${bam}.abund"
    done

    ls *.abund > "${sample_id}_abund_list.txt"
    """
}
