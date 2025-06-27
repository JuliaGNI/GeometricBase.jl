
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

function eachsample end
function eachtimestep end
function timespan end
function timestep end
function timesteps end

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

function order end
function coefficients end
function tableau end

function name end
function description end
function reference end

function value end
