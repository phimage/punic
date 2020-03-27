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

    struct Workspace: PunicCommand {

        @OptionGroup()
        var options: Punic.Options

        func validate() throws {
            try options.validate()
        }

        func run() {
            run(options: self.options)
        }

        func run(options: Punic.Options) {
            let rootPath = options.rootPath(extension: .xcworkspace)
            let carthagePath: Path = rootPath + sourceDir
            guard let workspacePath: Path = options.filePath(extension: .xcworkspace) else {
                options.error("Cannot find workspace in \(rootPath)") // XXX maybe create an empty one
                return
            }

            let workspaceDataPath: Path = workspacePath + "contents.xcworkspacedata"
            let workspaceDataFile = DataFile(path: workspaceDataPath)
            guard let workspaceData = try? workspaceDataFile.read() else {
                options.error("Cannot read \(workspacePath)")
                return
            }
            guard let workspaceDocument = try? AEXMLDocument(xml: workspaceData) else {
                options.error("Cannot parse \(workspacePath)")
                return
            }
            guard let workspace = workspaceDocument.firstDescendant(where: { $0.name == "Workspace"}) else {
                options.error("error: not a workspace, \(workspacePath)")
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
                    options.log("No xcodeproj for \(dependecyPath.fileName)")
                    continue
                }

                options.debug("📦 \(dependecyPath.fileName)")
                var relativePath = xcodeProjPath.rawValue.replacingOccurrences(of: rootPath.rawValue, with: "")
                if relativePath.starts(with: "/") {
                    relativePath = String(relativePath.dropFirst())
                }
                let expectedLocation = "group:\(relativePath)"

                var fileRef = group?.firstDescendant(where: {$0.name == "FileRef" && $0.attributes["location"] == expectedLocation})
                if fileRef == nil {
                    options.log("➕ \(expectedLocation)")
                    fileRef = group?.addChild(name: "FileRef", attributes: ["location": expectedLocation])
                    hasChange = true
                } else {
                    options.debug("❄️ \(expectedLocation)")
                }
            }

            if hasChange, let newData = workspaceDocument.xml.data(using: .utf8) {
                do {
                    try workspaceDataFile.write(newData)
                    options.log("💾 Workspace saved")
                } catch let ioError {
                    options.error("Cannot save workspace \(ioError)")
                }
            } else {
                options.debug("❄️ Nothing to change to workspace")
            }
        }
    }
}
