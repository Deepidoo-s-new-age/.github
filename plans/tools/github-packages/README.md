# GitHub Packages

The French version is [README.fr.md](README.fr.md).

## Purpose

Publish versioned Python and npm packages from this organization so other repos install them instead of cloning a sibling checkout.

## Problem it resolves

`deepidoo-contracts` is a path in `uv.lock` (`../../contracts`). deesplay is a `file:` link to another organization’s checkout. CI cannot rely on a developer’s disk. A version makes the bump a pull request.

## How we use it

Phase 3: tag `vX.Y.Z` on `deepidoo-contracts` runs the package tests, then publishes `deepidoo-contracts` to GitHub Packages. Consumers pin the version. `checkout_contracts: false` after that. A breaking change is a major version.

Phase 4: publish deesplay from `packages/deesplay`. GitHub Packages requires the npm scope to match the owning org, so the name is `@deepidoo-s-new-age/deesplay`. Imports, the lockfile, and the Vite alias change with that name. Consumers need:

```text
@deepidoo-s-new-age:registry=https://npm.pkg.github.com
```

and `NODE_AUTH_TOKEN` in `vue-app.yml`.

## Installation

A GitHub registry. The `deepidoo-contracts` release workflow publishes with the uv tooling already in that repo and `GITHUB_TOKEN`. deesplay publishes with `npm publish` from `packages/deesplay`. Consumers point pip at the organization Python index, or npm at `https://npm.pkg.github.com`, with a read token.

## Constraints

The package is private. CI and the cluster need a token that can read it. The scope cannot stay `@deepidoo` if the package is published from `Deepidoo-s-new-age`.

## Pros

Same host as the git repos. The workflow’s `GITHUB_TOKEN` can publish from the repo that owns the package.

## Cons

Consumers outside the org need a token. npm and pip configuration is easy to get slightly wrong and only fails at install.

## Alternatives

A public PyPI or npm publish. These packages are private. GitHub Packages is the registry.
