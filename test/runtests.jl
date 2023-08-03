using SafeTestsets

@safetestset "Abstract Integrator                                                             " begin include("abstract_integrator_tests.jl") end
@safetestset "Abstract Method                                                                 " begin include("abstract_method_tests.jl") end
@safetestset "Types                                                                           " begin include("types_tests.jl") end
@safetestset "Utils                                                                           " begin include("utils_tests.jl") end
