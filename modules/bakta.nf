#!/usr/bin/env nextflow

process BAKTA {

        // define container image
        // container: "oras://community.wave.seqera.io/library/bakta:1.11.4--733db51190e0baa3"
        container "file://${params.apptainer_dir}/bakta.sif"
        publishDir "${params.outdir}/bakta", mode: 'copy'

        input:
        tuple val(sample_id), path(contigs)

        output:
        path "${sample_id}_bakta/*", emit: results

        script:
        // define external command line arguments from config file
        def args = task.ext.args ?: ''
        """
        bakta \
            --db ${params.bakta_db} \
            --prefix ${sample_id} \
            --output "${sample_id}_bakta" \
            --threads ${task.cpus} \
            $args \
            $contigs
        """
}
