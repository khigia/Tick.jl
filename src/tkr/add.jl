# TODO generic output
struct Add <: Ticker{Int}
    left_node
    right_node
end

function universe(tkr::Add)
    [
        NTicker("left", tkr.left_node, () -> Latest(0), true),
        NTicker("right", tkr.right_node, () -> Latest(0), false),
    ]
end

function tick(tkr::Add, input)::Nullable{output_type(tkr)}
    return Nullable(input["left"] + input["right"])
end
