# Release Notes

All notable changes to GeometricBase.jl.

This package is pre-1.0, so *every* minor release is potentially breaking in the sense of
[SemVer](https://semver.org) for `0.x` versions. The sections below name what actually
changed, so that a compat-only bump can be told apart from a rename or a change in results.

This file was started on 2026-08-31 and deliberately holds no entries. 64 versions were
released before it, the most recent `v0.14.9`, and none of them are written up here: the
record of that history is `git log` and the tags. It is named as a gap rather than
reconstructed, because a changelog assembled after the fact loses exactly the reasoning that
makes it worth keeping. The `[Unreleased]` target below is provisional — confirm it when the
first entry is written.

## [Unreleased] — targeting 0.14.10

The provisional `0.15.0` target was lowered to a patch: everything below is additive, and
nothing existing changes name or behaviour.

### New Features

- Interface stubs `noise` and `noisedims`, declared in `src/methods.jl` beside the other
  interface points and, like them, left unexported for downstream packages to re-export.

  `AbstractStochasticProcess` has been declared here since 0.14 and `GeometricEquations` hangs a
  `noise` field off every `SDE`, `PSDE` and `SPSDE` — but with no interface attached, a noise
  object could not be asked anything, not even how many Wiener processes it stands for. Every
  stochastic problem therefore had to invent a bare marker type, and a stochastic integrator had
  no way to size its increment vectors from the problem. These two stubs are that missing
  interface; `GeometricEquations` supplies the concrete processes and the methods on them.

### Bug Fixes

### Breaking Changes

## Open Issues
