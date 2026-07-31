#!/usr/bin/env nextflow

process METABINNER {

        // define container image
        // container "oras://community.wave.seqera.io/library/metabinner:1.4.4--f8cf05c1ca43286d"
        container "file://${params.apptainer_dir}/metabinner.sif"
        publishDir "${params.outdir}/metabinner", mode: 'copy'

        input:
        tuple val(sample_id), path(contigs), path(coverage), path(kmer)

        output:
        tuple val(sample_id), path("${sample_id}_metabinner_bins/metabinner_res/metabinner_result.tsv"), emit: result_tsv

        script:
        def args = task.ext.args ?: ''
        def out_dir = "${sample_id}_metabinner_bins"
        """
        set -e

        # 1. Create the local output directory first
        rm -rf "${out_dir}"
        mkdir -p "${out_dir}"

        # 2. Convert it to an absolute path so MetaBinner doesn't drift into /usr/local/bin
        CONTIGS_ABS=\$(realpath "${contigs}")
        COVERAGE_ABS=\$(realpath "${coverage}")
        KMER_ABS=\$(realpath "${kmer}")
        OUT_DIR_ABS=\$(realpath "${out_dir}")
        NEXTFLOW_TASK_DIR=\$(realpath .)

        # Dynamically locate MetaBinner package path inside container
        METABINNER_PATH=\$(dirname \$(which run_metabinner.sh))

        run_metabinner.sh \
            -a "\${CONTIGS_ABS}" \
            -d "\${COVERAGE_ABS}" \
            -k "\${KMER_ABS}" \
            -t ${task.cpus} \
            -o "\${OUT_DIR_ABS}" \
            -p \$METABINNER_PATH \
            ${args} ## scale argument in config file (if different from default)

        """
}
