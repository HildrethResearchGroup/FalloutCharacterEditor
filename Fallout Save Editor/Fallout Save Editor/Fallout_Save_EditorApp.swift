//
//  Fallout_Save_EditorApp.swift
//  Fallout Save Editor
//
//  Created by Kyle Collins on 10/9/24.
//

import SwiftUI

@main
struct FalloutSaveEditorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Open") {
                    // Trigger the openFile function via NotificationCenter
                    NotificationCenter.default.post(name: .openFile, object: nil)
                }
                .keyboardShortcut("o", modifiers: [.command])
                
                Divider()
                
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: [.command])
            }
        }
    }
}

// Extension to define the openFile notification
extension Notification.Name {
    static let openFile = Notification.Name("openFile")
}
