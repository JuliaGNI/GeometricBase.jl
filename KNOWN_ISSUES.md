# Known issues

Defects found in review and not yet fixed.

## KI-1 · `test/integration/hdf5_ext.jl` runs once per process only

- **Kind:** test
- **Evidence:** lines 9–11 assert that the HDF5 extension is not loaded and that `h5save` and
  `h5load` have no methods. A second include in the same process fails both assertions. The
  suite includes the file once, so `Pkg.test()` passes.

## KI-2 · `test/quality/aqua.jl` lists Aqua's checks in a comment

- **Kind:** docs
- **Evidence:** lines 5–7 name the checks that `Aqua.test_all` runs. The list goes out of date when
  Aqua changes its checks.

## KI-3 · `test/Utils.jl` tests files under `src/utils/`

- **Kind:** docs
- **Evidence:** the file tests `src/utils/macros.jl`, `norms.jl` and `summation.jl`, which a strict
  reading of the layout rule puts in `test/utils/`. `test-layout.jl --check` accepts the current
  path, because `src/Utils.jl` includes them.

## KI-4 · No test covers `GeometricData`

- **Kind:** coverage
- **Evidence:** a mutant of `Base.getproperty` for `GeometricData` in
  `src/data/geometric_data.jl` (`if hasfield(TupleType, s)` → `if !hasfield(TupleType, s)`)
  survives `test/data/data_and_system_types.jl`. No other test file names `GeometricData`.
