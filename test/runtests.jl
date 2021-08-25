using SafeTestsets

@safetestset "Utils                                                                           " begin include("utils_tests.jl") end
@safetestset "Data Series                                                                     " begin include("dataseries_tests.jl") end
@safetestset "Time Series                                                                     " begin include("timeseries_tests.jl") end
@safetestset "Solution                                                                        " begin include("solution_tests.jl") end
