#!/usr/bin/env nextflow

process COMEBIN {

        // define container image
        // container "oras://community.wave.seqera.io/library/comebin:1.0.4--12fdcf0118ec044d"
        container "file://${params.apptainer_dir}/comebin.sif"
        publishDir "${params.outdir}/comebin", mode: 'copy'

        input:
        tuple val(sample_id), path(bams), path(bais), path(contigs)

        output:
        tuple val(sample_id), val("comebin"), path("${sample_id}_comebin_bins/comebin_res/comebin_res_bins/*.fa*"), emit: bins

        script:
        def out_dir = "${sample_id}_comebin_bins"
        def bin_dir = "${out_dir}/bins"
        """
        # Create the output directory before running comebin
        mkdir -p "${out_dir}"

         # Get absolute paths for inputs and outputs
        FASTA_ABS=\$(realpath "${contigs}")
        BAM_DIR_ABS=\$(realpath .)
        OUT_DIR_ABS=\$(realpath "${out_dir}")

        # Change into the tool's directory so it can find 'main.py'
        cd /usr/local/bin/COMEBin/

        bash run_comebin.sh \
            -a "\${FASTA_ABS}" \
            -p "\${BAM_DIR_ABS}" \
            -o "\${OUT_DIR_ABS}" \
            -t ${task.cpus}
             # > "\${OUT_DIR_ABS}/comebin.log" 2>&1

        """
}
