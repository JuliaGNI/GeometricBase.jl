module GeometricBase

include("Config.jl")
include("Utils.jl")

include("methods.jl")
include("types.jl")

include("abstract_problem.jl")
include("abstract_method.jl")
include("abstract_integrator.jl")
include("abstract_solution.jl")
include("abstract_solver.jl")
include("abstract_solver_state.jl")

include("data/system_types.jl")
include("data/data_types.jl")
include("data/geometric_data.jl")
include("data/state_variables.jl")
include("data/state.jl")

end
