module Config

export add_config, get_config, set_config,
       get_config_dictionary

if !(@isdefined GNICONFIG)
    const global GNICONFIG = Dict{Symbol, Any}()
end

function add_config(name::Symbol, value)
    if !haskey(GNICONFIG, name)
        GNICONFIG[name] = value
    end
end

function set_config(name::Symbol, value)
    if haskey(GNICONFIG, name)
        GNICONFIG[name] = value
    else
        println("  WARNING: Unknown parameter $name.")
    end
end

function get_config(name::Symbol)
    if haskey(GNICONFIG, name)
        return GNICONFIG[name]
    else
        println("  WARNING: Unknown parameter $name.")
        return nothing
    end
end

function get_config_dictionary()
    return Dict{Symbol, Any}(GNICONFIG)
end

end
