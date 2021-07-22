
function compensated_summation(x::T, δ::T, ε::T) where {T}
    a = x
    ε = ε + δ
    x = a + ε
    ε = ε + (a - x)

    return (x, ε)
end

function compensated_summation(x::VT, δ::VT, ε::VT) where {T, VT <: AbstractVector{T}}
    a  = copy(x)
    ε  = ε .+ δ
    x̄  = a .+ ε
    ε̄ = ε .+ (a .- x̄)

    return (x̄, ε̄)
end

function compensated_summation!(x::VT, δ::VT, ε::VT) where {T, VT <: AbstractVector{T}}
    a  = copy(x)
    ε  = ε .+ δ
    x .= a .+ ε
    ε .= ε .+ (a .- x)

    return (x, ε)
end
