//
//  KitIconGeneratorApp.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 21/11/2023.
//

import SwiftUI

@main
struct KitIconGeneratorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.commands {
            SidebarCommands()
        }
    }
}
