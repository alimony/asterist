build:
ifeq ($(TARGETNAME),go)
	test -f go/bin/go || (cd go/src && ./all.bash)
else
ifeq ($(TARGETNAME),go-ipfs)
	test -f go-ipfs/bin/ipfs || go get -u github.com/jbenet/go-ipfs/cmd/ipfs
else
ifeq ($(TARGETNAME),node)
	test -f node/node || (cd node && ./configure && make)
else
ifeq ($(TARGETNAME),ipfs-webui)
	test -f ipfs-webui/node_modules/.bin/gulp || (cd ipfs-webui && npm install)
endif
endif
endif
endif

clean:
ifeq ($(TARGETNAME),go)
	test ! -f go/bin/go || (cd go/src && ./clean.bash)
else
ifeq ($(TARGETNAME),go-ipfs)
	rm -rf go-ipfs/*
else
ifeq ($(TARGETNAME),node)
	cd node && make clean
else
ifeq ($(TARGETNAME),ipfs-webui)
	rm -rf ipfs-webui/node_modules
endif
endif
endif
endif
