
function relative_l2_error(sol, ref)
    norm(sol.d[end,begin] .- ref) / norm(ref)
end

function relative_maximum_error(sol, ref)
    maximum(abs.((sol.d[end,begin] .- ref) ./ ref))
end
