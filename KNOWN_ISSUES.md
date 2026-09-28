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

### K5 · `noteq_agrees` accepts a `≠` that returns a non-`Bool`.

- **location:** `test/data/state_variables.jl:232`
- **evidence:** `isequal(1, true)` is `true`, so the helper passes a `≠` that returns an `Int`. The
  mutant `Base.:(≠)(x::AbstractScalarVariable, y::Number) = Int(value(x) ≠ y)` in
  `src/data/state_variables.jl` survives `test/data/state_variables.jl` (1738/1738 pass). The
  `===` assertions that the helper replaces catch it. A possible fix is
  `noteq_agrees(x, y) = (r = x ≠ y; (r isa Bool || r === missing) && isequal(r, !(x == y)))`.
- **kind:** missing test
- **found:** 2026-09-28
