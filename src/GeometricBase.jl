module GeometricBase

    include("Config.jl")
    include("Utils.jl")

    include("methods.jl")
    include("types.jl")

    include("abstract_problem.jl")
    include("abstract_method.jl")
    include("abstract_integrator.jl")

end
