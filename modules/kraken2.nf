#!/usr/bin/env nextflow

process KRAKEN2 {

    //container "community.wave.seqera.io/library/kraken2:2.1.5--2bd828274d201d82"
    container "file://${params.apptainer_dir}/kraken2.sif"
    publishDir "${params.outdir}/kraken2", mode: 'copy'

    input:
    tuple val(sample_id), path(read1), path(read2)
    path index_zip

    output:
    tuple val(sample_id), path("${sample_id}_D_R{1,2}.fastq"), emit: decontam_reads
    tuple val(sample_id), path("${sample_id}_C_R{1,2}.fastq"), emit: contam_reads

    script:
    """
    tar -xzvf $index_zip

    kraken2 --db ${index_zip.simpleName} \
        --paired ${read1} ${read2} \
        --use-names \
        --threads 10 \
        --output ${sample_id}.names \
        --report ${sample_id}.report \
        --unclassified-out ${sample_id}_D_R#.fastq \
        --classified-out ${sample_id}_C_R#.fastq
    
    """
}

//    extract_kraken_reads.py -k ${read1.simpleName}.names --report ${read1.simpleName}.report \
//    -s1 ${read1} -s2 ${read2} \
//    -o ${read1.simpleName}.D.R1.fq -o2 ${read2.simpleName}.D.R2.fq \
//    --taxid 9606 --exclude --fastq-output
