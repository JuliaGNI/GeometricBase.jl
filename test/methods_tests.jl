using Test

import GeometricBase: tbegin, tend, tspan

tspan(x::StepRangeLen) = x

@test tbegin(0:0.1:1) == 0.0
@test tend(0:0.1:1) == 1.0
