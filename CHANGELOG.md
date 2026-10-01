# Release Notes

All notable changes to GeometricBase.jl.

This package is pre-1.0, so *every* minor release is potentially breaking in the sense of
[SemVer](https://semver.org) for `0.x` versions. The sections below name what actually
changed, so that a compat-only bump can be told apart from a rename or a change in results.

This file was started on 2026-08-31 and deliberately holds no entries for what preceded it. 64
versions were released before it, the most recent `v0.14.9`, and none of them are written up
here: the record of that history is `git log` and the tags. It is named as a gap rather than
reconstructed, because a changelog assembled after the fact loses exactly the reasoning that
makes it worth keeping.

## [0.15.0] — 2026-10-01

### Breaking Changes

- GeometricBase 0.15 declares its stubs public and requires Julia 1.11. Every function stub of
  `src/methods.jl`, and `initialtime` and `finaltime`, is public. The six exported stubs stay
  exported: `datatype`, `timetype`, `arrtype` and `equtype` from `src/methods.jl`, and `reset!`
  and `value` from `src/data/state_variables.jl`. Every other one is public through a new
  `public` statement. The stubs are meant to be extended by other packages, and the ecosystem
  uses them by qualified name to avoid export clashes; `public` makes that use part of the API
  without a new export. The `public` keyword needs Julia 1.11, so Julia 1.10 cannot load 0.15,
  and Julia 1.10 users keep 0.14.12. The exports do not change. `test/public.jl` reads the stubs
  from `src/methods.jl` and fails for a stub that is not public.

### Fixed

- `x ≠ y` (and `x != y`) now agrees with whatever `Base.:(==)` method actually applies for `x`
  and `y`, instead of always falling back to a plain `parent`-array comparison. For two
  `StateVariable`s that differ only in `range` or `periodic` (not in their values), `x ≠ y`
  now correctly returns `true` (it previously returned `false`, disagreeing with `x == y`, which
  was already `false` there too — an existing inconsistency). The same fix applies to two
  `StateWithError`s that differ only in `error` (not in `state`), and to an `Increment` wrapping
  such a variable, since `Increment` forwards `==` to what it wraps. `Base` already derives
  `≠`/`!=` from `==` via `!=(x, y) = !(x == y)`, so the six `Base.:(≠)` methods removed from
  `src/data/state_variables.jl` were redundant overloads that could (and did, for these two
  cases) silently drift out of sync with the corresponding `==` methods.

### Changed

- The test suite follows the layout of the other JuliaGNI packages. `test/runtests.jl` holds one
  `core` group of `@safetestset` lines. Each test file mirrors the source file it tests:
  `test/data/state.jl`, `test/data/state_variables.jl`, `test/Utils.jl` and so on.
  `interface_tests.jl` and `hdf5_tests.jl` test the whole package and are now
  `test/integration/interface.jl` and `test/integration/hdf5_ext.jl`. `geometric_data_tests.jl`
  tests `src/data/data_types.jl` and `src/data/system_types.jl`, and is now
  `test/data/data_and_system_types.jl`.
- The four test files that draw random numbers seed the RNG.
- The tests assert `!isnan(x)` directly, not `isnan(x) == false`. The three assertions are
  stricter, as an `isnan` that returns a non-`Bool` now fails. Nothing under `src/` changes.
- `test/Project.toml` no longer carries `HDF5 = "0.17.4"` in `[compat]`. HDF5 is a weak
  dependency of the package, so the test environment already takes the root's bound
  `"0.16.11, 0.17"`; a second entry could only narrow it and test fewer versions than the
  package claims. A test or docs environment carries no `[compat]` entry for a dependency of
  the root `Project.toml`.
- The docstring of `copy!(st::State, sol::NamedTuple)` names `copy!` and `sol`, not `initialize!`
  and `ics`, and says that the keys of `sol` must be a subset of the keys of the state, as the
  method asserts.

### Added

- `test/quality/aqua.jl` runs Aqua's checks. Its ambiguity check is `broken`: `range` for a
  `StateWithError` is ambiguous with `Base.range` (issue #22). Aqua and Random are new test
  dependencies.
- `test/quality/explicit_imports.jl` runs `ExplicitImports.test_explicit_imports`, which fails on
  a stale explicit import and on an import through a module that does not own the name.
  ExplicitImports 1.15 is a new test dependency.

## [0.14.12] — 2026-09-23

### Added

- `h5save(h5, x; path)` and `h5load(T, h5, args...; path)`, generic functions for HDF5 storage, with
  file-path forms supplied by the HDF5 package extension. A package that stores its types in HDF5
  adds methods in an extension on HDF5, typing `h5` as `HDF5.H5DataStore` and choosing its own
  default for `path`, so that one function serves every type and two packages that both store data
  do not export two different `h5save` bindings.

### Changed

- `src/data/data_types.jl`, `test/geometric_data_tests.jl` and `test/state_tests.jl` are now
  Unicode NFC-normalised. The first two stored `ṗ` and `ż` as a base letter plus a combining mark,
  the third `ṗ` alone, inherited from macOS rather than chosen. `q̇`, `q̈` and `q̄` have no
  precomposed codepoint and are unchanged.

  Nothing about the compiled code changes — Julia's parser normalises identifiers to NFC — but a
  `grep` pattern or an editor search typed in NFC now matches, where before it silently matched
  nothing. Each file is byte-equal to the NFC normalisation of its predecessor, and no string
  literal was affected.

  `_add_symbol` and `_strip_symbol` in `src/data/state.jl` were already normalisation-correct and
  are untouched: they normalise explicitly rather than relying on the encoding of the source.

## [0.14.11] — 2026-09-05

### Tests

- `test/interface_tests.jl` asserts that no name this package owns collides with a function of the
  same name owned by an upstream module — `Base` and `Core`, which the check seeds, together with
  the direct dependencies it derives, here `Unicode`. Nothing was found: the 85 functions this
  package owns are disjoint from the 8 `Unicode` owns, on every supported Julia version.

  It is a guard rather than a fix, added because this package declares the interface generics the
  whole ecosystem extends, so a name re-defined here would fragment every consumer at once.
  `GeometricIntegratorsBase` had exactly that defect against seven of these generics — the six
  method-property predicates and `reference`, all bare-defined in its `src/method.jl` with no
  import — and its own copy of this check is what found them.

  The dependency list is derived with `Base.identify_package` rather than by testing whether the
  module binds a dependency's name, because the latter misses one reached as `using Dep: name` —
  which is how this package reaches `Unicode`, i.e. it would have missed the only dependency there
  is. `Unicode` is asserted by name in the test for that reason.

  The generated `eval` and `include` are excluded from the scan. `parentmodule` attributes them to
  the module itself up to Julia 1.11 and to `Core` and `Base` from 1.12, so including them would
  make both the count and the verdict depend on the Julia version.

- The root `Project.toml` no longer carries an `[extras]`/`[targets]` block. `test/Project.toml`
  declares the test dependencies on every supported Julia version, so the block was a second and
  silently unread copy of that list — one that had already drifted, in that it does not name
  `Unicode`.

## [0.14.10] — 2026-09-02

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
