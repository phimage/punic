//
//  Path+Find.swift
//  Created by phimage on 20/03/2020.
//

import Foundation
import FileKit

let buildDir = "Carthage/Build"
let sourceDir = "Carthage/Checkouts"

extension Path {
    
    enum Extension: String {
        case xcodeproj
        case xcworkspace
    }

    func findXcodeProj() -> Path? {
        var xcodeprojPath = self + "\(self.fileName).\(Path.Extension.xcodeproj)"
        if xcodeprojPath.exists {
            return xcodeprojPath
        }
        xcodeprojPath = (self + self.fileName) + "\(self.fileName).\(Path.Extension.xcodeproj)"
        if xcodeprojPath.exists {
            return xcodeprojPath
        }
        xcodeprojPath = (self + self.fileName) + "\(self.fileName).\(Path.Extension.xcodeproj)"
        if xcodeprojPath.exists {
            return xcodeprojPath
        }
        xcodeprojPath = (self + "\(self.fileName)Example") + "\(self.fileName)Example.\(Path.Extension.xcodeproj)"
        if xcodeprojPath.exists {
            return xcodeprojPath
        }
        xcodeprojPath = (self + "Example") + "\(self.fileName).\(Path.Extension.xcodeproj)"
        if xcodeprojPath.exists {
            return xcodeprojPath
        }
        return self.find(searchDepth: 0, condition: { $0.has(extension: .xcodeproj) }).first
    }

    func findXcodeWorkspace() -> Path? {
        let xcworkspacePath = self + "\(self.fileName).\(Path.Extension.xcworkspace)"
        if xcworkspacePath.exists {
            return xcworkspacePath
        }
        return self.find(searchDepth: 0, condition: { $0.has(extension: .xcworkspace) }).first
    }

    func find(extension ext: Extension) -> Path? {
        switch ext {
        case .xcodeproj:
            return self.findXcodeProj()
        case .xcworkspace:
            return self.findXcodeWorkspace()
        }
    }

    func has(extension ext: Extension) -> Bool {
        return self.pathExtension == ext.rawValue
    }

    func of(extension ext: Extension) -> Path {
        var path = self.parent + self.fileName
        path.pathExtension = ext.rawValue
        return path
    }
}
