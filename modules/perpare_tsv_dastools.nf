#!/usr/bin/env nextflow

process PREPARE_TSV_DASTOOLS {

    container "file://${params.apptainer_dir}/dastools.sif"
    publishDir "${params.outdir}/dastools/tsv", mode: 'copy'

    input:
    tuple val(sample_id), path(binner_folders)
    val binning_methods

    output:
    tuple val(sample_id), path("${sample_id}_*_contig2bin.tsv"), emit: tsv

    script:
    """
    # Loop through each folder provided in the list
    for dir in ${binner_folders}; do
        if [ -d "\$dir" ]; then

            #  ^=^z^` Pure Bash Fix: Trim the front and back of the folder path cleanly
            # 1. Strip everything up to the sample ID prefix (e.g. removes paths)
            base_dir=\$(basename "\$dir")

            # 2. Strip 'CHG2098_S292_' from the front
            tmp=\${base_dir#${sample_id}_}

            # 3. Strip '_standard_bins' from the back, leaving ONLY the binner name
            binner_name=\${tmp%_standard_bins}

            # 2. Run the helper script on this specific binner folder
            # Since everything was standardized by our helper tool, the extension is always 'fa'
            Fasta_to_Contig2Bin.sh \
                -i "\$dir" \
                -e fa \
                > ${sample_id}_\${binner_name}_contig2bin.tsv

        fi
    done
    """
}
