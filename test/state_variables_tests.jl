using GeometricBase
using GeometricBase: AbstractVariable, AbstractStateVariable
using Test


function test_statevariable(Var, X, x)

    @test axes(X) == axes(x)
    @test size(X) == size(x)
    @test eachindex(X) == eachindex(x)
    @test parent(X) == x
    @test parent(zero(X)) == zero(x)
    @test zero(X) == Var(zero(x))

    @test X[1] == x[1]
    @test X[2] == x[2]
    @test X[3] == x[3]
    @test X[begin] == x[begin]
    @test X[end] == x[end]
    @test X[:] == x[:]

    @test_nowarn X[1] = 23
    @test_nowarn X[4] = 42

    if ndims(x) > 1
        @test X[1, 1] == x[1, 1]
        @test X[2, 3] == x[2, 3]
        @test X[3, 2] == x[3, 2]
        @test X[begin, 2] == x[begin, 2]
        @test X[2, end] == x[2, end]
        @test X[:, 2] == x[:, 2]
        @test X[2, :] == x[2, :]
        @test X[:, :] == x[:, :]

        @test x[1, 1] == 23

        @test_nowarn X[2, 2] = 42
        @test x[2, 2] == 42

        @test_nowarn X[:, 3] .= 1
        @test all(x[:, 3] .== 1)

        @test_nowarn X[3, :] .= 2
        @test all(x[3, :] .== 2)
    end

    @test_nowarn X[:] .= 3
    @test all(x .== 3)

    @test_nowarn copy!(X, zero(X))
    @test all(x .== 0)
    @test_nowarn add!(X, ones(eltype(x), size(x)))
    @test_nowarn add!(X, ones(eltype(x), size(x)))
    @test x == 2 .* ones(eltype(x), size(x))

    @test_nowarn copy!(X, zero(parent(X)))
    @test all(x .== 0)
end


@testset "$(rpad("Time Variable",80))" begin

    t = 2.0
    T = TimeVariable(t)
    U = TimeVariable(2)

    @test T == TimeVariable(T)

    @test parent(T) == fill(t)
    @test value(T) == t

    @test parent(zero(T)) == zero(fill(t))
    @test zero(T) == TimeVariable(zero(fill(t)))

    @test T + 2 == fill(4.0)
    @test 2 + T == fill(4.0)
    @test T - 2 == fill(0.0)
    @test 2 - T == fill(0.0)
    @test T * 3 == fill(6.0)
    @test 3 * T == fill(6.0)
    @test T / 2 == fill(1.0)
    @test 2 / T == fill(1.0)

    @test U // 4 == fill(2 // 4)
    @test 4 // U == fill(4 // 2)

end


@testset "$(rpad("State Variables",80))" begin
    for Var in (StateVariable, VectorfieldVariable, AlgebraicVariable)
        for DT in (Float32, Float64), inds in ((4,), (3, 4))
            x = rand(DT, inds...)
            X = Var(x)

            @test X == Var(X)

            test_statevariable(Var, X, x)

            @test typeof(vectorfield(X)) <: VectorfieldVariable
            @test parent(vectorfield(X)) == zero(x)
        end
    end

    for DT in (Float32, Float64), inds in ((4,), (3, 4))
        x = rand(DT, inds...)
        X = StateVariable(x)

        @test axes(X) == axes(value(X))
        @test axes(X) == axes(range(X)[begin]) == axes(range(X)[end])
        @test axes(X) == axes(periodic(X))

        @test value(X, 3) == value(X)[3]
        @test value(X, :) == value(X)[:]

        @test range(X, 3) == (range(X)[begin][3], range(X)[end][3])
        @test range(X, :) == (range(X)[begin][:], range(X)[end][:])

        @test isperiodic(X, 3) == periodic(X)[3]
        @test isperiodic(X, :) == periodic(X)[:]

    end

    X = StateVariable([0.0, 1.0, 2.0], ([-Inf, 0.0, 3.0], [+Inf, 2.0, 5.0]))
    @test verifyrange(X) == BitArray([true, true, false])
end


@testset "$(rpad("Increment",80))" begin
    for Var in (StateVariable, VectorfieldVariable, AlgebraicVariable)

        @test typeof(Var(ones(Float64, 3))) <: AbstractVariable{Float64,1}
        @test typeof(Var(ones(Int, 3))) <: AbstractVariable{Int,1}
        @test typeof(Var(ones(Float64, 3, 4))) <: AbstractStateVariable{Float64,2}
        @test typeof(Var(ones(Int, 3, 4))) <: AbstractStateVariable{Int,2}

        for DT in (Float32, Float64), inds in ((4,), (3, 4))
            x = rand(DT, inds...)
            y = rand(DT, inds...)
            X = Var(copy(x))
            Y = Increment(Var(y))

            @test Y == Increment(Y)

            test_statevariable(Var, Y, y)

            @test_nowarn add!(X, Y)
            @test all(parent(X) .== x .+ y)
        end
    end
end


@testset "$(rpad("State with Error",80))" begin
    for Var in (StateVariable, VectorfieldVariable, AlgebraicVariable)

        @test typeof(Increment(Var(ones(Float64, 3)))) <: AbstractVariable{Float64,1}
        @test typeof(Increment(Var(ones(Int, 3)))) <: AbstractVariable{Int,1}
        @test typeof(Increment(Var(ones(Float64, 3, 4)))) <: AbstractStateVariable{Float64,2}
        @test typeof(Increment(Var(ones(Int, 3, 4)))) <: AbstractStateVariable{Int,2}

        for DT in (Float32, Float64), inds in ((4,), (3, 4))
            x = rand(DT, inds...)
            y = rand(DT, inds...)
            X = StateWithError(Var(x))
            Y = Increment(Var(y))

            test_statevariable(Var, X, x)

            @test axes(X.state) == axes(X.error)
            @test eltype(X.state) == eltype(X.error)

            x = rand(DT, inds...)
            X = StateWithError(Var(copy(x)))

            @test_nowarn add!(X, Y)
            @test all(parent(X) .== x .+ y)
            @test all(X.error .!== 0)

            @test_nowarn copy!(X, y)
            @test_nowarn copy!(X, Var(y))
            @test_nowarn copy!(X, StateWithError(Var(y)))
        end
    end
end


@testset "$(rpad("State Vector",80))" begin

end


@testset "$(rpad("Time Step",80))" begin

end
