# jolk

jolk is a tool that analyzes executables installed in macOS using various analyzer passes.

## Analyzer Passes

- strings: extracts strings inside the executable
- dynamic linker: identifies dynamically linked libraries and executables
- lipo: determines what architectures an executable supports
- launchd: discovers launchd plists that are relevant to the executable

## Usage

```text
$ jolk
analyze /usr/libexec/remotectl
complete /usr/libexec/remotectl 252.68ms
... more executables on the system ..
```

jolk produces a report in the file `executables.json` which will provide details like this:

```json
{
  "/usr/libexec/remotectl" : {
    "dynamic-linker.linked-files" : [
      "/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation",
      "/System/Library/PrivateFrameworks/BridgeXPC.framework/Versions/A/BridgeXPC",
      "/System/Library/PrivateFrameworks/RemoteXPC.framework/Versions/A/RemoteXPC",
      "/System/Library/PrivateFrameworks/RemoteServiceDiscovery.framework/Versions/A/RemoteServiceDiscovery",
      "/usr/lib/libobjc.A.dylib",
      "/usr/lib/libSystem.B.dylib",
      "/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation"
    ],
    "dynamic-linker.linked-frameworks" : [
      "/System/Library/Frameworks/Foundation.framework",
      "/System/Library/PrivateFrameworks/BridgeXPC.framework",
      "/System/Library/PrivateFrameworks/RemoteXPC.framework",
      "/System/Library/PrivateFrameworks/RemoteServiceDiscovery.framework",
      "/System/Library/Frameworks/CoreFoundation.framework"
    ],
    "lipo.architectures" : [
      "x86_64",
      "arm64e"
    ],
    "man-page.exists" : false,
    "strings.likely.has-help-flag" : false,
    "strings.likely.has-usage" : true
  }
}
```
