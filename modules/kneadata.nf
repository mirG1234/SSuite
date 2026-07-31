#!/usr/bin/env nextflow

process KNEADDATA {

    //container "community.wave.seqera.io/library/fastqc_kneaddata_trimmomatic:f596e5c86f298d72"
    container "file://${params.apptainer_dir}/kneadata.sif"
    publishDir "${params.outdir}/kneaddata", mode: 'symlink'

    input:
    tuple path(read1), path(read2)
    path index_zip

    output:
    tuple path("*_kneaddata_paired_1.fastq"), 
    path("*_kneaddata_paired_2.fastq"), emit: decontam_reads

    script:

    """
    tar -xzvf $index_zip
    kneaddata -t 10 -db ${index_zip.simpleName} \
    --input1 ${read1} --input2 ${read2} \
    --output ./ --bypass-trim
    
    """
}

//kneaddata --input1 /dbs/IMG146_S97.T.R1.fastq \
// --input2 /dbs/IMG146_S97.T.R2.fastq \
// -db /dbs/hg37_kneaddata --output kneaddata_output \
// --fastqc kneaddata_fastqc --bypass-trim

//kneaddata --input1 /dbs/IMG146_S97.T.R1.fastq --input2 /dbs/IMG146_S97.T.R2.fastq 
// -db /dbs/hg37_kneaddata 
//--output kneaddata_output --fastqc kneaddata_fastqc --bypass-trim
