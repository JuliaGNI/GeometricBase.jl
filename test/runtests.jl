using SafeTestsets

@safetestset "Geometric Integrator                                                            " begin include("geometric_integrator_tests.jl") end
@safetestset "Geometric Method                                                                " begin include("geometric_method_tests.jl") end
@safetestset "Types                                                                           " begin include("types_tests.jl") end
@safetestset "Utils                                                                           " begin include("utils_tests.jl") end
