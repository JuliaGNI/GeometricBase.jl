
function L2norm(x)
    mapreduce(xᵢ -> xᵢ * xᵢ, +, x)
end

function L2norm(x, y)
    @assert axes(x) == axes(y)
    mapfoldl(z -> (z[1] - z[2])^2, +, zip(x, y))
end

l2norm(x) = sqrt(L2norm(x))
l2norm(x, y) = sqrt(L2norm(x, y))

function maxnorm(x)
    local r² = zero(eltype(x))
    @inbounds for xᵢ in x
        r² = max(r², xᵢ^2)
    end
    sqrt(r²)
end
