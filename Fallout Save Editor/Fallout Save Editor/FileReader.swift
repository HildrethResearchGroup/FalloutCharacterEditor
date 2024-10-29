//
//  FileReader.swift
//  Fallout Save Editor
//
//  Created by Thomas Coates on 10/9/24.
//
import Foundation

class FileReader: ObservableObject {
    @Published var urlToPresent: URL? = nil
    @Published var fileSize: String = "No File Selected"

    // Computed property to display the selected file name
    var fileName: String {
        urlToPresent?.lastPathComponent ?? "No File Selected"
    }

    // Function to read file and update the file size
    func updateContent() {
        guard let url = urlToPresent else {
            fileSize = stringForError(.noURL)
            return
        }

        do {
            // Read the file content as binary data
            let fileData = try Data(contentsOf: url)

            // Get file size in bytes
            let fileSizeInBytes = fileData.count
            fileSize = "File size: \(fileSizeInBytes) bytes"
            
        } catch {
            // Handle errors related to file reading
            fileSize = stringForError(.noDataAtURL(url: url))
        }
    }

    // Custom error enum to handle different file reading issues
    enum ReaderError: Error {
        case noURL
        case noDataAtURL(url: URL)
    }

    // Function to generate a user-friendly message for errors
    func stringForError(_ error: ReaderError) -> String {
        switch error {
        case .noURL:
            return "No file has been selected."
        case let .noDataAtURL(url):
            return "File does not contain valid data: \(url.absoluteString)."
        }
    }
}
