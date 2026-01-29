
function L2norm(x)
    mapreduce(xᵢ -> xᵢ * xᵢ, +, x)
end

function L2norm(x, y)
    @assert axes(x) == axes(y)
    mapreduce((xᵢ, yᵢ) -> (xᵢ - yᵢ)^2, +, x, y)
end

function l2norm(x...)
    sqrt(L2norm(x...))
end

function maxnorm(x)
    local r² = zero(eltype(x))
    @inbounds for xᵢ in x
        r² = max(r², xᵢ^2)
    end
    sqrt(r²)
end
