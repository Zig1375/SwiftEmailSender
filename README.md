## Install

Supported only Swift 3.0 (snapshot from May 03, 2016) `swift-DEVELOPMENT-SNAPSHOT-2016-05-03-a`

In `Package.swift`:
```swift
dependencies: [
    // Other your packages
    .Package(url: "https://github.com/Zig1375/SwiftEmailSender.git", majorVersion: 0, minor: 0)
]
```


## Installation (Linux, Apt-based)

1. Install the following system linux libraries:

```sh
sudo apt-get install autoconf libtool libkqueue-dev libkqueue0 libdispatch-dev libdispatch0 libhttp-parser-dev libcurl4-openssl-dev libhiredis-dev libbsd-dev
```

2. Install libdispatch:
```sh
git clone -b experimental/foundation https://github.com/apple/swift-corelibs-libdispatch.git
cd swift-corelibs-libdispatch
git submodule init
git submodule update
sh ./autogen.sh
./configure --with-swift-toolchain=<path-to-swift>/usr --prefix=<path-to-swift>/usr
make && sudo make install
```



## Introduction

This is a Swift module for send email.

## Here is an example on how to use it:

```swift
let queue = EmailQueue();
queue.addHost(
    alias : "test",  
    host : "smtp.gmail.com",
    port : 587,
    username : "username@gmail.com",
    password: "password",
    from : "username@gmail.com"
);

var email = Email(subject: "test subject", to : "user2@gmail.com");
email.text = "test text \n TEXT";
email.html = "test html <br/><b> TEXT </b>";

queue.addEmail(alias : "test", email : email);
sleep(60)
```
