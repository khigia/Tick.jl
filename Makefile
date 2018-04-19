# Or from julia: Pkg.test("Tick")
.PHONY: test
test:
	julia -L src/Tick.jl test/runtests.jl
