using SafeTestsets

@safetestset "Types                                                                           " begin include("types_tests.jl") end
@safetestset "Utils                                                                           " begin include("utils_tests.jl") end
