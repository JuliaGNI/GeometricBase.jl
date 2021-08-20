module Utils

    export @define, @big

    include("utils/macros.jl")

    export compensated_summation, compensated_summation!

    include("utils/summation.jl")

    export L2norm, l2norm

    include("utils/norms.jl")

    export relative_l2_error, relative_maximum_error

    include("utils/errors.jl")

end
