#!/usr/bin/env nextflow

// Module INCLUDE statements (main modules)

// read mapping
include { BOWTIE2_BUILD } from './modules/bowtie2_build.nf'
include { BOWTIE2_ALIGN_ONLY } from './modules/bowtie2_align_only.nf'
include { SAMTOOLS } from './modules/samtools.nf'

// binners
include { COMEBIN } from './modules/comebin.nf'
include { SEMIBIN } from './modules/semibin.nf'
include { MAXBIN2 } from './modules/maxbin2.nf'
include { BINNY } from './modules/binny.nf'
include { METABAT2 } from './modules/metabat2.nf'
include { METABINNER } from './modules/metabinner.nf'
include { CONCOCT } from './modules/concoct.nf'

// bin QC and annotation
include { CHECKM2 as CHECKM2_RAW } from './modules/checkm2.nf'
include { CHECKM2 as CHECKM2_REFINED } from './modules/checkm2.nf'
include { DASTOOLS } from './modules/dastools.nf'
include { GTDBTK } from './modules/gtdbtk.nf'
include { MULTIQC } from './modules/multiqc.nf'

// binning helper modules)
include { GENERATE_ABUND_MAXBIN2 } from './modules/generate_abund_maxbin2.nf'
include { GENERATE_DEPTH_METABAT2 as GENERATE_DEPTH_METABAT2 } from './modules/generate_depth_metabat2.nf'
include { GENERATE_DEPTH_METABAT2 as GENERATE_DEPTH_METABINNER } from './modules/generate_depth_metabat2.nf'
include { GENERATE_COVERAGE_METABINNER } from './modules/generate_coverage_metabinner.nf'
include { GENERATE_KMERS_METABINNER } from './modules/generate_kmers_metabinner.nf'
include { PARSE_FASTA_METABINNER } from './modules/parse_fasta_metabinner.nf'
include { GENERATE_COVERAGE_CONCOCT } from './modules/generate_coverage_concoct.nf'
include { CUTUP_CONCOCT } from './modules/cutup_concoct.nf'
include { STANDARDIZE_BINS } from './modules/standardize_bins.nf'
include { PREPARE_TSV_DASTOOLS } from './modules/prepare_tsv_dastools.nf'


// ========================================== MAIN WORKFLOW ================================================//

