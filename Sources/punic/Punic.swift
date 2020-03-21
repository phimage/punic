//
//  Punic.swift
//  
//
//  Created by phimage on 20/03/2020.
//

import Foundation
import ArgumentParser

struct Punic: ParsableCommand {

    static let configuration = CommandConfiguration(
        abstract: "Inject carthage xcodeproj into workspace.",
        subcommands: [Workspace.self, Project.self],
        defaultSubcommand: Workspace.self)

}
