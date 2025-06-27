using Test

import GeometricBase: initialtime, finaltime, timespan

timespan(x::StepRangeLen) = x

@test initialtime(0:0.1:1) == 0.0
@test finaltime(0:0.1:1) == 1.0