workflow {

    /*
     * ASSEMBLY AND READS IMPORT
     */

    // Create ASSEMBLY input channel (format [sample_id, contigs])
    contigs_ch = Channel.fromPath(params.input_csv)
        .splitCsv(header:true)
        .map { row ->
                // Define the ID and the Reads based on column headers
                def sample_id = row.sample_id
                def contigs = file(row.assembly)

                // Return the clean tuple structure
                return [ sample_id, contigs ]
        }

     // Create READS input channel (format [sample_id, reads])
    decontam_reads_ch = Channel.fromPath(params.input_csv)
        .splitCsv(header:true)
        .map { row ->
                // Define the ID and the Reads based on column headers
                def sample_id = row.sample_id
                def reads = [ file(row.fastq_DR1), file(row.fastq_DR2) ]

                // Return the clean tuple structure
                return [ sample_id, reads ]
        }

// ========================================================================================================= //


    /*
     * READ CROSS-MAPPING
     */

    // build index from contigs for every sample: [ sample_id, contigs ]
    BOWTIE2_BUILD(contigs_ch)

    // Cross-mapping: Generate every assembly-read pair (all builds vs all read channels)
    // in the form [ assembly_id, [index_files], read_id, [reads] ]
    cross_mapping_ch = BOWTIE2_BUILD.out.index.combine(decontam_reads_ch)

    // align reads to index (all reads to all assemblies)
    BOWTIE2_ALIGN_ONLY(cross_mapping_ch)

    // feed sams into samtools
    SAMTOOLS(BOWTIE2_ALIGN_ONLY.out.sam)

    // GROUP BAMS AND BAIS BY SAMPLE_ID
    // Input format: [sample_id, bam, bai]
    // Output format: [sample_id, [bam1, bam2, ..., bamN], [bai1, bai2, ..., baiN]]
    grouped_bams_ch = SAMTOOLS.out.bam_with_index
                      .groupTuple(by: 0)

    // join bam files with their corresponding sample contigs to preserve ID match
    contigs_cross_mapped_bams_ch = grouped_bams_ch.join(contigs_ch)


// ========================================================================================================= //

    /*
     * BINNING
     */

    // initialize empty list for binner results
    // binner_outputs_ch = Channel.empty()
    def active_binner_channels = []

    // run binning module
    if (params.binners.contains('comebin')) {

        // run binning on id-joined contigs and bams
        COMEBIN(contigs_cross_mapped_bams_ch)
        active_binner_channels << COMEBIN.out.bins

    }

    if (params.binners.contains('semibin')){

        // run binning on id-joined contigs and bams
        SEMIBIN(contigs_cross_mapped_bams_ch)
        active_binner_channels << SEMIBIN.out.bins

    }

    if (params.binners.contains('maxbin2')){

        // run abundance assembly
        // use bam files joined with sample_id
        GENERATE_ABUND_MAXBIN2(grouped_bams_ch)

        // join with original contig files by id
        maxbin_input_ch = contigs_ch.join(GENERATE_ABUND_MAXBIN2.out.abund_list)

        // run binning on id-tagged contigs w/ abundance files
        MAXBIN2(maxbin_input_ch)
        active_binner_channels << MAXBIN2.out.bins

    }

    if (params.binners.contains('metabat2')){

        // generate depth file using internal helper function
        // use sorted .bam files and reference fasta (contig catalog)
        GENERATE_DEPTH_METABAT2(grouped_bams_ch)
        depth_ch = GENERATE_DEPTH_METABAT2.out.depth

        // join contigs with depth files
        metabat_input = contigs_ch.join(depth_ch)

        // run binning on id-tagged contigs with depth file from previous step
        METABAT2(metabat_input)
        active_binner_channels << METABAT2.out.bins

    }

    if (params.binners.contains('metabinner')){

        // use depth file from previous metabat2 module to calculate coverage
        GENERATE_DEPTH_METABINNER(grouped_bams_ch)
        depth_ch = GENERATE_DEPTH_METABINNER.out.depth

        // generate coverage file using internal helper function
        GENERATE_COVERAGE_METABINNER(depth_ch)
        coverage_ch = GENERATE_COVERAGE_METABINNER.out.coverage

        // generate kmer files (one per sample) using internal helper function
        // use contigs w/ additional length and threshold args (defined in params)
        GENERATE_KMERS_METABINNER(contigs_ch, params.kmer_size, params.length_thresh)
        kmer_ch = GENERATE_KMERS_METABINNER.out.kmer

        // join sample ID'ed contigs channel to kmer and coverage channels for same sample
        metabinner_input = contigs_ch
                .join(coverage_ch)
                .join(kmer_ch)

        // run binning on contigs + kmer + coverage files from previous steps
        METABINNER(metabinner_input)

        // take bin tsv output and parse into fasta files
        PARSE_FASTA_METABINNER(contigs_ch.join(METABINNER.out.result_tsv))

        active_binner_channels << PARSE_FASTA_METABINNER.out.bins

    }

    if (params.binners.contains('concoct')){

        // Fragment the assemblies
        CUTUP_CONCOCT(contigs_ch)

        // Join fragmented BED with grouped BAMs to get coverage
        coverage_input = CUTUP_CONCOCT.out.cutup_bed.join(grouped_bams_ch)
        GENERATE_COVERAGE_CONCOCT(coverage_input)

        // join original contigs, cutup fasta and coverage for final binning
        concoct_final_input = contigs_ch
            .join(CUTUP_CONCOCT.out.cutup_fa)
            .join(GENERATE_COVERAGE_CONCOCT.out.coverage)

        CONCOCT(concoct_final_input)
        active_binner_channels << CONCOCT.out.bins

    }

    // Flatten the list and mix them
    binner_outputs_ch = Channel.empty().mix( *active_binner_channels )


// ========================================================================================================= //

    /*
     * BIN REFINEMENT AND QC
     */

     if(params.refine_bins){

        // Run standardization helper on whatever binners ran
        STANDARDIZE_BINS(binner_outputs_ch)

        // Group clean folders by sample ID
        grouped_bins_ch = STANDARDIZE_BINS.out.bins.groupTuple(by: 0)

        // run DAStools helper module
        PREPARE_TSV_DASTOOLS(grouped_bins_ch, params.binners)
        tsv_ch = PREPARE_TSV_DASTOOLS.out.tsv

        // join tsv and contigs channels by sample ID
        contigs_tsv_ch = contigs_ch.join(tsv_ch)

        // run DAStools
        DASTOOLS(contigs_tsv_ch)
        bins_ch = DASTOOLS.out.refined_bins

         // Run CheckM2 on final DAS Tool consensus bins
        CHECKM2_REFINED(bins_ch, Channel.value("refined"))

        //  Run CheckM2 on your raw individual binner folders
        CHECKM2_RAW(STANDARDIZE_BINS.out.bins, Channel.value("raw"))

    } else {

        // If refinement is skipped, standardize names
        STANDARDIZE_BINS(binner_outputs_ch)

        Fall back straight to the standardized raw bins
        bins_ch = STANDARDIZE_BINS.out.bins

        //  Run CheckM2 on your raw individual binner folders
        CHECKM2_RAW(bins_ch, Channel.value("raw"))

    }

// ========================================================================================================= //


    /*
     * TAXONOMY ASSIGNMENT
     */

    // taxonomy assignment via gtdb-tk
    GTDBTK(bins_ch)

}


// ========================================================================================================= //

// DONE

