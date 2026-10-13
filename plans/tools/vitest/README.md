# Vitest

The French version is [README.fr.md](README.fr.md).

## Purpose

Run frontend unit tests.

## Problem it resolves

`vue-tsc` checks types. It does not check that a button submits the form. Frontends in this organization do not all have a test script yet. `auth-service` frontend has no `test` script.

## How we use it

`vue-app.yml` runs `npm test` (or Yarn or pnpm) only when `package.json` defines a `test` script. When a frontend adds tests, that script should be Vitest. The shared workflow does not install Vitest itself.

## Installation

An npm devDependency the frontend adds when it adds a `test` script. The same frozen install that fills `node_modules` installs it. The shared workflow waits for the repo to declare it.

## Constraints

A test script that launches a browser or a real API does not belong on the default pull-request job. Keep Vitest on jsdom or happy-dom. Browser tests wait for the preview environment.

## Pros

Same Vite pipeline as the app, so aliases and Vue components load the way the app loads them.

## Cons

An empty or missing script does not fail. A frontend can stay untested until someone adds the script. That is deliberate until phase 4.

## Alternatives

Jest. New tests go to Vitest so the runner matches Vite. Do not add Jest beside it.
