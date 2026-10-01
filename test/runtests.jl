using SafeTestsets

const GROUPS = isempty(ARGS) ? ["core", "slow"] : ARGS

if "core" in GROUPS
    @safetestset "Aqua" include("quality/aqua.jl")
    @safetestset "ExplicitImports" include("quality/explicit_imports.jl")
    @safetestset "Interface Tests" include("integration/interface.jl")
    @safetestset "Abstract Problem" include("abstract_problem.jl")
    @safetestset "Abstract Solution" include("abstract_solution.jl")
    @safetestset "Abstract Integrator" include("abstract_integrator.jl")
    @safetestset "Abstract Method" include("abstract_method.jl")
    @safetestset "Abstract Solver" include("abstract_solver.jl")
    @safetestset "Data and System Types" include("data/data_and_system_types.jl")
    @safetestset "State Variables" include("data/state_variables.jl")
    @safetestset "States" include("data/state.jl")
    @safetestset "Methods" include("methods.jl")
    @safetestset "Public Names" include("public.jl")
    @safetestset "HDF5 Extension" include("integration/hdf5_ext.jl")
    @safetestset "Types" include("types.jl")
    @safetestset "Utils" include("Utils.jl")
end
