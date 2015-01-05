build:
ifeq ($(TARGETNAME),go)
	test -f go/bin/go || (cd go/src && /bin/bash all.bash)
else
ifeq ($(TARGETNAME),go-ipfs)
	test -f go-ipfs/bin/ipfs || go get -u github.com/jbenet/go-ipfs/cmd/ipfs
else
ifeq ($(TARGETNAME),ipfs-webui)
	test -f ipfs-webui/node_modules/.bin/gulp || (cd ipfs-webui && npm install)
endif
endif
endif

clean:
ifeq ($(TARGETNAME),go)
	cd go/src && /bin/bash clean.bash
else
ifeq ($(TARGETNAME),go-ipfs)
	rm -rf go-ipfs/*
else
ifeq ($(TARGETNAME),ipfs-webui)
	rm -rf ipfs-webui/node_modules
endif
endif
endif
