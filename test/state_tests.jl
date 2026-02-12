using GeometricBase
using Test

using GeometricBase: StateWithError, TimeVariable, VectorfieldVariable
using GeometricBase: periodic, value
using GeometricBase: _strip_symbol, _strip_bar, _strip_dot, _add_symbol, _add_bar, _add_dot, _state, _vectorfield


@testset "$(rpad("State Helper Functions",80))" begin

    x = rand(3)

    @test _strip_symbol(:q̄, Char(0x0304)) == :q
    @test _strip_symbol(:q̇, Char(0x0307)) == :q

    @test _strip_bar(:q̄) == :q
    @test _strip_dot(:q̇) == :q

    @test _add_symbol(:q, Char(0x0304)) == :q̄
    @test _add_symbol(:q, Char(0x0307)) == :q̇

    @test _add_bar(:q) == :q̄
    @test _add_dot(:q) == :q̇

    @test _state(TimeVariable(1.0)) == TimeVariable(0.0)
    @test _state(StateVariable(x)) == StateWithError(StateVariable(zero(x)))

    # @test ismissing(_vectorfield(1))
    @test ismissing(_vectorfield(TimeVariable(1.0)))
    @test ismissing(_vectorfield(AlgebraicVariable(x)))
    @test ismissing(_vectorfield(VectorfieldVariable(StateVariable(x))))

    @test _vectorfield(StateVariable(x)) == VectorfieldVariable(zero(x))
    @test _vectorfield(StateWithError(StateVariable(x))) == VectorfieldVariable(zero(x))

end


@testset "$(rpad("State Constructor and Access Functions",80))" begin

    data = (
        t=TimeVariable(0.0),
        q=StateVariable(rand(3)),
        p=StateVariable(rand(3)),
        λ=AlgebraicVariable(rand(2)),
    )

    st = State(data; initialize=false)

    @test state(st) == st.state
    @test solution(st) == st.solution
    @test vectorfield(st) == st.vectorfield

    @test keys(st) == keys(state(st))

    # @test st.t ≠ data.t
    @test st.q ≠ data.q
    @test st.p ≠ data.p
    @test st.λ ≠ data.λ

    @test st.t == zero(data.t)
    @test st.q == zero(data.q)
    @test st.p == zero(data.p)
    @test st.λ == zero(data.λ)


    st = State(data)

    @test st.t == data.t
    @test st.q == data.q
    @test st.p == data.p
    @test st.λ == data.λ

    @test hasproperty(st, :t)
    @test hasproperty(st, :q)
    @test hasproperty(st, :p)
    @test hasproperty(st, :λ)
    @test hasproperty(st, :q̇)
    @test hasproperty(st, :ṗ)

    @test :t ∈ keys(st)
    @test :q ∈ keys(st)
    @test :p ∈ keys(st)
    @test :λ ∈ keys(st)
    @test :q̇ ∈ keys(st)
    @test :ṗ ∈ keys(st)

    @test :t ∈ keys(state(st))
    @test :q ∈ keys(state(st))
    @test :p ∈ keys(state(st))
    @test :λ ∈ keys(state(st))
    @test :q̇ ∈ keys(state(st))
    @test :ṗ ∈ keys(state(st))

    @test :t ∈ keys(solution(st))
    @test :q ∈ keys(solution(st))
    @test :p ∈ keys(solution(st))
    @test :λ ∈ keys(solution(st))

    @test :t ∉ keys(vectorfield(st))
    @test :q ∈ keys(vectorfield(st))
    @test :p ∈ keys(vectorfield(st))
    @test :λ ∉ keys(vectorfield(st))

end
