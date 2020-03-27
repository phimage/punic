//
//  Punic.swift
//  
//
//  Created by phimage on 20/03/2020.
//

import Foundation
import ArgumentParser
import FileKit

struct Punic: ParsableCommand {
  
    static let configuration = CommandConfiguration(
        abstract: "Inject carthage xcodeproj into workspace.",
        subcommands: [All.self, Workspace.self, Project.self],
        defaultSubcommand: All.self)

    struct Options: ParsableArguments {
        @Option(default: "", help: "The project path.")
        var path: String
        
        @Option(default: false, help: "Print debug information.")
        var debug: Bool
        
        func validate() throws {
            let path = self.path
            guard Path(path).exists else {
                throw ValidationError("'<path>' \(path) doesn't not exist.")
            }
        }

        func rootPath(extension ext: Path.Extension) -> Path {
            let parameterPath: Path = Path(self.path)
            if parameterPath.has(extension: ext) { // begentle if workspace passed as parameters
                return parameterPath.parent
            } else {
                return parameterPath
            }
        }

        func filePath(extension ext: Path.Extension) -> Path? {
            let parameterPath: Path = Path(self.path)
            if parameterPath.has(extension: ext) {
                return parameterPath
            } else {
                return parameterPath.find(extension: ext)
            }
        }

        func log(_ message: String) {
            print(message)
        }
        func debug(_ message: String) {
            if self.debug {
                print(message)
            }
        }
        func error(_ message: String) {
            print("❌ error: \(message)") // TODO: output in stderr
        }
    }

}

protocol PunicCommand: ParsableCommand {
    var options: Punic.Options { get }
}

extension Punic {

    struct All: ParsableCommand {
        
        @OptionGroup()
        var options: Punic.Options
        
        func validate() throws {
            try options.validate()
        }
        func run() {
            run(options: self.options)
        }

        func run(options: Punic.Options) {
            Punic.Workspace().run(options: options)
            Punic.Project().run(options: options)
        }
    }
    
}
