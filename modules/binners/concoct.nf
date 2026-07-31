#!/usr/bin/env nextflow

process CONCOCT {

        // define container image
        // container "oras://community.wave.seqera.io/library/concoct:1.1.0--076c81fe6e260a99"
        container "file://${params.apptainer_dir}/concoct.sif"
        publishDir "${params.outdir}/concoct", mode: 'copy'

        input:
        tuple val(sample_id), path(original_fasta), path(cutup_fasta), path(coverage_table)

        output:
        tuple val(sample_id), val("concoct"), path("${sample_id}_concoct_bins/${sample_id}.concoct.*.fa*"), emit: bins
        tuple val(sample_id), path("${sample_id}_concoct_results/clustering_gt1000.csv"), emit: clustering

        script:
        def out_dir = "${sample_id}_concoct_bins"
        """
        ## create directories to keep results and bins separate
        mkdir ${sample_id}_concoct_results
        mkdir ${out_dir}

        # Run the binner to get the clustering CSV
        concoct \
            --composition_file ${cutup_fasta} \
            --coverage_file ${coverage_table} \
            -b ${sample_id}_concoct_results/ \
            -t ${task.cpus}

        # 2. Combine fragments back to the original IDs using the native tool
        merge_cutup_clustering.py \
            ${sample_id}_concoct_results/clustering_gt1000.csv \
            > ${sample_id}_concoct_results/clustering_merged.csv

        # 2a. cleanup headers of original fasta
        sed 's/ .*//' ${original_fasta} > clean_original.fasta

        # Extract the actual FASTA bins from the original assembly
        extract_fasta_bins.py \
            clean_original.fasta \
            ${sample_id}_concoct_results/clustering_merged.csv \
            --output_path ${out_dir}

        # 3. Standardize bin file names inside out_dir to include sample information
        cd ${out_dir}
        for f in *.fa; do
            if [ -f "\$f" ]; then
                # Extracts the bin number (e.g., from '1.fasta' it grabs '1')
                bin_num=\${f%.*}
                # Renames it cleanly to: CHG2098_S292.concoct.bin.1.fa
                mv "\$f" "${sample_id}.concoct.bin.\${bin_num}.fa"
            fi
        done

        """
}
