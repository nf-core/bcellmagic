# ![nf-core/bcellmagic](docs/images/nf-core-bcellmagic_logo.png)

[![GitHub Actions CI Status](https://github.com/nf-core/bcellmagic/workflows/nf-core%20CI/badge.svg)](https://github.com/nf-core/bcellmagic/actions?query=workflow%3A%22nf-core+CI%22)
[![GitHub Actions Linting Status](https://github.com/nf-core/bcellmagic/workflows/nf-core%20linting/badge.svg)](https://github.com/nf-core/bcellmagic/actions?query=workflow%3A%22nf-core+linting%22)
[![AWS CI](https://img.shields.io/badge/CI%20tests-full%20size-FF9900?labelColor=000000&logo=Amazon%20AWS)](https://nf-co.re/bcellmagic/results)
[![Cite with Zenodo](http://img.shields.io/badge/DOI-10.5281/zenodo.2642009-1073c8?labelColor=000000)](https://doi.org/10.5281/zenodo.2642009)
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-%E2%89%A521.04.0-23aa62.svg?labelColor=000000)](https://www.nextflow.io/)
[![run with conda](http://img.shields.io/badge/run%20with-conda-3EB049?labelColor=000000&logo=anaconda)](https://docs.conda.io/en/latest/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)
[![run with singularity](https://img.shields.io/badge/run%20with-singularity-1d355c.svg?labelColor=000000)](https://sylabs.io/docs/)
[![Get help on Slack](http://img.shields.io/badge/slack-nf--core%20%23bcellmagic-4A154B?labelColor=000000&logo=slack)](https://nfcore.slack.com/channels/bcellmagic)
[![Follow on Twitter](http://img.shields.io/badge/twitter-%40nf__core-1DA1F2?labelColor=000000&logo=twitter)](https://twitter.com/nf_core)
[![Watch on YouTube](http://img.shields.io/badge/youtube-nf--core-FF0000?labelColor=000000&logo=youtube)](https://www.youtube.com/c/nf-core)

## Introduction

The nf-core/bcellmagic pipeline is a bioinformatics best-practice pipeline to analyze B-cell or T-cell bulk repertoire sequencing data. It makes use of the [Immcantation](https://immcantation.readthedocs.io) toolset and requires as input targeted amplicon sequencing data of the V, D, J and C regions of the B/T-cell receptor with multiplex PCR or 5' RACE protocol.

The pipeline is built using [Nextflow](https://www.nextflow.io), a workflow tool to run tasks across multiple compute infrastructures in a very portable manner. It uses Docker/Singularity containers making installation trivial and results highly reproducible. The [Nextflow DSL2](https://www.nextflow.io/docs/latest/dsl2.html) implementation of this pipeline uses one container per process which makes it much easier to maintain and update software dependencies. Where possible, these processes have been submitted to and installed from [nf-core/modules](https://github.com/nf-core/modules) in order to make them available to all nf-core pipelines, and to everyone within the Nextflow community!

On release, automated continuous integration tests run the pipeline on a full-sized dataset on the AWS cloud infrastructure. This ensures that the pipeline runs on AWS, has sensible resource allocation defaults set to run on real-world datasets, and permits the persistent storage of results to benchmark between pipeline releases and other analysis sources. The results obtained from the full-sized test can be viewed on the [nf-core website](https://nf-co.re/bcellmagic/results).

## Pipeline summary

By default, the pipeline currently performs the following steps:

* Raw read quality control (`FastQC`)
* Pre-processing (`pRESTO`)
    * Filtering sequences by sequencing quality.
    * Masking amplicon primers.
    * Pairing read mates.
    * Cluster sequences according to similarity, it helps identify if the UMI barcode diversity was not high enough.
    * Building consensus of sequences with the same UMI barcode.
    * Re-pairing read mates.
    * Assembling R1 and R2 read mates.
    * Removing and annotating read duplicates with different UMI barcodes.
    * Filtering out sequences that do not have at least 2 duplicates.
* Assigning gene segment alleles with `IgBlast` using the IMGT database (`Change-O`).
* Determining the BCR / TCR genotype of the sample and finding the threshold for clone definition (`TIgGER`, `SHazaM`).
* Clonal assignment: defining clonal lineages of the B-cell / T-cell populations (`Change-O`).
* Reconstructing gene calls of germline sequences (`Change-O`).
* Generating clonal trees (`Alakazam`).
* Repertoire analysis: calculation of clonal diversity and abundance (`Alakazam`).
* Aggregating QC reports (`MultiQC`).

## Quick Start

1. Install [`Nextflow`](https://nf-co.re/usage/installation) (`>=21.04.0`)

2. Install any of [`Docker`](https://docs.docker.com/engine/installation/), [`Singularity`](https://www.sylabs.io/guides/3.0/user-guide/), [`Podman`](https://podman.io/), [`Shifter`](https://nersc.gitlab.io/development/shifter/how-to-use/) or [`Charliecloud`](https://hpc.github.io/charliecloud/) for full pipeline reproducibility _(please only use [`Conda`](https://conda.io/miniconda.html) as a last resort; see [docs](https://nf-co.re/usage/configuration#basic-configuration-profiles))_

3. Download the pipeline and test it on a minimal dataset with a single command:

    ```console
    nextflow run nf-core/bcellmagic -profile test,<docker/singularity/podman/shifter/charliecloud/conda/institute>
    ```

    > * Please check [nf-core/configs](https://github.com/nf-core/configs#documentation) to see if a custom config file to run nf-core pipelines already exists for your Institute. If so, you can simply use `-profile <institute>` in your command. This will enable either `docker` or `singularity` and set the appropriate execution settings for your local compute environment.
    > * If you are using `singularity` then the pipeline will auto-detect this and attempt to download the Singularity images directly as opposed to performing a conversion from Docker images. If you are persistently observing issues downloading Singularity images directly due to timeout or network issues then please use the `--singularity_pull_docker_container` parameter to pull and convert the Docker image instead. Alternatively, it is highly recommended to use the [`nf-core download`](https://nf-co.re/tools/#downloading-pipelines-for-offline-use) command to pre-download all of the required containers before running the pipeline and to set the [`NXF_SINGULARITY_CACHEDIR` or `singularity.cacheDir`](https://www.nextflow.io/docs/latest/singularity.html?#singularity-docker-hub) Nextflow options to be able to store and re-use the images from a central location for future pipeline runs.
    > * If you are using `conda`, it is highly recommended to use the [`NXF_CONDA_CACHEDIR` or `conda.cacheDir`](https://www.nextflow.io/docs/latest/conda.html) settings to store the environments in a central location for future pipeline runs.

4. Start running your own analysis!

    ```bash
    nextflow run nf-core/bcellmagic \
    -profile <docker/singularity/podman/shifter/charliecloud/conda/institute> \
    --input samplesheet.tsv \
    --protocol pcr_umi \
    --cprimers CPrimers.fasta \
    --vprimers VPrimers.fasta \
    --umi_length 12 \
    --loci "ig"
    ```

See [usage docs](https://nf-co.re/bcellmagic/usage) for all of the available options when running the pipeline.

## Documentation

The nf-core/bcellmagic pipeline comes with documentation about the pipeline [usage](https://nf-co.re/bcellmagic/usage), [parameters](https://nf-co.re/bcellmagic/parameters) and [output](https://nf-co.re/bcellmagic/output).

## Credits

nf-core/bcellmagic was originally written by Gisela Gabernet, Simon Heumos, Alexander Peltzer.

<!-- We thank the following people for their extensive assistance in the development
of this pipeline: -->

## Contributions and Support

If you would like to contribute to this pipeline, please see the [contributing guidelines](.github/CONTRIBUTING.md).

For further information or help, don't hesitate to get in touch on the [Slack `#bcellmagic` channel](https://nfcore.slack.com/channels/bcellmagic) (you can join with [this invite](https://nf-co.re/join/slack)).

## Citations

If you use nf-core/bcellmagic for your analysis, please cite it using the following DOI: [10.5281/zenodo.2642009](https://doi.org/10.5281/zenodo.2642009)

An extensive list of references for the tools used by the pipeline can be found in the [`CITATIONS.md`](CITATIONS.md) file.

You can cite the `nf-core` publication as follows:

> **The nf-core framework for community-curated bioinformatics pipelines.**
>
> Philip Ewels, Alexander Peltzer, Sven Fillinger, Harshil Patel, Johannes Alneberg, Andreas Wilm, Maxime Ulysse Garcia, Paolo Di Tommaso & Sven Nahnsen.
>
> _Nat Biotechnol._ 2020 Feb 13. doi: [10.1038/s41587-020-0439-x](https://dx.doi.org/10.1038/s41587-020-0439-x).
