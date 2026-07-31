#!/usr/bin/env nextflow

process HUMANN4 {

    //container "sshekarriz/humann:4.0.0.a.1"
    container "file://${params.apptainer_dir}/humann4.sif"
    publishDir "${params.outdir}/humann4", mode: 'copy'

    input:
    tuple val(sample_id), path(read1), path(read2), path(taxprofile)
    path index_zip

    output:
    path("*.log"), emit: logfile_output
    path("*_genefamilies.tsv"), emit: genefamilies_profile
    path("*_reactions.tsv"), emit: reaction_profile
    path("*_pathabundance.tsv"), emit: pathabundance_profile

    script:
    """
    tar -xzvf $index_zip
    humann -i ${read1} --taxonomic-profile ${taxprofile} --input-format fastq \
    --nucleotide-database ${index_zip.simpleName}.0.0a1/chocophlan \
    --protein-database ${index_zip.simpleName}.0.0a1/uniref --bypass-translated-search \
    --utility-database ${index_zip.simpleName}.0.0a1/utility_mapping \
    --threads 10 -o ./

    """
}

//  --bypass-translated-search
//humann --input ./RAW/SRR14076335_1.fastq.gz  --taxonomic-profile ./BUGS/SRR14076335_profile.tsv  
//--output ./FromBUGS/  --nucleotide-database "./HUMANn/chocophlan" --threads 2
