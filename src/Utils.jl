module Utils

    export @define, @big

    include("macros.jl")

    export compensated_summation, compensated_summation!

    include("summation.jl")

    export L2norm, l2norm

    include("norms.jl")

    export relative_l2_error, relative_maximum_error

    include("errors.jl")

end
