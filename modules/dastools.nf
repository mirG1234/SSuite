#!/usr/bin/env nextflow

process DASTOOLS {

        // define container image
        container "file://${params.apptainer_dir}/dastools.sif"
        publishDir "${params.outdir}/dastools", mode: 'copy'

        input:
        tuple val(sample_id), path(contigs), path(bins_tsv)

        output:
        path "${sample_id}_DASTool_summary.tsv", emit: summary
        path "${sample_id}_DASTool_contigs2bin.tsv", optional: true, emit: contigs2bin
        tuple val(sample_id), path("${sample_id}_DASTool_bins"), emit: refined_bins

        script:
        def input_tsv_list = bins_tsv.join(',')
        def label_string = params.binners.join(',')
        """
        DAS_Tool -i ${input_tsv_list} \
             -c ${contigs} \
             -l ${label_string} \
             -o "${sample_id}" \
             --write_bins \
             --threads ${task.cpus}

        """
}

