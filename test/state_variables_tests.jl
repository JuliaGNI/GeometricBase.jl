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

    @test X[1,1] == x[1,1]
    @test X[2,3] == x[2,3]
    @test X[3,2] == x[3,2]
    @test X[begin,2] == x[begin,2]
    @test X[2,end] == x[2,end]
    @test X[:,2] == x[:,2]
    @test X[2,:] == x[2,:]
    @test X[:,:] == x[:,:]

    @test_nowarn X[1] = 23
    @test x[1,1] == 23

    @test_nowarn X[2,2] = 42
    @test x[2,2] == 42

    @test_nowarn X[:,3] .= 1
    @test all(x[:,3] .== 1)

    @test_nowarn X[3,:] .= 2
    @test all(x[3,:] .== 2)

    @test_nowarn X[:] .= 3
    @test all(x .== 3)

    @test_nowarn copy!(X, zero(X))
    @test all(x .== 0)
    @test_nowarn add!(X, ones(size(x)))
    @test_nowarn add!(X, ones(size(x)))
    @test x == 2 .* ones(size(x))

    @test_nowarn copy!(X, zero(parent(X)))
    @test all(x .== 0)
end


@testset "$(rpad("Time Variable",80))" begin

    t = 2.
    T = TimeVariable(t)
    U = TimeVariable(2)

    @test T == TimeVariable(T)

    @test parent(T) == fill(t)
    @test value(T) == t

    @test parent(zero(T)) == zero(fill(t))
    @test zero(T) == TimeVariable(zero(fill(t)))

    @test T + 2 === 4.
    @test 2 + T === 4.
    @test T - 2 === 0.
    @test 2 - T === 0.
    @test T * 3 === 6.
    @test 3 * T === 6.
    @test T / 2 === 1.
    @test 2 / T === 1.

    @test U // 4 === 2 // 4
    @test 4 // U === 4 // 2

end


@testset "$(rpad("State Variables",80))" begin
    for Var in (StateVariable, VectorfieldVariable, AlgebraicVariable)

        x = rand(3,4)
        X = Var(x)

        @test X == Var(X)

        test_statevariable(Var, X, x)

        @test typeof(vectorfield(X)) <: VectorfieldVariable
        @test parent(vectorfield(X)) == zero(x)
    end
end


@testset "$(rpad("Increment",80))" begin
    for Var in (StateVariable, VectorfieldVariable, AlgebraicVariable)

        @test typeof(Var(ones(Float64, 3))) <: AbstractVariable{Float64,1}
        @test typeof(Var(ones(Int, 3))) <: AbstractVariable{Int,1}
        @test typeof(Var(ones(Float64, 3, 4))) <: AbstractStateVariable{Float64,2}
        @test typeof(Var(ones(Int, 3, 4))) <: AbstractStateVariable{Int,2}
    
        x = rand(3,4)
        y = rand(3,4)
        X = Var(copy(x))
        Y = Increment(Var(y))

        @test Y == Increment(Y)

        test_statevariable(Var, Y, y)

        @test_nowarn add!(X, Y)
        @test all(parent(X) .== x .+ y)

    end
end


@testset "$(rpad("State with Error",80))" begin
    for Var in (StateVariable, VectorfieldVariable, AlgebraicVariable)

        @test typeof(Increment(Var(ones(Float64, 3)))) <: AbstractVariable{Float64,1}
        @test typeof(Increment(Var(ones(Int, 3)))) <: AbstractVariable{Int,1}
        @test typeof(Increment(Var(ones(Float64, 3, 4)))) <: AbstractStateVariable{Float64,2}
        @test typeof(Increment(Var(ones(Int, 3, 4)))) <: AbstractStateVariable{Int,2}
    
        x = rand(3,4)
        y = rand(3,4)
        X = StateWithError(Var(x))
        Y = Increment(Var(y))

        test_statevariable(Var, X, x)

        @test axes(X.state) == axes(X.error)
        @test eltype(X.state) == eltype(X.error)

        x = rand(3,4)
        X = StateWithError(Var(copy(x)))
        
        @test_nowarn add!(X, Y)
        @test all(parent(X) .== x .+ y)
        @test all(X.error .!== 0)

        @test_nowarn copy!(X, y)
        @test_nowarn copy!(X, Var(y))
        @test_nowarn copy!(X, StateWithError(Var(y)))
    end
end


@testset "$(rpad("State Vector",80))" begin

end


@testset "$(rpad("Time Step",80))" begin

end
