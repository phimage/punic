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

            var created = false
            if options.filePath(extension: .xcworkspace) == nil,
               let projectPath: Path = options.filePath(extension: .xcodeproj) {
                // if no workspace but a project we could create it
                let xmlString = """
                <?xml version="1.0" encoding="UTF-8"?>
                <Workspace
                   version = "1.0">
                   <FileRef
                      location = "container:\(projectPath.fileName)">
                   </FileRef>
                </Workspace>
                """
                let workspacePath: Path = projectPath.of(extension: .xcworkspace)
                if let data = xmlString.data(using: .utf8) {
                    do {
                        try workspacePath.createDirectory()
                        try DataFile(path: workspacePath + "contents.xcworkspacedata").write(data)
                        created = true
                    } catch let ioError {
                        options.error("Cannot save new create workspace \(ioError)")
                    }
                }
            }

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
            
            guard let groupElement = group else {
                options.error("Cannot create Group XML element")
                return
            }

            var hasChange = false
            for dependencyPath in carthagePath.children() {
                hasChange = addProject(from: dependencyPath, with: options, into: groupElement, rootPath: rootPath) || hasChange
            }
            if !options.devPath.isEmpty {
                for dependencyPath in  Path(options.devPath).children() {
                    hasChange = addProject(from: dependencyPath, with: options, into: groupElement, rootPath: rootPath) || hasChange
                }
            }

            if hasChange, let newData = workspaceDocument.xml.data(using: .utf8) {
                do {
                    try workspaceDataFile.write(newData)
                    options.log("💾 Workspace \(created ? "created": "saved")")
                } catch let ioError {
                    options.error("Cannot save workspace \(ioError)")
                }
            } else {
                options.debug("❄️ Nothing to change to workspace")
            }
        }

        func addProject(from path: Path, with options: Punic.Options, into group: AEXMLElement, rootPath: Path) -> Bool {
            guard path.isDirectory else {
                return false
            }
            guard let xcodeProjPath = path.findXcodeProj() else {
                options.log("No xcodeproj for \(path.fileName)")
               return false
            }
            options.debug("📦 \(path.fileName)")
            var relativePath = xcodeProjPath.rawValue.replacingOccurrences(of: rootPath.rawValue, with: "")
            if relativePath.starts(with: "/") {
                relativePath = String(relativePath.dropFirst())
            }
            let expectedLocation = "group:\(relativePath)"

            var fileRef = group.firstDescendant(where: {$0.name == "FileRef" && $0.attributes["location"] == expectedLocation})
            if fileRef == nil {
                options.log("➕ \(expectedLocation)")
                fileRef = group.addChild(name: "FileRef", attributes: ["location": expectedLocation])
                return true
            } else {
                options.debug("❄️ \(expectedLocation)")
            }
            return false
        }
    }

}
