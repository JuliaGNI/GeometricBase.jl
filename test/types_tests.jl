using Base: Callable, TwicePrecision
using GeometricBase
using Test


@testset "$(rpad("Null Types",80))" begin

    invs = NullInvariants()
    @test_throws ErrorException invs[1]
    @test_throws ErrorException for i in invs end

    params = NullParameters()
    @test_throws ErrorException params[1]
    @test_throws ErrorException for p in params end

    period = NullPeriodicity()
    @test_throws ErrorException period[1]
    @test_throws ErrorException for p in period end

end


@testset "$(rpad("Optional Types",80))" begin

    @test Nothing <: OptionalArray
    @test Nothing <: OptionalArray{AbstractArray}
    @test Nothing <: OptionalArray{Matrix}

    @test Matrix <: OptionalArray
    @test Matrix <: OptionalArray{AbstractArray}
    @test Matrix <: OptionalArray{Matrix}


    @test Nothing         <: OptionalAbstractArray
    @test Matrix          <: OptionalAbstractArray
    @test Matrix{Int}     <: OptionalAbstractArray
    @test AbstractMatrix  <: OptionalAbstractArray

    @test Nothing         <: OptionalCallable
    @test Callable        <: OptionalCallable

    @test Nothing         <: OptionalFunction
    @test Function        <: OptionalFunction

    @test Nothing         <: OptionalNamedTuple
    @test NamedTuple      <: OptionalNamedTuple

    @test Nothing         <: OptionalTuple
    @test Tuple           <: OptionalTuple

    @test NullInvariants  <: OptionalInvariants
    @test NamedTuple      <: OptionalInvariants

    @test NullParameters  <: OptionalParameters
    @test NamedTuple      <: OptionalParameters

    @test NullPeriodicity                <: OptionalPeriodicity
    @test typeof((rand(3,3), rand(3,3))) <: OptionalPeriodicity
    @test !(typeof((rand(2), rand(3,3))) <: OptionalPeriodicity)

end


@testset "$(rpad("Data Types",80))" begin

    @test Number <: AbstractData
    @test Int    <: AbstractData
    @test Matrix{Number} <: AbstractData
    @test Matrix{Int}    <: AbstractData
    @test AbstractMatrix{Number} <: AbstractData
    @test AbstractMatrix{Int}    <: AbstractData

end
