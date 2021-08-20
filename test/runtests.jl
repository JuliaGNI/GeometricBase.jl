using SafeTestsets

@safetestset "Utils                                                                           " begin include("test_utils.jl") end
@safetestset "Time Series                                                                     " begin include("timeseries_tests.jl") end
@safetestset "Solution                                                                        " begin include("solution_tests.jl") end
