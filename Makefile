.PHONY: test
test:
	julia --color=yes -e 'Pkg.test("Tick")'
