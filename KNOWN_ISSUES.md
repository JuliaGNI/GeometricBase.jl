# Known issues

Defects found in review and not yet fixed.

### K1 · `test/integration/hdf5_ext.jl` runs once per process only.

- **location:** `test/integration/hdf5_ext.jl:9`
- **evidence:** lines 9–11 assert that the HDF5 extension is not loaded and that `h5save` and
  `h5load` have no methods. A second include in the same process fails all three assertions. The
  suite includes the file once, so `Pkg.test()` passes.
- **kind:** defect
- **found:** 2026-09-26

### K2 · `test/quality/aqua.jl` lists Aqua's checks in a comment.

- **location:** `test/quality/aqua.jl:5`
- **evidence:** lines 5–7 name the checks that `Aqua.test_all` runs. The list goes out of date when
  Aqua changes its checks.
- **kind:** docs
- **found:** 2026-09-26

### K3 · `test/Utils.jl` tests files under `src/utils/`.

- **location:** `test/Utils.jl`
- **evidence:** the file tests `src/utils/macros.jl`, `norms.jl` and `summation.jl`, which a strict
  reading of the layout rule puts in `test/utils/`. `test-layout.jl --check` accepts the current
  path, because `src/Utils.jl` includes them.
- **kind:** docs
- **found:** 2026-09-26

### K4 · No test covers `GeometricData`.

- **location:** `src/data/geometric_data.jl:20`
- **evidence:** a mutant of `Base.getproperty` for `GeometricData` in
  `src/data/geometric_data.jl` (`if hasfield(TupleType, s)` → `if !hasfield(TupleType, s)`)
  survives `test/data/data_and_system_types.jl`. No other test file names `GeometricData`.
- **kind:** missing test
- **found:** 2026-09-26

### K5 · No CI job runs the suite on HDF5 0.16.11, the root floor.

- **location:** `Project.toml:16`
- **evidence:** the Downgrade log of the `main` run 36477203480 (job 109139865132) says "Package
  HDF5 from compat not found in resolved manifest". HDF5 is a weak dependency of the root, which
  `--min=@deps` does not force, and the test environment then takes HDF5 0.17.4. On Julia 1.13,
  HDF5 0.16.11 does not install: HDF5_jll is restricted to 1.10.5–1.12.2 by HDF5 and to
  1.14.3–2.2.2 by Julia.
- **kind:** not verified
- **found:** PR #32
