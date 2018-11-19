# 3. Component Based Rails Application

Date: 2018-11-19

## Status

Accepted

## Context

Current application has lot of old, legacy code that is difficult and slow to refactor anything more
manageable codebase. Easy way to make application's codebase more modern and manageable is simply
writing new code. Full rewrite of product is though slow and impossible. Gradual refactoring and rewriting
is the only option that is possible.

## Decision

Best option to write new code is to adopt Component Based Rails Application (CoBRA). This splits rails app
to multiple small engines that implement micro-service idea, each component does only one thing but does it
well. Different components can talk to each other, and depending on others, but only on either same level or
on abstraction level below.

## Consequences

Developing new features will be bit slower at first as building required new data layer and abstractions.
