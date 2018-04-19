struct Add{T} <: Ticker{T}
    left_node
    right_node
end

Add(left::Node{LT}, right::Node{RT}) where {LT,RT} = Add{promote_type(LT,RT)}(left, right)

function universe(tkr::Add)
    [
        NTicker("left", tkr.left_node, () -> Latest(0), true),
        NTicker("right", tkr.right_node, () -> Latest(0), false),
    ]
end

function tick(tkr::Add, input)::Nullable{output_type(tkr)}
    return Nullable(input["left"] + input["right"])
end
