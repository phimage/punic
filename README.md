# punic

![Swift](https://github.com/phimage/punic/workflows/Swift/badge.svg)

- Add dependencies sources project introduced by [Carthage](https://github.com/Carthage/Carthage) into your Xcode workspace.
- Remove copy framework build phrase from Xcode project and embed frameworks instead.

## Why?

To remove the usage of binary frameworks introduced by [Carthage](https://github.com/Carthage/Carthage) and to go back to developpement with sources.

## Usage

### For current path

#### Edit workspace

```bash
punic workspace
```

#### Edit project

```bash
punic project
```

#### Edit all (workspace+project)

```bash
punic
```

### or for specific path

```bash
punic --path <your project root path>
```
> work also with subcommands project or workspace

## Install

### From source

```bash
swift build
```
> result in .build/debug/punic, could be copyed to /usr/local/bin/

## Output sample

```
➕ group:Carthage/Checkouts/Alamofire/Alamofire.xcodeproj
➕ group:Carthage/Checkouts/Moya/Moya.xcodeproj
➕ group:Carthage/Checkouts/Prephirences/Prephirences.xcodeproj
💾 Workspace saved
⚙️ Build script phrase Copy Frameworks removed
🔍 FRAMEWORK_SEARCH_PATHS edited for configuration Debug
🔍 FRAMEWORK_SEARCH_PATHS edited for configuration Release
📦 Alamofire.framework path changed to BUILT_PRODUCTS_DIR
📦 Moya.framework path changed to BUILT_PRODUCTS_DIR
📦 Prephirences.framework path changed to BUILT_PRODUCTS_DIR
🚀 Embed framework Alamofire.framework with ref 005DF40092F000CBE4009994
🚀 Embed framework Moya.framework with ref 00E1C5002541000E0000FF11
🚀 Embed framework Prephirences.framework with ref 0005CC00CB4000780B00588C
💾 Project saved
```

## Dependencies

- [ArgumentParser](https://swift.org/blog/argument-parser/) for parsing command line arguments.
- [FileKit](https://github.com/nvzqz/FileKit) for file browsing.
- [AEXML](https://github.com/tadija/AEXML) for XML parsing and modifying.
- [XcodeProjKit](https://github.com/phimage/XcodeProjKit) for Xcode project parsing and modifying.

## Why this project is named `punic`?

> The ancient city was destroyed by the Roman Republic in the Third Punic War in 146 BC and then re-developed as Roman Carthage
[@Wikipedia](https://en.wikipedia.org/wiki/Carthage)

[![Punic Wars](https://pbs.twimg.com/media/DpPTMsgWwAAnXq1?format=jpg&name=thumb)](https://twitter.com/sara_boutall/status/1050415438923005958)
