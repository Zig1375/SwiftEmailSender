import PackageDescription

let package = Package(
    name: "SwiftEmailSender",
    targets:      [],
    dependencies: [
        .Package(url: "https://github.com/Zig1375/EmailCurl.git", majorVersion: 1, minor: 0)
    ]
);
