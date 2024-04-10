using Base: TwicePrecision
using GeometricBase.Utils
using GeometricBase.Utils: _big
using Test

@testset "$(rpad("Macros",80))" begin
    
    @test _big(1)    == BigFloat(1)
    @test _big(1//1) == BigFloat(1)
    @test _big(1.0)  == BigFloat(1)
    @test _big("1")  == BigFloat(1)
    @test _big(:(1)) == BigFloat(1)

    x = @big [1  2.0  1//3]
    y = big.([1  2.0  1//3])
    z = [big(1)  big(2.0)  big(1//3)]

    @test x != y
    @test x == z

end


@testset "$(rpad("Norms",80))" begin

    x = [3.0, 4.0]

    @test L2norm(x) == 25.
    @test l2norm(x) == 5.

end


@testset "$(rpad("Summation",80))" begin
    
    n = 100000
    d = 5

    x = rand()
    y = rand(n)
    e = zero(x)

    x_cs = x
    x_tp = TwicePrecision(x)
    x_bg = big(x)
    x_ft = x

    for t in y
        x_cs, e = compensated_summation(x_cs, t, e)
        x_tp += t
        x_bg += t
        x_ft += t
    end

    @test x_cs == typeof(x_cs)(x_tp)
    @test x_cs == typeof(x_cs)(x_bg)
    @test x_cs ≈ x_ft rtol=1E-12


    x = rand(d)
    y = [rand(d) for _ in 1:n]
    e = zero(x)

    x_cs = copy(x)
    x_tp = TwicePrecision.(x)
    x_bg = big.(x)
    x_ft = copy(x)

    x_cs2 = copy(x)
    e_cs2 = zero(x)

    for t in y
        x_cs, e = compensated_summation!(x_cs, t, e)
        x_cs2, e_cs2 = compensated_summation(x_cs2, t, e_cs2)
        x_tp .+= t
        x_bg .+= t
        x_ft .+= t
    end

    @test x_cs == x_cs2
    @test x_cs == typeof(x_cs)(x_tp)
    @test x_cs == typeof(x_cs)(x_bg)
    @test x_cs ≈ x_ft rtol=1E-12

end
