// Derived from nf-core module 
// https://github.com/nf-core/modules/blob/master/modules/samtools/merge

// Import generic module functions
include { saveFiles } from './functions'

process SAMTOOLS_MERGE {
    tag "samtools_merge_${sample_id}"
    publishDir "${params.cram_dir}/study_sample", mode: params.publish_dir_mode, pattern: "*.cram*"

    input:
    tuple val(study_id), val(sample_id), path(input_files)

    output:
    tuple val(study_id), val(sample_id), path("${study_id}_${sample_id}.cram"), emit: sample_cram
		path("metadata.csv"), emit: merged_cram_metadata

    when:
		params.merge_crams_by_sample && params.download_cram

    script:
    def args = task.ext.args ?: ''
    """
    samtools \\
        merge \\
        --threads ${task.cpus-1} \\
        $args \\
        ${study_id}_${sample_id}.cram \\
        $input_files*
    
    merged_filename="${study_id}_${sample_id}.cram"
	  merged_filepath="${params.cram_dir}/study_sample/\$merged_filename"
	  metadata_filepath="metadata.csv"
	  echo "study_id,sample_id,cram_file" > \$metadata_filepath
	  echo "${study_id},${sample_id},\${merged_filepath}" >> \$metadata_filepath
    """
}