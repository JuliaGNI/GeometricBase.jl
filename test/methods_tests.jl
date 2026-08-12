using Test

import GeometricBase
import GeometricBase: initialtime, finaltime, timespan

timespan(x::StepRangeLen) = x

@test initialtime(0:0.1:1) == 0.0
@test finaltime(0:0.1:1) == 1.0


# The accessors below are declared here so that the packages of the ecosystem extend one
# generic function each instead of defining their own. They carry no methods of their own:
# a method here would apply to every implementation and there is nothing generic to say.

for f in (:basis, :degree, :nnodes, :nodes, :weights)
    @eval @test isa(GeometricBase.$f, Function)
    @eval @test length(methods(GeometricBase.$f)) == 0
end
