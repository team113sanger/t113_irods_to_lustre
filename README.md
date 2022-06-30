# sge_irods_to_lustre

[![Nextflow](https://img.shields.io/badge/nextflow-%E2%89%A522.04.3.-brightgreen.svg)](https://www.nextflow.io/)

## Introduction

A [Nextflow](https://www.nextflow.io) pipeline to be used internally at Sanger for generating metadata and downloading/processing data from Sanger's iRODS.

1. Get metadata from Sanger iRODS
2. Download lane BAM/CRAM from Sanger iRODS
3. Merge lane BAM/CRAM into a sample BAM/CRAM
4. Convert BAM/CRAM to FASTQ

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner.  The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies.

For documentation, see the pipeline [usage](docs/usage.md) documentation.

## Quick Start (Sanger farm5)

1. Load Nextflow module
   ```console
   module load /software/team113/modules/modulefiles
   ```
   
2. Load samtools module
   ```console
   module load /software/CASM/modules/modulefiles/samtools/1.14
   ```

3. Download the pipeline

   ```console
   git clone https://gitlab.internal.sanger.ac.uk/team113_nextflow_pipelines/t113_irods_to_lustre.git
   ```
	
4. Start running your own analysis!

   To download all sample BAM/CRAM for a study:

   ```console
   nextflow run t113_irods_to_lustre --run_mode study --study_id 6902
   ```

   To download all sample BAM/CRAM from a single run for a study:

   ```console
   nextflow run t113_irods_to_lustre --run_mode study_run --study_id 6902 --run_id 45215
   ```