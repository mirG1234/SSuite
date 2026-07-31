#!/usr/bin/env nextflow

process MAXBIN2 {

        // define container image
        // container "oras://community.wave.seqera.io/library/maxbin2:2.2.7--972ca9f8c80a9705"
        container "file://${params.apptainer_dir}/maxbin2.sif"
        publishDir "${params.outdir}/maxbin2_bins", mode: 'copy'

        input:
        tuple val(sample_id), path(contigs), path(abund_list), path(abund_files)

        output:
        tuple val(sample_id), val("maxbin2"), path("${sample_id}_maxbin2_bins/${sample_id}.*.fa*"), emit: bins

        script:
        def out_dir = "${sample_id}_maxbin2_bins"
        """
        ## create sub-directory
        mkdir ${out_dir}

        run_MaxBin.pl \
            -thread ${task.cpus} \
            -contig ${contigs} \
            -abund_list ${abund_list} \
            -out ${out_dir}/${sample_id}
        """
}
