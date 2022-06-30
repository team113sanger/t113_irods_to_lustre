// Import generic module functions
include { saveFiles } from './functions'

params.options = [:]

process METADATA_BY_STUDY {
	tag "imeta_${study_id}"
	publishDir "${params.outdir}",
		mode: params.publish_dir_mode,
		saveAs: { filename -> saveFiles(filename:filename, options:params.options, publish_dir:'metadata', meta:[:], publish_by_meta:[]) }

	input:
		val study_id

	output:
		path "${study_id}_samples.tsv", emit: metadata_file

	script: 
	"""
	bash $workflow.projectDir/bin/imeta_study.sh ${study_id}
	"""
}