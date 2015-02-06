    ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
      █████╗ ███████╗████████╗███████╗██████╗ ██╗███████╗████████╗
     ██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗██║██╔════╝╚══██╔══╝
     ███████║███████╗   ██║   █████╗  ██████╔╝██║███████╗   ██║
     ██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗██║╚════██║   ██║
     ██║  ██║███████║   ██║   ███████╗██║  ██║██║███████║   ██║
     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝   ╚═╝
    ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★

Asterist is an [IPFS](https://github.com/jbenet/ipfs) client for Mac. It should currently be considered pre-alpha software, or rather a proof of concept; it is nowhere near usable yet.

The idea is to bundle [the reference implementation](https://github.com/jbenet/go-ipfs) of IPFS with the application so that no one has to build or download anything except Asterist itself.

Building Asterist involves fetching [go](https://github.com/golang/go) as a submodule and then installing [go-ipfs](https://github.com/jbenet/go-ipfs) through the [recommended method](https://github.com/jbenet/go-ipfs#install):

    go get -u github.com/jbenet/go-ipfs/cmd/ipfs

The resulting `ipfs` binary is copied to the application bundle, and we're good to go.

Launching Asterist will also launch `ipfs` in daemon mode and then communicate with it through HTTP, which happens to be how the command line version of `ipfs` interfaces with itself when the daemon is running. All commands conveniently map to HTTP endpoints, meaning that support for any command in `ipfs` is relatively easy to add to Asterist.

**I want to stress again that this is just a proof of concept and should not be considered usable software.** Hopefully it can stabilize along with the implementation of IPFS and turn into an actual client someday.
