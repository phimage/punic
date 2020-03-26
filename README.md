# punic

![Swift](https://github.com/phimage/punic/workflows/Swift/badge.svg)

Add dependencies sources project introduced by [Carthage](https://github.com/Carthage/Carthage) into your Xcode workspace.

Remove copy framework build phrase from Xcode project.

## Why?

To remove the usage of binary frameworks introduced by [Carthage](https://github.com/Carthage/Carthage) and to go back to developpement with sources.

## Usage

### For current path

```bash
punic
```

### or for specific path

```bash
punic --path <your project root path>
```

## Install

### From source

```bash
swift build
```

## Dependencies

- [ArgumentParser](https://swift.org/blog/argument-parser/) for parsing command line arguments.
- [FileKit](https://github.com/nvzqz/FileKit) for file browsing.
- [AEXML](https://github.com/tadija/AEXML) for XML parsing and modifying.
- [XcodeProjKit](https://github.com/phimage/XcodeProjKit) for Xcode project parsing.

## Why this project is named `punic`?

> The ancient city was destroyed by the Roman Republic in the Third Punic War in 146 BC and then re-developed as Roman Carthage

https://en.wikipedia.org/wiki/Carthage

[![Punic Wars](https://pbs.twimg.com/media/DpPTMsgWwAAnXq1?format=jpg&name=thumb)](https://twitter.com/sara_boutall/status/1050415438923005958)
