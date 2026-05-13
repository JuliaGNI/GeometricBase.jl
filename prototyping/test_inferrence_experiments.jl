using GeometricBase
using Test

# The type `State` has only one field that is a `NamedTuple`
struct State{keys,valTypes}
    values::valTypes

    function State(data::NamedTuple)
        _keys = map(x -> Val(x), keys(data))
        new{_keys,typeof(data)}(data)
    end
end

Base.keys(::State{keyVals}) where {keyVals} = keyVals
Base.values(st::State) = st.values

# `hasproperty` checks if `s` is either a key of the `NamedTuple` or a field in `State`
function Base.hasproperty(::State{keys}, s::Symbol) where {keys}
    Val(s) ∈ keys || hasfield(State, s)
end

# `getproperty` checks if `s` is a key of the `NamedTuple` and if so returns the corresponding value,
# if not it returns the corresponding field of `State`
function Base.getproperty(st::State{keys}, s::Symbol) where {keys}
    if Val(s) ∈ keys
        return getfield(st, :values)[s]
    else
        return getfield(st, s)
    end
end

# `getindex` is just forwarded to the `getindex` method of the `NamedTuple`
Base.getindex(st::State, ::Val{s}) where {s} = getindex(values(st), s)
Base.getindex(st::State, s::Symbol) = getindex(st, Val(s))


### Test for type stability ###

data = (
    t=TimeVariable(0.0),
    x=StateVariable(rand(3)),
    y=StateVariable(rand(3)),
)

st = State(data)
tmp = State(data)

@inferred st[Val(:t)]
@inferred st[Val(:x)]

function test_symbols_loop(dst, src)
    for k in keys(src)
        copy!(dst[k], src[k])
    end
end

@time test_symbols_loop(tmp, st)
@time test_symbols_loop(tmp, st)

@code_warntype test_symbols_loop(tmp, st)



function Base.copy!(dst::State, src::State)
    @assert keys(dst) == keys(src)
    for k in keys(state(dst))
        copy!(dst[k], src[k])
    end
    return dst
end

@time test_symbols_loop(tmp, st)
@time test_symbols_loop(tmp, st)

@code_warntype copy!(tmp, st)
