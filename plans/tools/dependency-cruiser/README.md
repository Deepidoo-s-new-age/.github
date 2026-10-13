# dependency-cruiser

The French version is [README.fr.md](README.fr.md).

## Purpose

Fail when a frontend import crosses a boundary, including a circular import.

## Problem it resolves

A module UI that imports another service, or a cycle between views, is a structure bug. Typecheck does not see it as a violation.

## How we use it

The workflow runs it only when a config file is already in the frontend (`.dependency-cruiser.*` or `dependency-cruiser.config.*`), against `src`. Phase 5 adds that config once the frontend job is green: a module UI does not import another service.

## Installation

An npm devDependency of the frontend. `npm ci` installs it once that repo commits the package and a config file.

## Constraints

No config means no check. Adding a config with the current graph red blocks the frontend until the graph is fixed or baselined.

## Pros

The forbidden edges are a reviewed file. It understands TypeScript and Vue if the config says so.

## Cons

Another devDependency to keep current. Worth it only when the rule is real.

## Alternatives

eslint-plugin-import, madge for cycles only. dependency-cruiser covers cycles and forbidden folders in one config. Use that, not both.
