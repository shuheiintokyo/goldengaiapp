//
//  GoldenGaiAppApp.swift
//  GoldenGaiApp
//
//  Created by Shuhei Kinugasa on 2025/11/08.
//

import SwiftUI
import CoreData

@main
struct GoldenGaiAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
