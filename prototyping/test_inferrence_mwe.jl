using Test

# The type `Wrapper` has only one field that is a `NamedTuple`
struct Wrapper{wrapperType<:NamedTuple}
    data::wrapperType
end

function Wrapper(data::NamedTuple)
    Wrapper{typeof(data)}(data)
end

# `hasproperty` checks if `s` is either a key of the `NamedTuple` or a field in `Wrapper`
function Base.hasproperty(::Wrapper{WT}, s::Symbol) where {WT}
    hasfield(WT, s) || hasfield(Wrapper, s)
end

# `getproperty` checks if `s` is a key of the `NamedTuple` and if so returns the corresponding value,
# if not it returns the corresponding field of `Wrapper`
function Base.getproperty(w::Wrapper{WT}, s::Symbol) where {WT}
    if hasfield(WT, s)
        return getfield(getfield(w, :data), s)
    else
        return getfield(w, s)
    end
end

# Return wrapped NamedTuple
Base.parent(w::Wrapper) = w.data
Base.keys(w::Wrapper) = keys(parent(w))

# This getindex method recieves the key symbol wrapped in Val,
# which implies that the value is known at compile time
Base.getindex(w::Wrapper, ::Val{s}) where {s} = getindex(parent(w), s)

# This getindex method wraps the key symbol into a Val, and passes it on to the above method
Base.getindex(w::Wrapper, s::Symbol) = getindex(w, Val(s))


### Test for type stability ###

# Create a `Wrapper` instance based on some arbitrary data (with different types)

data = (
    t=0.0,
    x=rand(3),
)

wr = Wrapper(data)

# Accessing fields of NamedTuple via forwarding in getproperty is type-stable
# as the value of the key symbol is known at compile time:

test_t(wrapper) = wrapper.t
test_x(wrapper) = wrapper.x

@inferred test_t(wr)
@inferred test_x(wr)


# Accessing fields of NamedTuple via getindex of Val{<:Symbol} is type stable

test_symbol(wrapper, s) = wrapper[s]

@inferred test_symbol(wr, Val(:t))
@inferred test_symbol(wr, Val(:x))

@inferred wr[Val(:t)]
@inferred wr[Val(:x)]


# Accessing fields of NamedTuple via getindex of Val{<:Symbol} with
# Val wrapping inside a loop seems also type stable but it not

function test_symbols_inferred(wrapper, keys)
    for k in keys
        @inferred wrapper[Val(k)]
    end
end

test_symbols_inferred(wr, (:t, :x))


function test_symbols_warntype(wrapper, keys)
    for k in keys
        @code_warntype wrapper[Val(k)]
    end
end

test_symbols_warntype(wr, (:t, :x))


function test_symbols(wrapper, keys)
    (wrapper[Val(k)] for k in keys)
end

@code_warntype test_symbols(wr, (:t, :x))


function test_symbols_loop(wrapper, keys)
    for k in keys
        wrapper[Val(k)]
    end
end

_keys2 = (:t, :x)
@time test_symbols(wr, _keys2)
@time test_symbols(wr, _keys2)

_keys8 = (:t, :t, :t, :t, :x, :x, :x, :x)
@time test_symbols(wr, _keys8)
@time test_symbols(wr, _keys8)


# Accessing fields of NamedTuple via getindex of Symbol that wraps the key
# symbol into a Val is not type stable

@inferred test_symbol(wr, :t)
@inferred test_symbol(wr, :x)
