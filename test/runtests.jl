using SafeTestsets

@safetestset "Types                                                                           " begin include("types_tests.jl") end
@safetestset "Utils                                                                           " begin include("utils_tests.jl") end
@safetestset "Data Series                                                                     " begin include("dataseries_tests.jl") end
@safetestset "Time Series                                                                     " begin include("timeseries_tests.jl") end
@safetestset "Solution                                                                        " begin include("solution_tests.jl") end
