# Release Please

The French version is [README.fr.md](README.fr.md).

## Purpose

Open a release pull request that bumps the version, updates the changelog, and tags `vX.Y.Z` when merged.

## Problem it resolves

`deepidoo-contracts` and deesplay need a version people can pin. Hand-cut tags drift from the changelog and from what consumers install. The image tag for a service can follow the same number so a Helm promotion PR reads “1.4.2, digest sha256:…”.

## How we use it

When phase 3 and phase 4 start publishing. Conventional commits on `main` feed the release PR. Merging it creates the tag. The tag triggers the GitHub Packages publish. A breaking change is a major, which the architecture doc already requires for contracts.

## Installation

The Release Please GitHub Action, pinned, in the repositories that publish: `deepidoo-contracts`, then `deesplay`. Merging its pull request creates the git tag. That tag starts the GitHub Packages publish workflow.

## Constraints

It depends on commit messages that say feat, fix, or the breaking marker. A repo that does not write those gets no release until someone edits the release PR. It does not deploy. Helm still gets a separate digest PR.

## Pros

The version, the changelog, and the tag are one merge.

## Cons

Wrong commit types produce a wrong version. The release PR is the place to correct that before the tag exists.

## Alternatives

semantic-release, which tags from CI without a PR. Release Please keeps a human on the version. That matches “a human merges”.
