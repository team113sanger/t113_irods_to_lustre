// Import generic module functions
include { saveFiles } from './functions'

params.options = [:]

process METADATA_BY_STUDY_RUN {
	tag "imeta_${study_id}_${run_id}"
	publishDir "${params.outdir}",
		mode: params.publish_dir_mode,
		saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:'metadata', meta:[:], publish_by_meta:[]) }

	input:
		tuple val(study_id), val(run_id)

	output:
		path "${study_id}_${run_id}_samples.tsv", emit: metadata_file

	script: 
	"""
	bash $workflow.projectDir/bin/imeta_study_run.sh ${study_id} ${run_id}
	"""
}