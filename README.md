    ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
      █████╗ ███████╗████████╗███████╗██████╗ ██╗███████╗████████╗
     ██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗██║██╔════╝╚══██╔══╝
     ███████║███████╗   ██║   █████╗  ██████╔╝██║███████╗   ██║
     ██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗██║╚════██║   ██║
     ██║  ██║███████║   ██║   ███████╗██║  ██║██║███████║   ██║
     ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝╚══════╝   ╚═╝
    ★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★
    
Asterist is an [IPFS](https://github.com/jbenet/ipfs) client for Mac. It should currently be considered pre-alpha software, or rather a proof of concept; it is nowhere near usable yet. The idea is to bundle [the reference implementation](https://github.com/jbenet/go-ipfs) of IPFS with the application so that no one has to build or download anything except Asterist itself.

Launching Asterist will also launch `ipfs` in daemon mode and then communicate with it through HTTP, which happens to be how the command line version of `ipfs` interfaces with itself when the daemon is running. All commands conveniently map to HTTP endpoints, meaning that support for any command in `ipfs` is relatively easy to add to Asterist.

**I want to stress again that this is just a proof of concept and should not be considered usable software.** Hopefully it can stabilize along with the implementation of IPFS and turn into an actual client someday.

Building
--------
1. Make sure you have [CocoaPods](http://cocoapods.org/) installed; if not, run `sudo gem install cocoapods` and `pod setup`
2. Install dependencies by running `pod install` in the Asterist root directory
3. Fetch git submodules by running `git submodule update --init`
4. Open the Xcode project through `Asterist.xcworkspace` (not the `.xcodeproj`) and run **Build**

The first build will take a while since all of [Go](http://golang.org/) is being built as well. `go-ipfs` will then be fetched through the `go get` command and the resulting `ipfs` binary copied into the application bundle. You should now be able to run Asterist. Note that Go and `go-ipfs` will only be built once, to rebuild these you must run **Clean** before **Build** in Xcode.
