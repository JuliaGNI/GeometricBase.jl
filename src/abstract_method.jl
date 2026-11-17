
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

const TYPE_PROPERTIES = (order, name, description, reference)

const Violation = @NamedTuple{f::Symbol, kind::Symbol, detail::String}

"""
    interface_violations(method::AbstractMethod; include_missing = false)

The violations of the contract of `AbstractMethod` by `method`, in the form of
[`interface_violations`](@ref), for its ten properties, in the order `isexplicit`, `isimplicit`,
`issymmetric`, `issymplectic`, `isenergypreserving`, `isstifflyaccurate`, `order`, `name`,
`description` and `reference`. Each property gives at most one `:shadowed` entry, and each call
of a property at most one entry of the other kinds:

- `:shadowed`: a module of the method binds the name of the property to a `Function` that is not
  GeometricBase's and has a method applicable to `method` or to its type, so a definition there
  does not reach GeometricBase's property. The binding is a definition in the module or an
  `import`; a binding that `using` brings in is not read, and a function with no such method is
  not a shadow. The modules of the method are the module of its type and each of its parents, up
  to the first module that is its own parent, such as the root module of a package, and never
  `Main`, `Base` or `Core`, unless the type is defined there. A module off this chain, such as a
  sibling submodule, is not read. `detail` names the module that owns the function, which can
  be a module off the chain. This entry comes before the entries of the calls.
- `:throws`: the call of the property throws; `detail` names the exception's type. An
  `InterruptException` is thrown again.
- `:type`: a property `is…` answers other than a `Bool` or `missing`, or `order` answers other
  than an `Integer` that is not a `Bool`, or `missing`; on the type of `method`, `order` may also
  answer an `AbstractString`, such as the formula `"2s"` in the number of stages `s`, but on
  `method` a string is a violation. `detail` names the type of the answer. `name`, `description`
  and `reference` have no type rule.
- `:missing`: the property answers `missing` on `method`; reported only with
  `include_missing = true`.

Each property is called on `method`. `order`, `name`, `description` and `reference` are also
called on the type of `method`, and give the entries `:throws` and `:type` by the same rules,
except that `order` may answer an `AbstractString` there; their `detail` ends in "on the type",
and they come after the entries of the call on `method`. An answer `missing` on the type is no
violation. Unlike for [`isAbstractMethod`](@ref), an answer `missing` on `method` is no
violation by default.
"""
function interface_violations(method::AbstractMethod; include_missing::Bool = false)
    violations = Violation[]
    T = typeof(method)
    modules = method_modules(T)
    for f in METHOD_PROPERTIES
        fname = nameof(f)
        for m in modules
            owner = shadow_owner(m, fname, f, T)
            if owner !== nothing
                detail = "module $owner defines its own `$fname`, " *
                         "which does not extend `GeometricBase.$fname`"
                push!(violations, (; f = fname, kind = :shadowed, detail))
                break
            end
        end
        check_answer!(violations, f, method, "", include_missing)
        f in TYPE_PROPERTIES && check_answer!(violations, f, T, " on the type", false)
    end
    return violations
end

# Calls `f(x)` and pushes the entry of its answer, if any, with `suffix` appended to `detail`.
function check_answer!(violations, f, x, suffix, include_missing)
    fname = nameof(f)
    answer = try
        f(x)
    catch e
        e isa InterruptException && rethrow()
        push!(violations, (;
            f = fname, kind = :throws, detail = "throws $(typeof(e))$suffix"))
        return violations
    end
    if answer === missing
        include_missing &&
            push!(violations, (; f = fname, kind = :missing, detail = "answers `missing`"))
    elseif !answer_has_type(f, answer, x isa Type)
        push!(violations,
            (; f = fname, kind = :type,
                detail = "answers a value of type $(typeof(answer))$suffix"))
    end
    return violations
end

# Whether `answer` has the type that the rule of `f` asks for. `on_type` is `true` for the call
# on the type of a method, where `order` may answer a formula, such as "2s" in the number of
# stages `s`, as an `AbstractString`.
function answer_has_type(f, answer, on_type::Bool)
    f in BOOL_PROPERTIES && return answer isa Bool
    f === order || return true
    on_type && answer isa AbstractString && return true
    return answer isa Integer && !(answer isa Bool)
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

# The module that owns the function that `m` binds to `fname` by a definition or an `import`,
# where that function is not `f` and has a method for `T` or for `Type{T}`; `nothing` otherwise.
# `names(m; imported = true)` holds the names that `m` defines or imports, not those of `using`.
function shadow_owner(m::Module, fname::Symbol, f, T::Type)
    isdefined(m, fname) || return nothing
    g = getglobal(m, fname)
    (g isa Function && g !== f) || return nothing
    (hasmethod(g, Tuple{T}) || hasmethod(g, Tuple{Type{T}})) || return nothing
    fname in names(m; all = true, imported = true) || return nothing
    return parentmodule(g)
end
