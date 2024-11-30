import Foundation

class FalloutSaveInspector {
    let data: Data

    init(data: Data) {
        self.data = data
    }

    /// Finds the offset of a specific byte pattern in the data.
    /// - Parameter pattern: The byte pattern to search for.
    /// - Returns: The offset if found, otherwise `nil`.
    func findOffset(of pattern: [UInt8]) -> Int? {
        let patternData = Data(pattern)
        for i in 0..<(data.count - patternData.count + 1) {
            if data.subdata(in: i..<(i + patternData.count)) == patternData {
                return i
            }
        }
        return nil
    }

    /// Reads a 4-byte integer at the specified offset in Big Endian format.
    /// - Parameter offset: The starting offset.
    /// - Returns: The integer value.
    func readInt32(at offset: Int) -> Int {
        guard offset + 4 <= data.count else {
            print("Offset \(offset) out of bounds.")
            return 0
        }
        let bytes = data.subdata(in: offset..<(offset + 4))
        return Int(UInt32(bigEndian: bytes.withUnsafeBytes { $0.load(as: UInt32.self) }))
    }

    /// Parses the Function 5 offset in the save file.
    /// - Returns: The offset of Function 5 if found, otherwise `nil`.
    func findFunction5Offset() -> Int? {
        return findOffset(of: [0x00, 0x00, 0x46, 0x50]) // Equivalent to b'\x00\x00\x46\x50'
    }

    /// Calculates the size of Function 5 based on the inventory structure.
    /// - Parameter function5Offset: The starting offset of Function 5.
    /// - Returns: The total size of Function 5.
    func calculateFunction5Size(function5Offset: Int) -> Int {
        let baseSize = 0x80 // Fixed size portion of Function 5
        let inventoryCountOffset = function5Offset + 0x48
        let numItems = readInt32(at: inventoryCountOffset)
        return baseSize + (numItems * 0x64) // Each inventory item is 0x64 bytes
    }

    /// Reads and prints the SPECIAL stats from Function 6.
    func inspectFunction6() {
        guard let function5Offset = findFunction5Offset() else {
            print("Function 5 not found.")
            return
        }

        let function6Offset = function5Offset + calculateFunction5Size(function5Offset: function5Offset)
        print("Function 6 starts at offset: \(function6Offset)")

        let specialStatsOffsets = [
            "Strength": 0x08,
            "Perception": 0x0C,
            "Endurance": 0x10,
            "Charisma": 0x14,
            "Intelligence": 0x18,
            "Agility": 0x1C,
            "Luck": 0x20
        ]

        for (stat, relativeOffset) in specialStatsOffsets {
            let value = readInt32(at: function6Offset + relativeOffset)
            print("\(stat): \(value)")
        }
    }
}
