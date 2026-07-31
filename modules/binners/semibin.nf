#!/usr/bin/env nextflow

process SEMIBIN {


        // define container image
        // container "oras://community.wave.seqera.io/library/semibin:2.2.1--d6d6a5cd200043a3"
        container "file://${params.apptainer_dir}/semibin.sif"
        publishDir "${params.outdir}/semibin", mode: 'copy'

        input:
        tuple val(sample_id), path(bams), path(bais), path(contigs)

        output:
        tuple val(sample_id), val("semibin"), path("${sample_id}_semibin_bins/output_bins/${sample_id}.semibin.*.fa*"), emit: bins
        path "semibin2.log", emit: log

        script:
        def out_dir = "${sample_id}_semibin_bins"
        """
        SemiBin2 single_easy_bin \
                --input-fasta ${contigs} \
                --input-bam ${bams} \
                --output ${out_dir} \
                --threads ${task.cpus} \
                --self-supervised \
                ## redirect standard output and error to log
                > semibin2.log 2>&1
        """
}
