//
//  Path+Find.swift
//  Created by phimage on 20/03/2020.
//

import Foundation
import FileKit

extension Path {
    
    func findXcodeProj() -> Path? {
        var xcodeprojPath = self + "\(self.fileName).xcodeproj"
        if xcodeprojPath.exists {
            return xcodeprojPath
        }
        xcodeprojPath = (self + self.fileName) + "\(self.fileName).xcodeproj"
        if xcodeprojPath.exists {
            return xcodeprojPath
        }
        xcodeprojPath = (self + self.fileName) + "\(self.fileName).xcodeproj"
        if xcodeprojPath.exists {
            return xcodeprojPath
        }
        xcodeprojPath = (self + "\(self.fileName)Example") + "\(self.fileName)Example.xcodeproj"
        if xcodeprojPath.exists {
            return xcodeprojPath
        }
        xcodeprojPath = (self + "Example") + "\(self.fileName).xcodeproj"
        if xcodeprojPath.exists {
            return xcodeprojPath
        }
        return nil
    }

    func findXcodeWorkspace() -> Path? {
        let xcworkspacePath = self + "\(self.fileName).xcworkspace"
        if xcworkspacePath.exists {
            return xcworkspacePath
        }
        if let first = self.find(condition: {$0.pathExtension == "xcworkspace"}).first {
            return first
        }
        return nil
    }
}

// MARK: cmd
