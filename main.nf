#!/usr/bin/env nextflow
/*
========================================================================================
    irods_to_lustre
========================================================================================
    GitLab : https://gitlab.internal.sanger.ac.uk/team113_nextflow_pipelines/irods_to_lustre
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

/*
========================================================================================
    VALIDATE & PRINT PARAMETER SUMMARY
========================================================================================
*/

WorkflowMain.initialise(workflow, params, log)

/*
========================================================================================
    NAMED WORKFLOW FOR PIPELINE
========================================================================================
*/

include { SGE } from './workflows/sge'

//
// WORKFLOW: Run main QUANTS analysis pipeline
//
workflow IRODS_TO_LUSTRE {
    SGE ()
}

/*
========================================================================================
    RUN ALL WORKFLOWS
========================================================================================
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
//
workflow {
    IRODS_TO_LUSTRE ()
}

/*
========================================================================================
    THE END
========================================================================================
*/
