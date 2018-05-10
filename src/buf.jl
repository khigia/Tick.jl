# TODO Fisrt, Collect, Reducer(fn) ...
# TODO maybe no need for add/generate/reset, reduce/init is better


struct Latest
    v
    Latest(x) = new(Ref(x))
end

function add(aggr::Latest, v)  # push!
    aggr.v[] = v
    true  # trigger
end

generate(aggr::Latest) = aggr.v[]

reset(aggr::Latest) = nothing  # always keep latest
