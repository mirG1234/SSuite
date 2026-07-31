#!/usr/bin/env nextflow

process PROKKA {

        // define container image
        // container: "oras://community.wave.seqera.io/library/prokka:1.15.6--e5028fc3f228f99c"
        container "file://${params.apptainer_dir}/prokka.sif"
        publishDir "${params.outdir}/prokka", mode: 'copy'

        input:
        tuple val(sample_id), path(contigs)

        output:
        path "${sample_id}_prokka/*", emit: results

        script:
        """
         prokka \
            --outdir "${sample_id}_prokka" \
            --prefix ${sample_id} \
            --cpus ${task.cpus}
            ${contigs}
        """
}
