
function L2norm(x)
    mapreduce(xᵢ -> xᵢ * xᵢ, +, x)
end

function l2norm(x)
    sqrt(L2norm(x))
end
