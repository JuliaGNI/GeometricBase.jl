using GeometricBase
using Test

using GeometricBase: variables

data = (
    t=TimeVariable(0.0),
    q=StateVariable(rand(3)),
    p=StateVariable(rand(3)),
    λ=AlgebraicVariable(rand(2)),
)

st1 = State(data)
st2 = State(data)

function Base.copy!(dst::State, src::State)
    @assert keys(dst) == keys(src)
    for k in keys(dst)
        copy!(dst[k], src[k])
    end
    return dst
end


function Base.copy!(dst::State, src::State)
    @assert keys(dst) == keys(src)
    map((x,y) -> copy!(x,y), variables(dst), variables(src))
    return dst
end


@code_warntype copy!(st1, st2)

@time copy!(st1, st2)
@time copy!(st1, st2)
