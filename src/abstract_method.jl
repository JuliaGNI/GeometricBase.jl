
export AbstractMethod, isAbstractMethod

abstract type AbstractMethod end

Base.parent(::AbstractMethod) = nothing

isexplicit(::AbstractMethod) = missing
isimplicit(::AbstractMethod) = missing
issymmetric(::AbstractMethod) = missing
issymplectic(::AbstractMethod) = missing
isenergypreserving(::AbstractMethod) = missing
isstifflyaccurate(::AbstractMethod) = missing

order(::Union{AbstractMethod, Type{<:AbstractMethod}}) = missing
name(::Union{AbstractMethod, Type{<:AbstractMethod}}) = missing
description(::Union{AbstractMethod, Type{<:AbstractMethod}}) = missing
reference(::Union{AbstractMethod, Type{<:AbstractMethod}}) = missing

"""
    isAbstractMethod(method)

`true` when `method` is an `AbstractMethod` whose ten properties `isexplicit`, `isimplicit`,
`issymmetric`, `issymplectic`, `isenergypreserving`, `isstifflyaccurate`, `order`, `name`,
`description` and `reference` all answer other than `missing`, and `false` otherwise. A
property that throws makes `isAbstractMethod` throw. [`interface_violations`](@ref) lists the
properties that throw, answer the wrong type, are defined again in a module of the method, or,
on request, answer `missing`.
"""
isAbstractMethod(::Any) = false

function isAbstractMethod(method::AbstractMethod)
    isexplicit(method) === missing && return false
    isimplicit(method) === missing && return false
    issymmetric(method) === missing && return false
    issymplectic(method) === missing && return false
    isenergypreserving(method) === missing && return false
    isstifflyaccurate(method) === missing && return false
    order(method) === missing && return false
    name(method) === missing && return false
    description(method) === missing && return false
    reference(method) === missing && return false
    return true
end

const METHOD_PROPERTIES = (isexplicit, isimplicit, issymmetric, issymplectic,
    isenergypreserving, isstifflyaccurate, order, name, description, reference)

const BOOL_PROPERTIES = (isexplicit, isimplicit, issymmetric, issymplectic,
    isenergypreserving, isstifflyaccurate)

const Violation = @NamedTuple{f::Symbol, kind::Symbol, detail::String}

"""
    interface_violations(method::AbstractMethod; include_missing = false)

The violations of the contract of `AbstractMethod` by `method`, in the form of
[`interface_violations`](@ref), for its ten properties, in the order `isexplicit`, `isimplicit`,
`issymmetric`, `issymplectic`, `isenergypreserving`, `isstifflyaccurate`, `order`, `name`,
`description` and `reference`. Each property gives at most one entry of each kind:

- `:shadowed`: a module of the method binds the name of the property to a `Function` of its own
  that does not extend GeometricBase's, so a definition there does not reach GeometricBase's
  property. The modules of the method are the module of its type and each of its parents, up to
  the first module that is its own parent, such as the root module of a package, and never
  `Main`, `Base` or `Core`, unless the type is defined there. A function owned by another
  module, such as one that `using` brings in, is not a shadow, and a module off this chain, such
  as a sibling submodule, is not read. `detail` names the module that owns the function, which
  can be a parent of the module that binds it. This entry comes before the entry of the call.
- `:throws`: the call of the property on `method` throws; `detail` names the exception's type.
  An `InterruptException` is thrown again.
- `:type`: a property `is…` answers other than a `Bool` or `missing`, or `order` answers other
  than an `Integer` that is not a `Bool`, or `missing`; `detail` names the type of the answer.
  `name`, `description` and `reference` have no type rule.
- `:missing`: the property answers `missing`; reported only with `include_missing = true`.

Unlike for [`isAbstractMethod`](@ref), an answer `missing` is no violation by default. Each
property is called on `method` only: the contract also defines `order`, `name`, `description`
and `reference` on the type of `method`, and those answers are not checked.
"""
function interface_violations(method::AbstractMethod; include_missing::Bool = false)
    violations = Violation[]
    modules = method_modules(typeof(method))
    for f in METHOD_PROPERTIES
        fname = nameof(f)
        for m in modules
            owner = shadow_owner(m, fname, f, modules)
            if owner !== nothing
                detail = "module $owner defines its own `$fname`, " *
                         "which does not extend `GeometricBase.$fname`"
                push!(violations, (; f = fname, kind = :shadowed, detail))
                break
            end
        end
        answer = try
            f(method)
        catch e
            e isa InterruptException && rethrow()
            push!(violations, (; f = fname, kind = :throws, detail = "throws $(typeof(e))"))
            continue
        end
        if answer === missing
            include_missing &&
                push!(violations, (;
                    f = fname, kind = :missing, detail = "answers `missing`"))
        elseif !answer_has_type(f, answer)
            push!(violations, (; f = fname, kind = :type,
                detail = "answers a value of type $(typeof(answer))"))
        end
    end
    return violations
end

function answer_has_type(f, answer)
    f in BOOL_PROPERTIES ? answer isa Bool :
    f === order ? answer isa Integer && !(answer isa Bool) : true
end

# The module of a method type and its parents, up to the first module that is its own parent.
# `Main`, `Base` and `Core` end the chain and are not part of it, unless `T` is defined there.
function method_modules(T::Type)
    m = parentmodule(T)
    modules = [m]
    while parentmodule(m) !== m
        m = parentmodule(m)
        m in (Main, Base, Core) && break
        push!(modules, m)
    end
    return modules
end

# The module that owns the function that `m` binds to `fname`, where that function is not `f`
# and its owner is one of `modules`; `nothing` otherwise.
function shadow_owner(m::Module, fname::Symbol, f, modules)
    isdefined(m, fname) || return nothing
    g = getglobal(m, fname)
    (g isa Function && g !== f) || return nothing
    owner = parentmodule(g)
    return owner in modules ? owner : nothing
end
