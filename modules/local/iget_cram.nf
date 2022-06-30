// Import generic module functions
include { saveFiles } from './functions'

params.options = [:]

process GET_CRAM {
	tag "${study_id}_${sample_id}"
	publishDir "${params.cram_dir}", mode: params.publish_dir_mode

	input:
		tuple val(study_id), val(sample_id), val(cram_irods_object)

	output:
		tuple val(study_id), val(sample_id), path("*.cram"), emit: irods_cram
    tuple val(study_id), val(sample_id), path("*.cram"), path("*.crai"), emit: irods_crai optional true

	when:
  params.download_cram

	script: 
	"""
	iget -K -f -I -v "${cram_irods_object}"
	iget -K -f -I -v "${cram_irods_object}.crai" || true
	"""
}