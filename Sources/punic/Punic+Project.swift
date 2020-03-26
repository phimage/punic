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
            // remove script phrase with file in "Carthage/Build", suppose copy phase
            for target in project.targets {
                for buildPhase in target.buildPhases {
                    if let scriptPhase = buildPhase as? PBXShellScriptBuildPhase {
                        if scriptPhase.inputPaths.contains(where: { $0.contains("Carthage/Build")}) {
                            target.remove(object: scriptPhase, forKey: "buildPhases")
                            scriptPhase.destroy()
                            hasChange = true
                        }
                    }
                }
                /*for buildConfiguration in target.buildConfigurationList?.buildConfigurations ?? [] {
                    if var buildSettings = buildConfiguration.buildSettings {
                       "FRAMEWORK_SEARCH_PATHS", remove "$(PROJECT_DIR)/Carthage/Build/iOS",
                    }
                }*/
            }

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
