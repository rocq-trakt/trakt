all:
	dune build theories/Trakt.vo

install:
	dune install rocq-trakt

test:
	cd test && dune build

example:
	cd example && dune build

clean:
	dune clean
	rm -f rocq-trakt.install {theories,example,test}/_RocqProject

.PHONY: all install test example clean
.NOTPARALLEL:
