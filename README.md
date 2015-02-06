# Asterist

This is currently just a proof of concept on bundling everything necessary to run [IPFS](https://github.com/jbenet/ipfs) on your Mac without having to install anything else. These are the bundled components:

[go](https://github.com/golang/go) – included as a submodule and used to build/install:

[go-ipfs](https://github.com/jbenet/go-ipfs) – the reference implementation of IPFS, written in Go

Building the project will fetch and build all of these, as well as copy them to the built application bundle so it will run independently on any computer. The Cocoa application itself is a simple wrapper that launches all necessary processes and then displays the locally running web interface in an embedded web view.

**I want to point out again that this is just a proof of concept and should not be considered usable software.** Hopefully it can stabilize along with the implementation of IPFS and turn into an actual client someday. For example, the entire web interface should probably go away, letting the Cocoa application communicate directly with go-ipfs instead.
