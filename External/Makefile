build:
ifeq ($(TARGETNAME),go-ipfs)
	test -f go-ipfs/bin/ipfs || go get -u github.com/jbenet/go-ipfs/cmd/ipfs
else
ifeq ($(TARGETNAME),ipfs-webui)
	test -f ipfs-webui/node_modules/.bin/gulp || (cd ipfs-webui && npm install)
endif
endif

clean:
ifeq ($(TARGETNAME),go-ipfs)
	rm -rf go-ipfs/*
else
ifeq ($(TARGETNAME),ipfs-webui)
	rm -rf ipfs-webui/node_modules
endif
endif
