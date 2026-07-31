#!/usr/bin/env nextflow

process FILTER_CONTIGS {

    publishDir "${params.outdir}/filtered_assemblies", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_filtered.fasta"), emit: filtered_contigs

    script:
    // Uses awk to set the Record Separator to ">" for easy length counting
    """

    # Log the original count
    echo "Sample: ${sample_id} - Original contig count: \$(grep -c '^>' ${assembly})"

    awk -v min_len=${params.min_contig_length} '
        BEGIN { RS = ">"; ORS = "" }
        NR > 1 {
            # Extract header and sequence
            header = \$1
            sequence = \$0
            sub(/^[^\\n]*\\n/, "", sequence) # Strip header line
            gsub(/\\n/, "", sequence)        # Strip all newlines from sequence

            # Check length of the clean sequence
            if (length(sequence) >= min_len) {
                print ">" \$0
            }
        }
    ' ${assembly} > ${sample_id}_filtered.fasta

    # Log the new count
    echo "Sample: ${sample_id} - Filtered contig count (Floor: ${params.min_contig_length}bp): \$(grep -c '^>' ${sample_id}_filtered.fasta)"

    """
}
