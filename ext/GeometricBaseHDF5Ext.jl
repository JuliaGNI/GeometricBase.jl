module GeometricBaseHDF5Ext

using HDF5: h5open

import GeometricBase: h5save, h5load

function h5save(fpath::AbstractString, x, args...; mode = "w", kwargs...)
    h5open(h5 -> h5save(h5, x, args...; kwargs...), fpath, mode)
end

function h5load(T::Type, fpath::AbstractString, args...; kwargs...)
    h5open(h5 -> h5load(T, h5, args...; kwargs...), fpath, "r")
end

end
