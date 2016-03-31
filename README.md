# AppRouting

AppRouting is a pure Swift URL Router. It allows you to easily handle open URLs and Universal Links on iOS by writing and using route patterns, like the ones you might see in your favorite web framework.

As I personally despise heavy dependencies, minimalism is a core design principle.

### Introduction

At the core, you have a Route, which is anything that conforms to a protocol with two methods:

    func matchesOnURL(URL: NSURL) -> Bool
    func parametersForURL(URL: NSURL) -> RouteParameters

This simplfies the logic of a Route in a very nice way. It also lets you write custom route parsing and handling if you find the built-in Route pattern matcher to be inadequate.

### Features

- Easy to use
- Small compact dependency
- Good code coverage
- MIT License
- Carthage compatible

### Requirements

- Requires Xcode 7.3 and Swift 2.2
