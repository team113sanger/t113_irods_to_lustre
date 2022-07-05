// Import generic module functions
include { saveFiles } from './functions'

params.options = [:]

process METADATA_BY_STUDY {
	tag "imeta_${study_id}"
	publishDir "${params.meta_dir}", mode: params.publish_dir_mode, pattern: "*_samples.tsv"

	input:
		val study_id

	output:
		path "${study_id}_samples.tsv", emit: metadata_file

	script: 
	"""
	bash $workflow.projectDir/bin/imeta_study.sh ${study_id}
	"""
}