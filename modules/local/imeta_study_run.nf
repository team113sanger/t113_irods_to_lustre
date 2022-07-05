// Import generic module functions
include { saveFiles } from './functions'

params.options = [:]

process METADATA_BY_STUDY_RUN {
	tag "imeta_${study_id}_${run_id}"
	publishDir "${params.meta_dir}", mode: params.publish_dir_mode, pattern: "*_samples.tsv"

	input:
		tuple val(study_id), val(run_id)

	output:
		path "${study_id}_${run_id}_samples.tsv", emit: metadata_file

	script: 
	"""
	bash $workflow.projectDir/bin/imeta_study_run.sh ${study_id} ${run_id}
	"""
}