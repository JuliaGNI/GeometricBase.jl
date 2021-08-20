module GeometricBase

    include("Config.jl")
    include("Utils.jl")


    include("types.jl")

    export NullInvariants, NullParameters

    export OptionalAbstractArray, OptionalArray,
           OptionalFunction, OptionalNamedTuple,
           OptionalInvariants, OptionalParameters
    
    export AbstractData

    export State, StateVector, SolutionVector


    export evaluate, evaluate!

    function evaluate end
    function evaluate! end

    export write_to_hdf5

    function write_to_hdf5 end

    export periodicity, reset!, cut_periodic_solution!

    function periodicity end
    function reset! end
    function cut_periodic_solution! end

    export ntime, nsamples, nconstraints,
           eachtimestep, eachsample

    function nsamples end
    function nconstraints end
    function ntime end
    function eachsample end
    function eachtimestep end

end
