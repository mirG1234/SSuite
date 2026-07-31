#!/usr/bin/env nextflow

process QUAST {

        // define container image
        //container "oras://community.wave.seqera.io/library/quast:5.3.0--bfd4c029fde7e696"
        container "file://${params.apptainer_dir}/quast.sif"
        publishDir "${params.outdir}/quast", mode: 'copy'

        input:
        tuple val(sample_id), path(contigs)

        output:
        tuple val(sample_id), path("${sample_id}_assembly_QC/*"), emit: results

        script:
        """
        ## create new wd for indiv. output
        mkdir -p "${sample_id}_assembly_QC"

        metaquast.py \
          ${contigs} \
          -o "${sample_id}_assembly_QC" \
          --min-contig 1 \
          --threads ${task.cpus}
        """
}
