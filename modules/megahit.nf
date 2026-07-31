#!/usr/bin/env nextflow

process MEGAHIT {

        // define container image
        container "file://${params.apptainer_dir}/megahit.sif"
        publishDir "${params.outdir}/megahit", mode: 'copy'

        input:
        tuple val(sample_id), path(reads)

        output:
        tuple val(sample_id), path("${sample_id}_output/*.contigs.fa"), emit: contigs
        path "${sample_id}_output/*.log", emit: log

        script:
        """
        megahit -1 ${reads[0]} -2 ${reads[1]} \
                -o ${sample_id}_output --out-prefix ${sample_id} \
                -t ${task.cpus}

        """
}
