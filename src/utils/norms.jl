
function L2norm(x, y)
    @assert axes(x) == axes(y)
    mapfoldl(z -> (z[1] - z[2])^2, +, zip(x, y))
end

# `AbstractArray` and not `AbstractVector`: the sum of squares of an array's entries does not depend
# on how those entries are arranged, and `mapreduce` reads any of them the same way. Written on the
# vector alone until 0.14.9, which left every caller holding a matrix to reach for `L2norm(vec(a))` --
# and `vec` of a `Matrix` allocates a 32-byte reshape wrapper, per call and per matrix.
# `GeometricOptimizers` had exactly that as `l2norm(a::AbstractMatrix) = l2norm(vec(a))`, which was
# also type piracy on this function and on `Base`'s type, since it owns neither; taking the general
# method here retires it.
function L2norm(x::AbstractArray{T}) where {T}
    isempty(x) && return zero(T)
    mapreduce(xᵢ -> xᵢ * xᵢ, +, x)
end

L2norm(x::Real) = x^2

l2norm(x) = sqrt(L2norm(x))
l2norm(x, y) = sqrt(L2norm(x, y))

function maxnorm(x)
    local r² = zero(eltype(x))
    @inbounds for xᵢ in x
        r² = max(r², xᵢ^2)
    end
    sqrt(r²)
end
