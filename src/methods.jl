
export datatype, timetype, arrtype, equtype

function datatype end
function timetype end
function arrtype end
function equtype end

export evaluate, evaluate!

function evaluate end
function evaluate! end

export reset!

function reset! end

export ntime, nsave, nsamples, nconstraints

function ntime end
function nsave end
function nsamples end
function nconstraints end

export tspan, tstep, tbegin, tend

function tspan end
function tstep end

tbegin(x) = tspan(x)[begin]
tend(x) = tspan(x)[end]

export eachsample, eachtimestep, timestep, timesteps

function eachsample end
function eachtimestep end
function timestep end
function timesteps end

export equation, equations, functions, solutions, invariants, parameters, periodicity

function equation end
function equations end
function functions end
function solutions end
function invariants end
function parameters end
function periodicity end

export order, coefficients, tableau

function order end
function coefficients end
function tableau end

export name, description, reference

function name end

description(::Any) = missing
reference(::Any) = missing

