
function relative_norm_error(sol, ref, p=2)
    norm(sol .- ref, p) / norm(ref, p)
end

function relative_maximum_error(sol, ref)
    maximum(abs.(sol .- ref)) ./ maximum(abs.(ref))
end
