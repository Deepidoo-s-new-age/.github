# vue-tsc

The French version is [README.fr.md](README.fr.md).

## Purpose

Typecheck Vue single-file components and TypeScript in a frontend.

## Problem it resolves

A template can pass the wrong prop and Vite will still build if nobody runs the checker. `auth-service` frontend already depends on `vue-tsc` and its build script is `vue-tsc -b && vite build`.

## How we use it

Phase 0, inside `vue-app.yml`, only when the job is enabled.

- If `package.json` has a `typecheck` script, run that.
- Otherwise, if `vue-tsc` is installed, run `vue-tsc --noEmit`.

`run_build` stays false until `npm run build` is green against the published deesplay package. The build script uses `vue-tsc -b`, which is project-reference mode. `--noEmit` and `-b` are not the same command. When the repo grows a `tsconfig` that needs `-b`, the `typecheck` script should be that command, and the workflow will follow the script.

## Installation

An npm devDependency of the frontend that already lists it. The `auth-service` frontend does. `npm ci` installs it with the rest of the lockfile.

## Constraints

The `auth-service` checker cannot pass while Vite aliases `@deepidoo/deesplay` to a folder CI does not have. Phase 4 removes that alias.

## Pros

Uses the binary the repo already installed. No second TypeScript checker.

## Cons

Slow on large apps. Still cheaper than a production build on every pull request.

## Alternatives

`tsc --noEmit` alone skips `.vue` files. Volar’s checker is the same engine as vue-tsc. Use vue-tsc.
