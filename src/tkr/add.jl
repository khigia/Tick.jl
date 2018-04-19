struct Add{T} <: Ticker{T}
    left_node
    right_node
end

Add(left::Node{LT}, right::Node{RT}) where {LT,RT} = Add{promote_type(LT,RT)}(left, right)

function universe(tkr::Add)
    [
        ("left", tkr.left_node),
        ("right", tkr.right_node),
    ]
end

function tick(tkr::Add, input)::Nullable{output_type(tkr)}
    return Nullable(input["left"] + input["right"])
end
