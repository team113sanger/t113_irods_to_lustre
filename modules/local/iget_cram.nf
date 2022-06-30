// Import generic module functions
include { saveFiles } from './functions'

params.options = [:]

process GET_CRAM {
	tag "${study_id}_${sample_id}"
	publishDir "${params.cram_dir}/study_run_lane", mode: params.publish_dir_mode, pattern: "*.cram*"

	input:
		tuple val(study_id), val(sample_id), val(cram_irods_object)

	output:
		tuple val(study_id), val(sample_id), path("*.cram"), emit: dnld_cram
    tuple val(study_id), val(sample_id), path("*.cram"), path("*.crai"), emit: dnld_crai optional true
		path("metadata.csv"), emit: dnld_cram_metadata

	when:
  params.download_cram

	script: 
	"""
	iget -K -f -I -v "${cram_irods_object}"
	iget -K -f -I -v "${cram_irods_object}.crai" || true

	dnld_filename="\$(basename *.cram)"
	dnld_filepath="${params.cram_dir}/study_run_lane/\$dnld_filename"
	metadata_filepath="metadata.csv"
	echo "study_id,sample_id,cram_file" > \$metadata_filepath
	echo "${study_id},${sample_id},\${dnld_filepath}" >> \$metadata_filepath
	"""
}