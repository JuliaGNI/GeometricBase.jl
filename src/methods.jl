
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
[`AbstractStochasticProcess`](@ref).

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
