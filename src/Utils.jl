module Utils

export @define, @big

include("utils/macros.jl")

export compensated_summation, compensated_summation!

include("utils/summation.jl")

export L2norm, l2norm, maxnorm

include("utils/norms.jl")

end
