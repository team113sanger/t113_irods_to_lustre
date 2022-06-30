/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    VALIDATE INPUTS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

def summary_params = NfcoreSchema.paramsSummaryMap(workflow, params)
def printErr = System.err.&println

// Make sure a run mode has been provided and that it's an expected string
def run_modes = ['study', 'study_run']
if (params.run_mode) {
    if ( run_modes.contains( params.run_mode ) == false ) {
	    printErr("The run_mode is invalid, must be one of: " + run_modes.join(',') + ".")
	    exit 1
    }
}

// Make sure that if run_mode is 'study' then a 'study_id' has been provided
if (params.run_mode == 'study' & !params.study_id) {
	printErr("Run mode is 'study' and no study_id provided.")
	exit 1
}

// Make sure that if run_mode is 'study_run' then a 'study_id' and 'run_id' have been provided
if (params.run_mode == 'study_run' & !params.study_id ) {
	printErr("Run mode is 'study_run' and no study_id provided.")
	exit 1
}
if (params.run_mode == 'study_run' & !params.run_id ) {
	printErr("Run mode is 'study_run' and no run_id provided.")
	exit 1
}

// Make sure and output directory has been specified
if (!params.run_mode) {
	printErr("No outdir provided.")
	exit 1
}	

/*
========================================================================================
    IMPORT LOCAL MODULES/SUBWORKFLOWS
========================================================================================
*/

// Don't overwrite global params.modules, create a copy instead and use that within the main script.
//def modules = params.modules.clone()

//
// MODULE: Local to the pipeline
//
include { METADATA_BY_STUDY } from '../modules/local/imeta_study' 
include { METADATA_BY_STUDY_RUN } from '../modules/local/imeta_study_run.nf'
include { GET_CRAM } from '../modules/local/iget_cram.nf'

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow SGE {
	if (params.run_mode == 'study') {
		//
		// SUBWORKFLOW: Get iRODS metadata per BAM/CRAM for all samples in a given study
		//
		ch_study_ids = Channel.from(params.study_id)
		//ch_study_ids =  Channel.from(6902, 6575)
		METADATA_BY_STUDY ( ch_study_ids )
		metadata_files = METADATA_BY_STUDY.out.metadata_file
	}	else if (params.run_mode == 'study_run') {
		//
		// SUBWORKFLOW: Get iRODS metadata per BAM/CRAM for all samples in a given study and run
		//
		// TO-DO: Check for multiple studies and error out
		ch_study_id = Channel.from(params.study_id).first()
		ch_run_ids = Channel.from(params.run_id)
		METADATA_BY_STUDY_RUN ( ch_study_id.combine(ch_run_ids) )
		metadata_files = METADATA_BY_STUDY_RUN.out.metadata_file
	}

	//
	// SUBWORKFLOW: Read in all metadata files and select relevant fields
	//
	ch_imeta = metadata_files
							.splitCsv(header: true, sep: '\t')
							.map{row->tuple(row.study_id, row.sample, row.file)}

	//
	// SUBWORKFLOW: Download BAM/CRAM from iRODS (lane)
	//
	GET_CRAM ( ch_imeta )
	dnld_cram_path = GET_CRAM.out.irods_cram

	//
	// SUBWORKFLOW: Group metadata by study and sample
	// Grouping by study as sample id may be shared across studies (e.g. WGS, WES)
	//
	ch_cram_by_sample = dnld_cram_path.groupTuple(by: [0,1])
}

/*
========================================================================================
    COMPLETION SUMMARY
========================================================================================
*/

workflow.onComplete {
    NfcoreTemplate.summary(workflow, params, log)
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
