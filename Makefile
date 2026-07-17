all:
	dune build theories

install:
	dune build -p rocq-trakt
	dune install rocq-trakt

test:
	dune build test

example:
	dune build example

clean:
	dune clean
	find . -name "_RocqProject" -delete
	rm -f rocq-trakt.install

.PHONY: all install test example clean
.NOTPARALLEL:
