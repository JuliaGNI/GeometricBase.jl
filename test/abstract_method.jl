using GeometricBase
using Test

struct TestMethod <: AbstractMethod end

method = TestMethod()

@test parent(method) === nothing

@test ismissing(GeometricBase.isexplicit(method))
@test ismissing(GeometricBase.isimplicit(method))
@test ismissing(GeometricBase.issymmetric(method))
@test ismissing(GeometricBase.issymplectic(method))
@test ismissing(GeometricBase.isenergypreserving(method))
@test ismissing(GeometricBase.isstifflyaccurate(method))
@test ismissing(GeometricBase.order(method))
@test ismissing(GeometricBase.name(method))
@test ismissing(GeometricBase.description(method))
@test ismissing(GeometricBase.reference(method))

@test !isAbstractMethod(method)

GeometricBase.isexplicit(method::TestMethod) = true
GeometricBase.isimplicit(method::TestMethod) = false
GeometricBase.issymmetric(method::TestMethod) = false
GeometricBase.issymplectic(method::TestMethod) = false
GeometricBase.isenergypreserving(method::TestMethod) = false
GeometricBase.isstifflyaccurate(method::TestMethod) = false

GeometricBase.order(::Union{TestMethod, Type{<:TestMethod}}) = 0
GeometricBase.name(::Union{TestMethod, Type{<:TestMethod}}) = "My Method"
GeometricBase.description(::Union{TestMethod, Type{<:TestMethod}}) = "Test Method"
GeometricBase.reference(::Union{TestMethod, Type{<:TestMethod}}) = "n/a"

@test isAbstractMethod(method)
@test !isAbstractMethod(42)

# The ten properties in the order of `src/abstract_method.jl`, each with an answer of the
# right type. `complete!` defines them for a fixture method type, except the names in `except`.
const PROPERTIES = (:isexplicit, :isimplicit, :issymmetric, :issymplectic,
    :isenergypreserving, :isstifflyaccurate, :order, :name, :description, :reference)
const ANSWERS = (true, false, true, false, true, false, 3, "Fixture", "A fixture", "none")

function complete!(T::Type; except = ())
    for (f, answer) in zip(PROPERTIES, ANSWERS)
        f in except && continue
        @eval GeometricBase.$f(::$T) = $answer
    end
    return T
end

const Violation = @NamedTuple{f::Symbol, kind::Symbol, detail::String}

struct OneThrows <: AbstractMethod end
complete!(OneThrows; except = (:issymmetric,))
GeometricBase.issymmetric(::OneThrows) = error("no answer")

struct TwoThrow <: AbstractMethod end
complete!(TwoThrow; except = (:isexplicit, :reference))
GeometricBase.isexplicit(::TwoThrow) = throw(ArgumentError("no answer"))
GeometricBase.reference(::TwoThrow) = error("no answer")

struct Interrupts <: AbstractMethod end
complete!(Interrupts; except = (:order,))
GeometricBase.order(::Interrupts) = throw(InterruptException())

struct IntSymplectic <: AbstractMethod end
complete!(IntSymplectic; except = (:issymplectic,))
GeometricBase.issymplectic(::IntSymplectic) = 1

struct FloatOrder <: AbstractMethod end
complete!(FloatOrder; except = (:order,))
GeometricBase.order(::FloatOrder) = 2.0

struct BoolOrder <: AbstractMethod end
complete!(BoolOrder; except = (:order,))
GeometricBase.order(::BoolOrder) = true

struct BigOrder <: AbstractMethod end
complete!(BigOrder; except = (:order,))
GeometricBase.order(::BigOrder) = big(4)

struct FreeText <: AbstractMethod end
complete!(FreeText; except = (:name, :description, :reference))
GeometricBase.name(::FreeText) = :fixture
GeometricBase.description(::FreeText) = nothing
GeometricBase.reference(::FreeText) = 42

struct NoProperty <: AbstractMethod end

# A module that defines its own `issymplectic`, which does not extend GeometricBase's.
module LocalGeneric
using GeometricBase
struct MyMethod <: AbstractMethod end
issymplectic(::MyMethod) = true
end

complete!(LocalGeneric.MyMethod; except = (:issymplectic,))

# A method type in a submodule, whose parent defines its own `order`.
module Outer
using GeometricBase
order(x) = 2
module Sub
using GeometricBase
struct SubMethod <: AbstractMethod end
end
end

complete!(Outer.Sub.SubMethod)

# Two modules of one chain that both define their own `order`.
module Twice
using GeometricBase
order(x) = 2
module Inner
using GeometricBase
order(x) = 3
struct InnerMethod <: AbstractMethod end
end
end

complete!(Twice.Inner.InnerMethod)

# A package root is its own parent, as a module made in `Base.__toplevel__` is.
const Root = Core.eval(Base.__toplevel__,
    :(module InterfaceViolationsRoot
    using GeometricBase
    description(x) = "own"
    module Sub
    using GeometricBase
    struct RootMethod <: AbstractMethod end
    end
    end))

complete!(Root.Sub.RootMethod)

# Bindings that are no shadow: an import of GeometricBase's function, a constant, a function
# that `using` brings in from another module, and no binding.
module ExportsName
export name
name(x) = 1
end

