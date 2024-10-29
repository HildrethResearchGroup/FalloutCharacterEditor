//
//  FileReader.swift
//  Fallout Save Editor
//
//  Created by Thomas Coates on 10/9/24.
//
import Foundation
import Pack

class FileReader: ObservableObject {
    @Published var urlToPresent: URL? = nil
    @Published var fileSize: String = "No File Selected"

    // Computed property to display the selected file name
    var fileName: String {
        urlToPresent?.lastPathComponent ?? "No File Selected"
    }

    // Load save file and update the file size
    func loadSaveFile(from url: URL) {
        do {
            let fileData = try Data(contentsOf: url)
            fileSize = "File size: \(fileData.count) bytes"
            unpackSaveData(from: fileData)
        } catch {
            fileSize = "Failed to read file data."
        }
    }

    private func unpackSaveData(from data: Data) {
        print("Unpacking save data...")

        // Unpacking the character name
        let characterNameData = data.subdata(in: 0x1D..<(0x1D + 32))
        if let characterName = String(data: characterNameData, encoding: .utf8) {
            print("Character Name: \(characterName)")
        }
    }
}

