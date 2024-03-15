
export datatype, timetype, arrtype, equtype

function datatype end
function timetype end
function arrtype end
function equtype end

function evaluate end
function evaluate! end

function reset! end

function ntime end
function nsave end
function nsteps end
function nsamples end
function nconstraints end

function tspan end
function tstep end

tbegin(x) = tspan(x)[begin]
tend(x) = tspan(x)[end]

function eachsample end
function eachtimestep end
function timestep end
function timesteps end

function equation end
function equations end
function functions end
function solutions end
function invariants end
function parameters end
function periodicity end

function order end
function coefficients end
function tableau end

function name end
function description end
function reference end

function value end
