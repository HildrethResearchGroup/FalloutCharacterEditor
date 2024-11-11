//
//
// FalloutSaveFile.swift
//
// This file is responsible for loading the SAVE.DAT file and unpacking the binary. Printing functions are implemented to verify contents of SAVE.DAT file are being targets correctly.
//
//


import Foundation
import Pack

class FalloutSaveFile: ObservableObject {
    @Published var urlToPresent: URL? = nil
    @Published var fileSize: String = "No File Selected"
    
    // Components of the save file
    var header: FalloutSaveFileHeader?
    
    // Computed property to display the selected file name
    var fileName: String {
        urlToPresent?.lastPathComponent ?? "No File Selected"
    }
    
    // Load the save file and print confirmation
    func loadSaveFile(from url: URL) {
        do {
            let fileData = try Data(contentsOf: url)
            fileSize = "File size: \(fileData.count) bytes"
            self.urlToPresent = url
            
            // Initialize header
            self.header = FalloutSaveFileHeader(data: fileData)
            
            // Print confirmation message
            print("File loaded successfully: \(fileName)")
            
        } catch {
            fileSize = "Failed to read file data."
            print("Error loading file: \(error)")
        }
    }
    
    // Print header contents to the console
    func printHeaderContents() {
        guard let header = header else {
            print("No header data available.")
            return
        }
        
        print("=== Header Contents ===")
        print("File Signature: \(header.fileSignature ?? "N/A")")
        print("Game Version: \(header.gameVersion ?? 0)")
        print("Release Letter: \(header.releaseLetter ?? "N/A")")
        print("Player Name: \(header.playerName ?? "N/A")")
        print("Save Game Name: \(header.saveGameName ?? "N/A")")
        print("Save Day: \(header.saveDay ?? 0)")
        print("Save Month: \(header.saveMonth ?? 0)")
        print("Save Year: \(header.saveYear ?? 0)")
        print("Save Time: \(header.saveTime ?? 0)")
        print("In-Game Month: \(header.inGameMonth ?? 0)")
        print("In-Game Day: \(header.inGameDay ?? 0)")
        print("In-Game Year: \(header.inGameYear ?? 0)")
        print("In-Game Date: \(header.inGameDate ?? 0)")
        print("Current Map Number: \(header.currentMapNumber ?? 0)")
        print("Current Map Filename: \(header.currentMapFilename ?? "N/A")")
        print("=======================")
    }
    
    
    
}
