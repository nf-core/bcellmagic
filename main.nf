#!/usr/bin/env nextflow
/*
========================================================================================
                        nf-core/bcellmagic
========================================================================================
    GitHub  : https://github.com/nf-core/bcellmagic
    Website : https://nf-co.re/rnaseq
    Slack   : https://nfcore.slack.com/channels/bcellmagic
----------------------------------------------------------------------------------------
*/

nextflow.enable.dsl = 2

log.info Headers.nf_core(workflow, params.monochrome_logs)

////////////////////////////////////////////////////
/* --               PRINT HELP                 -- */
////////////////////////////////////////////////////

def json_schema = "$projectDir/nextflow_schema.json"
if (params.help) {
    def command = "nextflow run nf-core/bcellmagic -profile <docker/singularity/podman/conda/institute> --input metadata.tsv --cprimers CPrimers.fasta --vprimers VPrimers.fasta"
    log.info NfcoreSchema.params_help(workflow, params, json_schema, command)
    exit 0
}

////////////////////////////////////////////////////
/* --         VALIDATE PARAMETERS              -- */
////////////////////////////////////////////////////+
if (params.validate_params) {
    NfcoreSchema.validateParameters(params, json_schema, log)
}

////////////////////////////////////////////////////
/* --          PARAMETER CHECKS                -- */
////////////////////////////////////////////////////

// Check that conda channels are set-up correctly
if (params.enable_conda) {
    Checks.check_conda_channels(log)
}

// Check AWS batch settings
Checks.aws_batch(workflow, params)

// Check the hostnames against configured profiles
Checks.hostname(workflow, params, log)


////////////////////////////////////////////////////
/* --         PRINT PARAMETER SUMMARY          -- */
////////////////////////////////////////////////////
def summary_params = NfcoreSchema.params_summary_map(workflow, params, json_schema)
log.info NfcoreSchema.params_summary_log(workflow, params, json_schema)


/////////////////////////////
/* -- RUN MAIN WORKFLOW -- */
/////////////////////////////

workflow {
    if (params.subworkflow == "bcellmagic") {
        include { BCELLMAGIC } from './bcellmagic' addParams( summary_params: summary_params )
        BCELLMAGIC()
    } else if (params.subworkflow == "reveal") {
        include { REVEAL } from './reveal' addParams( summary_params: summary_params )
        REVEAL ()
    } else {
        exit 1
    }
}

