module GeometricBase

    using Base: Callable, TwicePrecision

    include("Config.jl")
    include("Utils.jl")


    export evaluate, evaluate!

    function evaluate end
    function evaluate! end

    export reset!, cut_periodic_solution!

    function reset! end
    function cut_periodic_solution! end

    export ntime, nsave, nsamples, nconstraints

    function ntime end
    function nsave end
    function nsamples end
    function nconstraints end

    export eachsample, eachtimestep, timestep, timesteps
    
    function eachsample end
    function eachtimestep end
    function timestep end
    function timesteps end

    export functions, solutions, invariants, parameters, periodicity

    function functions end
    function solutions end
    function invariants end
    function parameters end
    function periodicity end

    export equation, equations
    
    function equation end
    function equations end


    include("types.jl")

    export NullInvariants, NullParameters, NullPeriodicity

    export OptionalAbstractArray, OptionalArray,
           OptionalCallable, OptionalFunction,
           OptionalNamedTuple, OptionalTuple

    export OptionalInvariants,
           OptionalParameters,
           OptionalPeriodicity
    
    export AbstractData

    export State, StateVector, SolutionVector

    export vectorfield

end
