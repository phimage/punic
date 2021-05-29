//
//  Punic+X.swift
//  
//
//  Created by emarchand on 28/05/2021.
//

import Foundation

import ArgumentParser
import FileKit
import XcodeProjKit

extension Punic {

    struct X: PunicCommand {

        @OptionGroup()
        var options: Punic.Options

        func validate() throws {
            try options.validate()
        }

        func run() {
            run(options: self.options)
        }

        func run(options: Punic.Options) {
          /*  let rootPath = options.rootPath(extension: .xcodeproj)
             guard let projectPath: Path = options.filePath(extension: .xcodeproj) else {
                options.error("Cannot find project in \(rootPath)") // XXX maybe create an empty one
                return
            }

            let projectDataPath: Path = projectPath + "project.pbxproj"
            let projectDataFile = DataFile(path: projectDataPath)
            guard let projectData = try? projectDataFile.read() else {
                options.error("Cannot read \(projectPath)")
                return
            }

            guard let xcodeProject = try? XcodeProj(propertyListData: projectData) else {
                options.error("Cannot read \(projectPath)")
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
                            scriptPhase.unattach()
                            hasChange = true
                            options.log("⚙️ Build script phrase \(scriptPhase.name ?? "") removed")
                        }
                    }
                }
                // Replace from FRAMEWORK_SEARCH_PATHS
                for buildConfiguration in target.buildConfigurationList?.buildConfigurations ?? [] {
                    if var buildSettings = buildConfiguration.buildSettings {
                        if var searchPaths = buildSettings["FRAMEWORK_SEARCH_PATHS"] as? [String] {
                            if searchPaths.contains(where: { $0.hasPrefix("$(PROJECT_DIR)/\(buildDir)/") }) { // ../iOS, ..
                                searchPaths = searchPaths.filter({!$0.hasPrefix("$(PROJECT_DIR)/\(buildDir)")})
                                hasChange = true
                                buildSettings["FRAMEWORK_SEARCH_PATHS"]=searchPaths+["$(PROJECT_DIR)/\(buildDir)"]/*xcframework*/
                                buildConfiguration.set(value: buildSettings, into: PBXBuildStyle.PBXKeys.buildSettings)
                                options.log("🔍 FRAMEWORK_SEARCH_PATHS edited for configuration \(buildConfiguration.name ?? buildConfiguration.description)")
                            }
                        }
                    }
                }
            }
            // Change frameworkd file references path
            let buildProductsDir = SourceTreeFolder.buildProductsDir.rawValue
            let fullFileRefs = project.mainGroup?.fullFileRefs ?? []
            for fileRef in fullFileRefs {
                if let path = fileRef.path, path.contains(buildDir) {

                    switch (fileRef.sourceTree ?? SourceTree.group) {
                    case SourceTree.relativeTo(to: SourceTreeFolder.buildProductsDir):
                        break
                    default:
                        fileRef.set(value: buildProductsDir, into: PBXReference.PBXKeys.sourceTree)
                        let name = fileRef.name ?? path
                        fileRef.set(value: name, into: PBXReference.PBXKeys.path)
                        hasChange = true
                        options.log("📦 \(String(describing: name)) path changed to \(buildProductsDir)")
                    }
                }
            }
            // Embed frameworkds
            for target in project.targets {
                let buildPhases = target.buildPhases
                let copyFilesBuildPhases = buildPhases.compactMap({$0 as? PBXCopyFilesBuildPhase})
                for copyfilesPhase in copyFilesBuildPhases {
                    if copyfilesPhase.name == "Embed Frameworks" {
                        let files = copyfilesPhase.files
                        let otherBuildPhases = buildPhases.compactMap({$0 as? PBXFrameworksBuildPhase})
                        let otherBuildFiles = otherBuildPhases.flatMap({$0.files})
                        // for each fileRef of framework in build phease
                        for otherBuildFile in otherBuildFiles {
                            guard let fileRef = otherBuildFile.fileRef as? PBXFileReference else {
                                continue
                            }
                            guard fileRef.lastKnownFileType ?? fileRef.explicitFileType == "wrapper.framework" else {
                                continue
                            }
                            guard !files.contains(where: { $0.fileRef as? PBXFileReference == fileRef}) else {
                                options.debug("❄️ Already embeded framework \(fileRef.name ?? fileRef.path ?? fileRef.description)")
                                continue // already added
                            }
                            let fields: PBXObject.Fields = [
                                PBXBuildFile.PBXKeys.fileRef.rawValue: fileRef.ref,
                                PBXBuildFile.PBXKeys.settings.rawValue: ["ATTRIBUTES": ["CodeSignOnCopy", "RemoveHeadersOnCopy"]] // TODO option sign or not
                            ]
                            var newRef = XcodeUUID.generate()
                            while xcodeProject.objects.object(newRef) != nil {
                                newRef = XcodeUUID.generate()
                            }
                            let embedFile = PBXBuildFile(ref: newRef, fields: fields, objects: xcodeProject.objects)
                            embedFile.attach()
                            copyfilesPhase.add(object: embedFile, into: PBXBuildPhase.PBXKeys.files)
                            options.log("🚀 Embed framework \(fileRef.name ?? fileRef.path ?? fileRef.description) with ref \(newRef)")
                            hasChange = true
                        }
                    }
                }
            }

            // If has change, write to file
            if false && hasChange {
                do {
                    try xcodeProject.write(to: projectDataPath.url, format: .openStep)
                    options.log("💾 Project saved")
                } catch let ioError {
                    options.error("Cannot save project \(ioError)")
                }
            } else {
                options.debug("❄️ Nothing to change to project")
            }*/
        }
    }
}
