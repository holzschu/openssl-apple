import Foundation
import FMake

OutputLevel.default = .error

try sh("./build-libssl.sh --disable-bitcode --verbose-on-error --targets=\"ios64-cross-arm64 ios-sim-cross-arm64 ios-sim-cross-x86_64\"")

try sh("./create-openssl-framework.sh static")

try cd("xcframeworks/static") {
    try sh("zip --symlinks -r ../../openssl-static.xcframework.zip openssl.xcframework")
}

try sh("zip --symlinks -r openssl-libs.zip libs")

try sh("./create-openssl-framework.sh dynamic")

try cd("xcframeworks/dynamic") {
    try sh("zip --symlinks -r ../../openssl-dynamic.xcframework.zip openssl.xcframework")
}

try cd("frameworks/static") {
    try sh("zip --symlinks -r ../../openssl-static.frameworks.zip .")
}

try cd("frameworks/dynamic") {
    try sh("zip --symlinks -r ../../openssl-dynamic.frameworks.zip .")
}

let releaseMD =
  """

    | File                            | SHA 256                                             |
    | ------------------------------- |:---------------------------------------------------:|
    | openssl-static.xcframework.zip  | \(try sha(path: "openssl-static.xcframework.zip"))  |
    | openssl-dynamic.xcframework.zip | \(try sha(path: "openssl-dynamic.xcframework.zip")) |
    | openssl-static.frameworks.zip   | \(try sha(path: "openssl-static.frameworks.zip"))   |
    | openssl-dynamic.frameworks.zip  | \(try sha(path: "openssl-dynamic.frameworks.zip"))  |

  """

try write(content: releaseMD, atPath: "release.md")
