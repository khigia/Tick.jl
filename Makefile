.PHONY: test
test:
	julia --color=yes -e 'Pkg.test("Tick")'

.PHONY: doc
doc:
	cd docs && julia make.jl
	# in atom, ctrl-shift-m to see preview
