//
//  SpectareApp.swift
//  Spectare
//
//  Created by Michael Brown on 10/29/21.
//

import SwiftUI

@main
struct SpectareApp: App {
    let persistenceController = PersistenceController.shared
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
