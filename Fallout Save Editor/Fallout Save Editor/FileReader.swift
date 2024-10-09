//
//  FileReader.swift
//  Fallout Save Editor
//
//  Created by Thomas Coates on 10/9/24.
//
import Foundation

class FileReader: ObservableObject {
    @Published var urlToPresent: URL? = nil
    @Published var content: String = "No File Selected"

    // Computed property to display the selected file name
    var fileName: String {
        urlToPresent?.lastPathComponent ?? "‹No File Selected>"
    }

    // Function to update the content by reading from the file URL
    func updateContent() {
        guard let url = urlToPresent else {
            content = "No URL has been provided."
            return
        }

        // Start accessing the security-scoped resource
        if url.startAccessingSecurityScopedResource() {
            defer { url.stopAccessingSecurityScopedResource() } // Ensure we stop accessing after we're done

            do {
                // Attempt to read the file content as a String
                let fileContent = try String(contentsOf: url, encoding: .utf8)
                content = fileContent
            } catch {
                // Handle errors related to file reading
                content = "Failed to read file content: \(error.localizedDescription)"
            }
        } else {
            // If unable to access the resource, display an appropriate message
            content = "Failed to gain access to the file. Please check permissions."
        }
    }
}

