# jolk

jolk is a tool that analyzes executables installed in macOS using various analyzer passes.

## Analyzer Passes

- strings: extracts strings inside the executable
- dynamic linker: identifies dynamically linked libraries and executables
- lipo: determines what architectures an executable supports
- launchd: discovers launchd plists that are relevant to the executable

## Usage

1. Install [Homebrew](https://brew.sh)
2. Install jolk with Homebrew: `brew install kendfinger/tools/jolk`

```text
$ jolk
analyze /usr/libexec/remoted
complete /usr/libexec/remoted 252.68ms
... more executables on the system ...
```

jolk produces a report in the file `executables.json` which will provide details like this:

```json
{
  "/usr/libexec/remoted" : {
    "dynamic-linker.linked-files" : [
      "/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation",
      "/System/Library/PrivateFrameworks/RemoteServiceDiscovery.framework/Versions/A/RemoteServiceDiscovery",
      "/System/Library/PrivateFrameworks/RemoteXPC.framework/Versions/A/RemoteXPC",
      "/usr/lib/libnetwork.dylib",
      "/System/Library/PrivateFrameworks/BridgeXPC.framework/Versions/A/BridgeXPC",
      "/System/Library/PrivateFrameworks/EmbeddedOSSupportHost.framework/Versions/A/EmbeddedOSSupportHost",
      "/System/Library/PrivateFrameworks/MultiverseSupport.framework/Versions/A/MultiverseSupport",
      "/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit",
      "/usr/lib/libMobileGestalt.dylib",
      "/System/Library/PrivateFrameworks/WatchdogClient.framework/Versions/A/WatchdogClient",
      "/usr/lib/libobjc.A.dylib",
      "/usr/lib/libSystem.B.dylib",
      "/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation"
    ],
    "dynamic-linker.linked-frameworks" : [
      "/System/Library/Frameworks/Foundation.framework",
      "/System/Library/PrivateFrameworks/RemoteServiceDiscovery.framework",
      "/System/Library/PrivateFrameworks/RemoteXPC.framework",
      "/System/Library/PrivateFrameworks/BridgeXPC.framework",
      "/System/Library/PrivateFrameworks/EmbeddedOSSupportHost.framework",
      "/System/Library/PrivateFrameworks/MultiverseSupport.framework",
      "/System/Library/Frameworks/IOKit.framework",
      "/System/Library/PrivateFrameworks/WatchdogClient.framework",
      "/System/Library/Frameworks/CoreFoundation.framework"
    ],
    "launchd.mach.services" : [
      "com.apple.remoted.watchdog",
      "com.apple.remoted.coredevice",
      "com.apple.remoted.control",
      "com.apple.remoted"
    ],
    "launchd.plists" : [
      "/System/Library/LaunchDaemons/com.apple.remoted.plist"
    ],
    "lipo.architectures" : [
      "x86_64",
      "arm64e"
    ],
    "man-page.exists" : false,
    "strings.likely.has-help-flag" : false,
    "strings.likely.has-usage" : false
  }
}
```
