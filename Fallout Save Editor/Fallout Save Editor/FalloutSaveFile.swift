import Foundation
import Pack

@Observable
class FalloutSaveFile {
    var urlToPresent: URL? = nil
    var fileSize: String = "No File Selected"
    
    // Components of the save file
    var header: FalloutSaveFileHeader?
    private var originalHeader: FalloutSaveFileHeader? // To store the original header state
    
    // SPECIAL stats
    var strength: Int = 0
    var perception: Int = 0
    var endurance: Int = 0
    var charisma: Int = 0
    var intelligence: Int = 0
    var agility: Int = 0
    var luck: Int = 0
    
    private var inspector: FalloutSaveInspector?

    // Computed property to display the selected file name
    var fileName: String {
        urlToPresent?.lastPathComponent ?? "No File Selected"
    }
    
    // Load the save file and parse data
    func loadSaveFile(from url: URL) {
        do {
            let fileData = try Data(contentsOf: url)
            fileSize = "\(fileData.count) bytes"
            self.urlToPresent = url
            
            // Initialize the FalloutSaveInspector
            inspector = FalloutSaveInspector(data: fileData)
            
            // Parse the header
            self.header = FalloutSaveFileHeader(data: fileData)
            self.originalHeader = header // Store the original state
            
            // Parse SPECIAL stats
            parseSpecialStats()
            
            // Print confirmation message
            print("File loaded successfully: \(fileName)")
        } catch {
            fileSize = "Failed to read file data."
            print("Error loading file: \(error)")
        }
    }
    
    // Reset the header and SPECIAL stats to their original state
    func resetHeader() {
        guard let originalHeader = originalHeader else {
            print("No original header to reset to.")
            return
        }
        self.header = originalHeader
        resetSpecialStats()
    }
    
    private func resetSpecialStats() {
        strength = 0
        perception = 0
        endurance = 0
        charisma = 0
        intelligence = 0
        agility = 0
        luck = 0
    }

    // Parse SPECIAL stats from the save file
    private func parseSpecialStats() {
        guard let inspector = inspector else {
            print("Inspector is not initialized. Unable to parse SPECIAL stats.")
            return
        }
        
        if let function5Offset = inspector.findFunction5Offset() {
            let function6Offset = function5Offset + inspector.calculateFunction5Size(function5Offset: function5Offset)
            strength = inspector.readInt32(at: function6Offset + 0x08)
            perception = inspector.readInt32(at: function6Offset + 0x0C)
            endurance = inspector.readInt32(at: function6Offset + 0x10)
            charisma = inspector.readInt32(at: function6Offset + 0x14)
            intelligence = inspector.readInt32(at: function6Offset + 0x18)
            agility = inspector.readInt32(at: function6Offset + 0x1C)
            luck = inspector.readInt32(at: function6Offset + 0x20)
        } else {
            print("Function 5 offset not found, unable to parse SPECIAL stats.")
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
    
    // Print SPECIAL stats to the console
    func printSpecialStats() {
        print("=== SPECIAL Stats ===")
        print("Strength: \(strength)")
        print("Perception: \(perception)")
        print("Endurance: \(endurance)")
        print("Charisma: \(charisma)")
        print("Intelligence: \(intelligence)")
        print("Agility: \(agility)")
        print("Luck: \(luck)")
        print("=====================")
    }
}
