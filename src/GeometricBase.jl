module GeometricBase

    using Base: TwicePrecision

    using Test

    include("Config.jl")
    include("Utils.jl")


    export evaluate, evaluate!

    function evaluate end
    function evaluate! end

    export reset!, cut_periodic_solution!

    function reset! end
    function cut_periodic_solution! end

    export ntime, nsave, nsamples, nconstraints
    export eachsample, eachtimestep, timesteps
    export parameters, periodicity

    function ntime end
    function nsave end
    function nsamples end
    function nconstraints end

    function eachsample end
    function eachtimestep end
    function timesteps end

    function parameters end
    function periodicity end
    

    include("types.jl")

    export NullInvariants, NullParameters, NullPeriodicity

    export OptionalAbstractArray, OptionalArray,
           OptionalFunction, OptionalNamedTuple,
           OptionalInvariants, OptionalParameters,
           OptionalPeriodicity
    
    export AbstractData

    export State, StateVector, SolutionVector


    include("solutions/dataseries.jl")

    export get_data!, set_data!
    export AbstractDataSeries, DataSeries,
           DataSeriesConstructor


    include("solutions/timeseries.jl")

    export TimeSeries, compute_timeseries!
    

    include("solutions/solution.jl")

    export Solution
    export counter, offset, lastentry

end