module NoShadow
using GeometricBase
import GeometricBase: issymplectic
using ..ExportsName
const order = 3
struct NoShadowMethod <: AbstractMethod end
end

complete!(NoShadow.NoShadowMethod)

# `Main` ends the chain of a method type defined below it, and is the module of a method type
# defined in it. `Main` binds its own `isstifflyaccurate` before any testset runs, so the
# parent-module testset sees that `Main` is not part of the chain of `Outer.Sub.SubMethod`.
# Each include names the type anew, so a second include in one process defines no type again.
const MainMethod = let T = gensym(:InterfaceViolationsMainMethod)
    Core.eval(Main, :(function isstifflyaccurate end; struct $T <: $AbstractMethod end; $T))
end

complete!(MainMethod)

@testset "no method for a value without a contract" begin
    @test Base.ispublic(GeometricBase, :interface_violations)
    @test !Base.isexported(GeometricBase, :interface_violations)
    @test_throws r"^MethodError: no method matching interface_violations\(::Int64\)" GeometricBase.interface_violations(42)
    @test_throws r"^MethodError: no method matching interface_violations\(::Nothing\)" GeometricBase.interface_violations(nothing)
end

@testset "a complete method has no violation" begin
    v = GeometricBase.interface_violations(method)
    @test v isa Vector{Violation}
    @test isempty(v)
    w = GeometricBase.interface_violations(method; include_missing = true)
    @test w isa Vector{Violation}
    @test isempty(w)
end

@testset "a property that throws" begin
    v = GeometricBase.interface_violations(OneThrows())
    @test length(v) == 1
    @test v[1].f === :issymmetric
    @test v[1].kind === :throws
    @test occursin("ErrorException", v[1].detail)

    w = GeometricBase.interface_violations(TwoThrow())
    @test [(x.f, x.kind) for x in w] == [(:isexplicit, :throws), (:reference, :throws)]
    @test occursin("ArgumentError", w[1].detail)
    @test occursin("ErrorException", w[2].detail)
end

@testset "an interrupt is not reported" begin
    # `@test_throws` passes an `InterruptException` on unless its pattern is that type, and the
    # exception carries no message to match.
    # ast-grep-ignore: test-throws-bare-type
    @test_throws InterruptException GeometricBase.interface_violations(Interrupts())
end

@testset "the type of an answer" begin
    v = GeometricBase.interface_violations(IntSymplectic())
    @test [(x.f, x.kind) for x in v] == [(:issymplectic, :type)]
    @test occursin("Int64", v[1].detail)

    v = GeometricBase.interface_violations(FloatOrder())
    @test [(x.f, x.kind) for x in v] == [(:order, :type)]
    @test occursin("Float64", v[1].detail)

    v = GeometricBase.interface_violations(BoolOrder())
    @test [(x.f, x.kind) for x in v] == [(:order, :type)]
    @test occursin("Bool", v[1].detail)

    @test isempty(GeometricBase.interface_violations(BigOrder()))
    @test isempty(GeometricBase.interface_violations(FreeText()))
end

@testset "a property defined again in the module of the method" begin
    v = GeometricBase.interface_violations(LocalGeneric.MyMethod())
    @test [(x.f, x.kind) for x in v] == [(:issymplectic, :shadowed)]
    @test occursin("LocalGeneric", v[1].detail)

    w = GeometricBase.interface_violations(LocalGeneric.MyMethod(); include_missing = true)
    @test [(x.f, x.kind) for x in w] ==
          [(:issymplectic, :shadowed), (:issymplectic, :missing)]

    m = GeometricBase.interface_violations(MainMethod())
    @test [(x.f, x.kind) for x in m] == [(:isstifflyaccurate, :shadowed)]
    @test occursin("Main", m[1].detail)
end

@testset "a property defined again in a parent module" begin
    v = GeometricBase.interface_violations(Outer.Sub.SubMethod())
    @test [(x.f, x.kind) for x in v] == [(:order, :shadowed)]
    @test occursin("Outer", v[1].detail)

    w = GeometricBase.interface_violations(Twice.Inner.InnerMethod())
    @test [(x.f, x.kind) for x in w] == [(:order, :shadowed)]

    r = GeometricBase.interface_violations(Root.Sub.RootMethod())
    @test [(x.f, x.kind) for x in r] == [(:description, :shadowed)]
    @test occursin("InterfaceViolationsRoot", r[1].detail)
end

@testset "bindings that are no shadow" begin
    @test getglobal(NoShadow, :issymplectic) === GeometricBase.issymplectic
    @test getglobal(NoShadow, :order) === 3
    @test getglobal(NoShadow, :name) === ExportsName.name
    @test !isdefined(NoShadow, :description)
    @test isempty(GeometricBase.interface_violations(NoShadow.NoShadowMethod()))
    @test isempty(GeometricBase.interface_violations(NoSolver()))
end

@testset "missing answers" begin
    @test isempty(GeometricBase.interface_violations(NoProperty()))
    v = GeometricBase.interface_violations(NoProperty(); include_missing = true)
    @test v isa Vector{Violation}
    @test [x.f for x in v] == collect(PROPERTIES)
    @test all(x -> x.kind === :missing, v)
end
