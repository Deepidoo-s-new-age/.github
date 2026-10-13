# oasdiff

The French version is [README.fr.md](README.fr.md).

## Purpose

Show whether a pull request changed the HTTP API in a way that breaks callers.

## Problem it resolves

A renamed field or a removed status code can pass tests that mock the client. The module that calls `platform-api` finds out in preproduction.

## How we use it

Phase 5, same job as the architecture validator. The test job generates OpenAPI without production dependencies. oasdiff compares that document to the OpenAPI artifact from the base branch. A breaking change fails, or at least prints in the pull request before we make the check blocking.

## Installation

The architecture job in `ci-workflows` downloads a pinned release of the Go binary onto the runner. The OpenAPI documents it compares are CI artifacts from the test job.

## Constraints

It needs a stable way to generate OpenAPI in CI. A generator that requires Postgres will not run on the default job. Breaking versus compatible is oasdiff’s classification. Read the report before treating every diff as a failure.

## Pros

The diff is the API, not a guess from the route list. No server.

## Cons

It does not know which consumer pins an old client. The contracts version bump is still how shared schemas move.

## Alternatives

`openapi-diff`, optic. oasdiff is the one we run. One API diff tool.
