build:
ifeq ($(TARGETNAME),go)
	test -f go/bin/go || (cd go/src && ./all.bash)
else
ifeq ($(TARGETNAME),go-ipfs)
	test -f go-ipfs/bin/ipfs || go get -u github.com/jbenet/go-ipfs/cmd/ipfs
endif
endif

clean:
ifeq ($(TARGETNAME),go)
	test ! -f go/bin/go || (cd go/src && ./clean.bash)
else
ifeq ($(TARGETNAME),go-ipfs)
	rm -rf go-ipfs/*
endif
endif
