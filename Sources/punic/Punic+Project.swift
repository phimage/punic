//
//   Punic+Project.swift
//  
//
//  Created by phimage on 21/03/2020.
//

import Foundation
import ArgumentParser
import FileKit
import XcodeProjKit

extension Punic {

    struct Project: ParsableCommand {
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
            if parameterPath.has(extension: .xcodeproj) { // begentle if workspace passed as parameters
                return parameterPath.parent
            } else {
                return parameterPath
            }
        }
        
        var projectPath: Path? {
            let parameterPath: Path = Path(self.path)
            if parameterPath.has(extension: .xcodeproj) {
                return parameterPath
            } else {
                return parameterPath.find(extension: .xcodeproj)
            }
        }
        
        func run() {
            let rootPath = self.rootPath
            guard let projectPath: Path = self.projectPath else {
                error("Cannot find workspace in \(rootPath)") // XXX maybe create an empty one
                return
            }

            let projectDataPath: Path = projectPath + "project.pbxproj"
            let projectDataFile = DataFile(path: projectDataPath)
            guard let projectData = try? projectDataFile.read() else {
                error("Cannot read \(projectPath)")
                return
            }

            guard let xcodeProject = try? XcodeProj(propertyListData: projectData) else {
                error("Cannot read \(projectPath)")
                return
            }

            var hasChange = false

            let project = xcodeProject.project
            for target in project.targets {
                // remove script phrase with file in "Carthage/Build", suppose copy phase
                for buildPhase in target.buildPhases {
                    if let scriptPhase = buildPhase as? PBXShellScriptBuildPhase {
                        if scriptPhase.inputPaths.contains(where: { $0.contains(buildDir)}) {
                            target.remove(object: scriptPhase, forKey: PBXTarget.PBXKeys.buildPhases)
                            scriptPhase.destroy()
                            hasChange = true
                            debug("⚙️ Build script phrase \(scriptPhase.name ?? "") removed")
                        }
                    }
                }
                // Remove from FRAMEWORK_SEARCH_PATHS
                for buildConfiguration in target.buildConfigurationList?.buildConfigurations ?? [] {
                    if var buildSettings = buildConfiguration.buildSettings {
                        if var searchPaths = buildSettings["FRAMEWORK_SEARCH_PATHS"] as? [String] {
                            if searchPaths.contains(where: { $0.hasPrefix("$(PROJECT_DIR)/\(buildDir)") }) {
                                searchPaths = searchPaths.filter({!$0.hasPrefix("$(PROJECT_DIR)/\(buildDir)")})
                                hasChange = true
                                buildSettings["FRAMEWORK_SEARCH_PATHS"]=searchPaths
                                buildConfiguration.set(value: buildSettings, into: PBXBuildStyle.PBXKeys.buildSettings)
                                debug("🔍 FRAMEWORK_SEARCH_PATHS edited for configuration \(buildConfiguration.name ?? buildConfiguration.description)")
                            }
                        }
                    }
                }
            }
            // Change frameworkd file references path
            let buildProductsDir = SourceTreeFolder.buildProductsDir.rawValue
            for fileRef in project.mainGroup?.fullFileRefs ?? []{
                if let path = fileRef.path, path.contains(buildDir) {
                    switch (fileRef.sourceTree ?? SourceTree.group) {
                    case SourceTree.relativeTo(to: SourceTreeFolder.buildProductsDir):
                        break
                    default:
                        fileRef.set(value: buildProductsDir, into: PBXReference.PBXKeys.sourceTree)
                        let name = fileRef.name ?? path
                        fileRef.set(value: name, into: PBXReference.PBXKeys.path)
                        hasChange = true
                        debug("📦 \(String(describing: name)) path changed to \(buildProductsDir)")
                    }
                }
            }

            // If has change, write to file
            if hasChange {
                do {
                    try xcodeProject.write(to: projectDataPath.url, format: .openStep)
                    print("💾 Project saved")
                } catch let ioError {
                    error("Cannot save project \(ioError)")
                }
            } else {
                debug("❄️ Nothing to change")
            }
        }
    }
}

extension PBXGroup {

    /// recursively get file refs
    var fullFileRefs: [PBXFileReference] {
        var result = self.fileRefs
        result += subGroups.flatMap { $0.fullFileRefs }
        return result
    }
}
