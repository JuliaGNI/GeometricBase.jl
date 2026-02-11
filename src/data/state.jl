using Unicode: normalize

export State
export solution, state, vectorfield


# The `_state` function returns an appropriate empty state for a given state variable.
# _state(x::Number) = ScalarVariable(x)
_state(x::TimeVariable) = zero(x)
_state(x::StateVariable) = StateWithError(zero(x))
_state(x::VectorfieldVariable) = zero(x)
_state(x::AlgebraicVariable) = zero(x)
_state(x::StateWithError) = zero(x)

# The `_vectorfield` function returns an appropriate empty vectorfield for a given state variable.
# _vectorfield(x::Number) = missing
_vectorfield(x::TimeVariable) = missing
_vectorfield(x::StateVariable) = VectorfieldVariable(x)
_vectorfield(x::VectorfieldVariable) = missing
_vectorfield(x::AlgebraicVariable) = missing
_vectorfield(x::StateWithError) = _vectorfield(x.state)

# The `_convert` function returns an appropriate type for any given `AbstractVariable`.
# In particular, it returns the scalar value of a `TimeVariable`.
_convert(x::Missing)::Missing = x
_convert(x::TimeVariable) = value(x)
_convert(x::AbstractVariable) = x

# Adds a dot or bar to a symbol, indicating a time derivative or vector field, or a previous solution.
_add_symbol(s::Symbol, c::Char) = Symbol(normalize("$(s)$(c)"))
_add_bar(s::Symbol) = _add_symbol(s, Char(0x0304))
_add_dot(s::Symbol) = _add_symbol(s, Char(0x0307))

# Removes a dot or bar from a symbol.
_strip_symbol(s::Symbol, c::Char) = Symbol(strip(normalize(String(s); decompose=true), c))
_strip_bar(s::Symbol) = _strip_symbol(s, Char(0x0304))
_strip_dot(s::Symbol) = _strip_symbol(s, Char(0x0307))

# q̄ = Symbol(join([Char('q'), Char(0x0304)]))
# q̇ = Symbol(join([Char('q'), Char(0x0307)]))
# q = Symbol(strip(String(:q̄), Char(0x0304)))
# q = Symbol(strip(String(:q̇), Char(0x0307)))


"""
Holds the solution of a geometric equation at a single time step.

It stores all the information that is required to uniquely determine the state of a systen,
in particular all state variables and their corresponding vector fields.
"""
struct State{
    stateType<:NamedTuple,
    solutionType<:NamedTuple,
    vectorfieldType<:NamedTuple
}

    state::stateType
    solution::solutionType
    vectorfield::vectorfieldType

    function State(ics::NamedTuple)
        # create solution tupke for all variables in ics
        solution = NamedTuple{keys(ics)}(_state(x) for x in ics)

        # create vectorfield vector for all state variables in ics
        vectorfield = NamedTuple{keys(ics)}(_vectorfield(x) for x in ics)

        # remove all fields that are missing, i.e., that correspond to a variable without vectorfield
        vectorfield_filtered = NamedTuple{filter(k -> !all(ismissing.(vectorfield[k])), keys(vectorfield))}(vectorfield)

        # create vector field symbols with dotted solution symbols
        vectorfield_keys = Tuple(_add_dot(k) for k in keys(vectorfield_filtered))
        vectorfield_dots = NamedTuple{vectorfield_keys}(values(vectorfield_filtered))

        # create state by merging solution fields with filtered vector fields
        state_fields = merge(solution, vectorfield_dots)

        # create state
        state = new{typeof(state_fields),typeof(solution),typeof(vectorfield_filtered)}(state_fields, solution, vectorfield_filtered)

        # copy initial conditions to state
        copy!(state, ics)

        return state
    end
end

@inline function Base.hasproperty(::State{ST}, s::Symbol) where {ST}
    hasfield(ST, s) || hasfield(State, s)
end

@inline function Base.getproperty(st::State{ST}, s::Symbol) where {ST}
    if hasfield(ST, s)
        return _convert(getfield(st, :state)[s])
    else
        return getfield(st, s)
    end
end

@inline function Base.setproperty!(st::State{ST}, s::Symbol, x) where {ST}
    if hasfield(ST, s)
        return copy!(getfield(st, :state)[s], x)
    else
        return setfield!(st, s, x)
    end
end


state(st::State) = st.state
solution(st::State) = st.solution
vectorfield(st::State) = st.vectorfield

"""
    keys(st::State)

Return the keys of all the state variables in the `State`.
"""
Base.keys(st::State) = keys(state(st))

"""
    copy!(st::State, sol::NamedTuple)

Copy the values from a `NamedTuple` `sol` to the `State` `st`.

The keys of `sol` must be a subset of the keys of the state.

# Arguments
- `st`: the state to copy into
- `sol`: the named tuple containing the solution values to copy
"""
function Base.copy!(st::State, sol::NamedTuple)
    @assert keys(sol) ⊆ keys(st)

    for k in keys(sol)
        copy!(solution(st)[k], sol[k])
    end

    return st
end
