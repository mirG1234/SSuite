#!/usr/bin/env nextflow

process GTDBTK {

        // define container image
        // container: "oras://community.wave.seqera.io/library/gtdbtk:2.6.1--d45d7510d9b62e44"
        container "file://${params.apptainer_dir}/gtdbtk.sif"
        publishDir "${params.outdir}/gtdbtk", mode: 'copy'

        input:
        tuple val(sample_id), path(bins_dir)

        output:
        tuple val(sample_id), path("${sample_id}_GTDBK/*"), emit: results

        script:
        """
        # Export the environment variable directly within the execution shell
        export GTDBTK_DATA_PATH="${params.gtdbtk_db}"

        # detect the bin extension (.fa or .fasta) inside the folder
        FIRST_FILE=\$(ls ${bins_dir} | head -n 1)
        EXT=\${FIRST_FILE##*.}

        gtdbtk classify_wf \
                --genome_dir ${bins_dir} \
                --out_dir "${sample_id}_GTDBK" \
                --cpus ${task.cpus} \
                -x \${EXT} \
                --force
        """
}

