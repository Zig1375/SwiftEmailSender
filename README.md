## Install

Supported only Swift 3.0 (snapshot from June 06, 2016) `swift-DEVELOPMENT-SNAPSHOT-2016-06-06-a`

In `Package.swift`:
```swift
dependencies: [
    // Other your packages
    .Package(url: "https://github.com/Zig1375/SwiftEmailSender.git", majorVersion: 0, minor: 0)
]
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
