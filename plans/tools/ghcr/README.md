# GHCR

The French version is [README.fr.md](README.fr.md).

## Purpose

Store the container images this organization builds.

## Problem it resolves

`auth-service` and `platform-api` tag `ghcr.io/deepidoo/...` from repositories in `Deepidoo-s-new-age`. The `GITHUB_TOKEN` cannot push there. The runs fail with `denied: permission_denied: read_package`.

## How we use it

`image.yml` pushes `ghcr.io/deepidoo-s-new-age/<service>:<git-sha>` with the caller’s `GITHUB_TOKEN` and `packages: write`. The tag is the commit. There is no `:latest` tag. The workflow outputs the digest. Helm values store that digest. Phase 1 builds with `push: false`. Phase 6 is the first push, and only on `main`.

Before the first push, set the organization’s default package visibility to private. The cluster gets an `imagePullSecret` that can read this org’s packages.

## Installation

GitHub’s container registry. `image.yml` logs in with `docker/login-action` and pushes with `docker/build-push-action`. The cluster pulls with an `imagePullSecret` that can read `ghcr.io/deepidoo-s-new-age/*`.

## Constraints

The image name must be lowercase and match the pattern in the workflow. The package is owned by `Deepidoo-s-new-age`. A repo that still lives in `Deepidoo` does not push here until it moves.

## Pros

No extra registry account. The token is the workflow token. The digest is immutable.

## Cons

Retention has to be configured or old sha tags accumulate. Private pulls need a pull secret on the cluster.

## Alternatives

Docker Hub, a registry in the cluster. GHCR stays next to the git host. One registry for New Age images.
