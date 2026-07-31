#!/usr/bin/env nextflow

process CHECKM2 {

        // define container image
        // container "oras://community.wave.seqera.io/library/checkm2:1.1.0--450784eb7a60b7bf"
        container "file://${params.apptainer_dir}/checkm2.sif"
        publishDir "${params.outdir}/checkm2/${label}", mode: 'copy'

        input:
        tuple val(sample_id), path(bins_dir)
        val label

        output:
        tuple val(sample_id), path("${sample_id}_*_checkm2_res/*"), emit: results


        script:
        """
        FIRST_FILE=\$(ls ${bins_dir} | head -n 1)
        EXT=\${FIRST_FILE##*.}


        ## extract binner name from input (if not received from dastools)
        base_dir=\$(basename "${bins_dir}")
        if [[ "\$base_dir" == *"dastool"* ]]; then
            binner_name="dastool"
        else
            tmp=\${base_dir#${sample_id}_}
            binner_name=\${tmp%_standard_bins}
        fi

        checkm2 predict --threads ${task.cpus} \
                    --input ${bins_dir} \
                    -x \${EXT} \
                    --output-directory "${sample_id}_\${binner_name}_checkm2_res" \
                    --database_path ${params.checkm2_db}
        """
}

