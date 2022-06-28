
abstract type Solution{dType, tType, N} end

nsave(sol::Solution) = error("nsave() not implemented for ", typeof(sol))
ntime(sol::Solution) = error("ntime() not implemented for ", typeof(sol))
nsamples(sol::Solution) = error("nsamples() not implemented for ", typeof(sol))

counter(sol::Solution) = error("counter() not implemented for ", typeof(sol))
# offset(sol::Solution) = error("offset() not implemented for ", typeof(sol))
lastentry(sol::Solution) = error("lastentry() not implemented for ", typeof(sol))
timesteps(sol::Solution) = error("timesteps() not implemented for ", typeof(sol))
eachtimestep(sol::Solution) = error("eachtimestep() not implemented for ", typeof(sol))

eachsample(sol::Solution) = 1:nsamples(sol)

Base.write(::IOStream, sol::Solution) = error("Base.write(::IOStream, ::Solution) not implemented for ", typeof(sol))


function test_interface(sol::Solution)

    @test_nowarn nsave(sol)
    @test_nowarn ntime(sol)
    @test_nowarn nsamples(sol)

    @test_nowarn counter(sol)
    # @test_nowarn offset(sol)
    @test_nowarn lastentry(sol)
    @test_nowarn timesteps(sol)

    @test_nowarn eachtimestep(sol)
    @test_nowarn eachsample(sol)
    
end
