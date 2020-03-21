//
//  Punic+Workspace.swift
//  
//
//  Created by phimage on 21/03/2020.
//

import Foundation
import ArgumentParser
import FileKit
import AEXML

extension Punic {

    struct Workspace: ParsableCommand {
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

        func debug(_ message: String) {
            if debug {
                print(message)
            }
        }
        func error(_ message: String) {
            print("error: \(message)") // TODO: output in stderr
        }

        var rootPath: Path {
            let parameterPath: Path = Path(self.path)
            if parameterPath.has(extension: .xcworkspace) { // begentle if workspace passed as parameters
                return parameterPath.parent
            } else {
                return parameterPath
            }
        }
        
        var workspacePath: Path? {
            let parameterPath: Path = Path(self.path)
            if parameterPath.has(extension: .xcworkspace) { 
                return parameterPath
            } else {
                return parameterPath.findXcodeWorkspace()
            }
        }

        func run() {
            let projectPath = self.rootPath
            let carthagePath: Path = projectPath + "Carthage/Checkouts"
            guard let workspacePath: Path = self.workspacePath else {
                error("Cannot find workspace in \(projectPath)") // XXX maybe create an empty one
                return
            }

            let workspaceDataPath: Path = workspacePath + "contents.xcworkspacedata"
            let workspaceDataFile = DataFile(path: workspaceDataPath)
            guard let workspaceData = try? workspaceDataFile.read() else {
                error("Cannot read \(workspacePath)")
                return
            }
            guard let workspaceDocument = try? AEXMLDocument(xml: workspaceData) else {
                error("Cannot parse \(workspacePath)")
                return
            }
            guard let workspace = workspaceDocument.firstDescendant(where: { $0.name == "Workspace"}) else {
                error("error: not a workspace, \(workspacePath)")
                return
            }

            let GroupName = "ThirdParty" // XXX custom option
            var group = workspace.firstDescendant(where: { $0.name == "Group"})
            if group == nil {
                group = workspace.addChild(name: "Group", attributes: ["location": "container:", "name": GroupName])
            }

            var hasChange = false
            for dependecyPath in carthagePath.children() {
                guard dependecyPath.isDirectory else {
                    continue
                }
                guard let xcodeProjPath = dependecyPath.findXcodeProj() else {
                    print("No xcodeproj for \(dependecyPath.fileName)")
                    continue
                }

                debug("📦 \(dependecyPath.fileName)")
                var relativePath = xcodeProjPath.rawValue.replacingOccurrences(of: projectPath.rawValue, with: "")
                if relativePath.starts(with: "/") {
                    relativePath = String(relativePath.dropFirst())
                }
                let expectedLocation = "group:\(relativePath)"

                var fileRef = group?.firstDescendant(where: {$0.name == "FileRef" && $0.attributes["location"] == expectedLocation})
                if fileRef == nil {
                    print("➕ \(expectedLocation)")
                    fileRef = group?.addChild(name: "FileRef", attributes: ["location": expectedLocation])
                    hasChange = true
                } else {
                    debug("❄️ \(expectedLocation)")
                }
            }

            if hasChange, let newData = workspaceDocument.xml.data(using: .utf8) {
                do {
                    try workspaceDataFile.write(newData)
                    print("💾 Workspace saved")
                } catch let ioError {
                    error("Cannot save workspace \(ioError)")
                }
            } else {
                debug("❄️ Nothing to change")
            }
        }
    }
}
