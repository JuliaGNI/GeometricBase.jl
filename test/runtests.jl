using SafeTestsets

@safetestset "Abstract Problem                                                                " begin
    include("abstract_problem_tests.jl")
end
@safetestset "Abstract Solution                                                               " begin
    include("abstract_solution_tests.jl")
end
@safetestset "Abstract Integrator                                                             " begin
    include("abstract_integrator_tests.jl")
end
@safetestset "Abstract Method                                                                 " begin
    include("abstract_method_tests.jl")
end
@safetestset "Abstract Solver                                                                 " begin
    include("abstract_solver_tests.jl")
end
@safetestset "Geometric Data                                                                  " begin
    include("geometric_data_tests.jl")
end
@safetestset "State Variables                                                                 " begin
    include("state_variables_tests.jl")
end
@safetestset "States                                                                          " begin
    include("state_tests.jl")
end
@safetestset "Methods                                                                         " begin
    include("methods_tests.jl")
end
@safetestset "Types                                                                           " begin
    include("types_tests.jl")
end
@safetestset "Utils                                                                           " begin
    include("utils_tests.jl")
end
