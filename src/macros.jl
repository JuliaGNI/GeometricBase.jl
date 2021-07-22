
macro define(name, definition)
    quote
        macro $(esc(name))()
            esc($(Expr(:quote, definition)))
        end
    end
end


_big(x) = x
_big(x::Number) = big(x)
_big(x::String) = parse(BigFloat, x)

function _big(x::Expr)
    y = x
    y.args .= _big.(y.args)
    return  y
end

macro big(x)
    return esc(_big(x))
end
