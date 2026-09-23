using Test

import GeometricBase
import GeometricBase: h5save, h5load

# The file-path methods of `h5save` and `h5load` are in the package extension on HDF5, so the two
# functions have no methods until HDF5 is loaded. No other test file loads HDF5.

@test Base.get_extension(GeometricBase, :GeometricBaseHDF5Ext) === nothing
@test isempty(methods(h5save))
@test isempty(methods(h5load))

using HDF5: HDF5, create_group

@test Base.get_extension(GeometricBase, :GeometricBaseHDF5Ext) isa Module

struct Point
    x::Float64
    y::Vector{Float64}
end

function h5save(h5::HDF5.H5DataStore, p::Point; path::AbstractString = "point")
    g = create_group(h5, path)
    g["x"] = p.x
    g["y"] = p.y
    return nothing
end

function h5load(::Type{Point}, h5::HDF5.H5DataStore; path::AbstractString = "point")
    g = h5[path]
    return Point(read(g["x"]), read(g["y"]))
end

p = Point(1.5, [1.0, 2.0, 3.0])
q = Point(-2.0, [4.0, 5.0])
fpath = joinpath(mktempdir(), "points.h5")

h5save(fpath, p)
h5save(fpath, q; mode = "r+", path = "q")

@test h5load(Point, fpath).x == p.x
@test h5load(Point, fpath).y == p.y
@test h5load(Point, fpath; path = "q").x == q.x
@test h5load(Point, fpath; path = "q").y == q.y
