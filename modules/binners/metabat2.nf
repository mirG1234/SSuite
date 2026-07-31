#!/usr/bin/env nextflow

process METABAT2 {

        // define container image
        // container "oras://community.wave.seqera.io/library/metabat2:2.18--e67c47d4c0457dda"
        container "file://${params.apptainer_dir}/metabat2.sif"
        publishDir "{params.outdir}/metabat2_bins", mode: 'copy'

        input:
        // Joined channel: [Sample_A, Sample_A_assembly.fasta, Sample_A_depth.txt]
        tuple val(sample_id), path(contigs), path(depth_file)

        output:
        tuple val(sample_id), path("${sample_id}.metabat2.*.fa*"), emit: bins

        script:
        """
        metabat2 \
            -i ${contigs} \
            -a ${depth_file} \
            -o ${sample_id}.metabat2 \
            -t ${task.cpus}

        """
}
