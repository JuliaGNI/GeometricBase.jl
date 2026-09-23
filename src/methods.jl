
export datatype, timetype, arrtype, equtype

function datatype end
function timetype end
function arrtype end
function equtype end

function evaluate end
function evaluate! end
function solutionstep! end

function reset! end
function update! end

function ntime end
function nsave end
function nstore end
function nsteps end
function nsamples end
function nconstraints end
function nnodes end

"""
    noisedims(process)
    noisedims(equation)
    noisedims(problem)

The number of independent Wiener processes driving a stochastic differential equation.

This fixes the number of columns of the diffusion matrix, and it is what a stochastic integrator
uses to size the increment vectors it draws each step — so it has to be answerable from the
problem alone, before any integrator exists.
"""
function noisedims end

function eachsample end
function eachtimestep end
function timespan end
function timestep end
function timesteps end

function initialstate end

initialtime(x) = timespan(x)[begin]
finaltime(x) = timespan(x)[end]

function equation end
function equations end
function functions end
function solutions end
function invariants end
function parameters end
function periodicity end
function initialguess end

"""
    noise(equation)
    noise(problem)

The stochastic process driving a stochastic differential equation, an
`AbstractStochasticProcess`.

The process says *which* noise drives the equation, not which realisation of it: drawing
increments is the integrator's business, since only the integrator knows whether the scheme it
implements needs increments that are accurate in the strong or the weak sense.
"""
function noise end

function order end
function degree end
function coefficients end
function tableau end

function basis end
function nodes end
function weights end

function name end
function description end
function reference end

function value end
function variables end

"""
    h5save(h5, x; path)
    h5save(fpath::AbstractString, x, args...; mode = "w", kwargs...)

Write `x` into the HDF5 file or group `h5`, under the group `path`.

A package that stores one of its types in HDF5 adds a method for that type, usually in a package
extension on `HDF5`, so that one function serves every type. The method types `h5` as
`HDF5.H5DataStore`, and it chooses its own default for `path`.

The second form opens the file `fpath` with `mode`, and calls the first form on it with the other
arguments. It is defined when `HDF5` is loaded, and it works for every type with a method of the
first form. An untyped `h5` makes a method of the first form ambiguous with it.
"""
function h5save end

"""
    h5load(T, h5, args...; path)
    h5load(T, fpath::AbstractString, args...; kwargs...)

Read an object of type `T` from the group `path` of the HDF5 file or group `h5`, as written by
[`h5save`](@ref). The trailing arguments supply what the file cannot hold, for example the problem
that a solution belongs to.

A method types `h5` as `HDF5.H5DataStore`, and it chooses its own default for `path`. The second
form opens the file `fpath` read-only, and calls the first form on it. See [`h5save`](@ref).
"""
function h5load end
