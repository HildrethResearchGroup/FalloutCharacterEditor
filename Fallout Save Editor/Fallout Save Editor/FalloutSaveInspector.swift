import Foundation

class FalloutSaveInspector {
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    /// Finds the offset of a specified byte pattern in the data.
    /// - Parameter pattern: The byte pattern to search for.
    /// - Returns: The offset if found, or `nil` if not found.
    func offset(of pattern: Data) -> Int? {
        guard pattern.count > 0, pattern.count <= data.count else { return nil }
        
        for i in 0..<(data.count - pattern.count + 1) {
            if data.subdata(in: i..<(i + pattern.count)) == pattern {
                return i
            }
        }
        
        return nil
    }
    
    /// Finds the offset for Function 5 - Player and Inventory.
    /// The expected byte sequence is `0x00004650`.
    func findFunction5Offset() -> Int? {
        // Define the pattern for "0x00004650" in Big Endian
        let function5Pattern = Data([0x00, 0x00, 0x46, 0x50])
        return offset(of: function5Pattern)
    }
    
    /// Calculates the total size of Function 5 based on the number of items in inventory.
    /// - Parameter function5Offset: The starting offset of Function 5.
    /// - Returns: The total size of Function 5 in bytes.
    func calculateFunction5Size(function5Offset: Int) -> Int {
        // Fixed portion size (up to offset 0x80)
        let fixedSize = 0x80
        
        // Read the number of inventory items at offset 0x48
        let numItemsOffset = function5Offset + 0x48
        let numItemsData = data.subdata(in: numItemsOffset..<(numItemsOffset + 4))
        let numItems = numItemsData.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        
        // Size of each inventory item entry is 0x64 bytes
        let itemSize = 0x64
        let inventoryListSize = Int(numItems) * itemSize
        
        // Total size of Function 5
        return fixedSize + inventoryListSize
    }
    
    func inspectFunction5() {
        if let function5Offset = findFunction5Offset() {
            print("Function 5 - Player and Inventory found at offset: \(function5Offset)")
            
            // Read and print the first few bytes after the offset for verification
            let bytesToRead = 16
            let endOffset = min(function5Offset + bytesToRead, data.count)
            let function5Data = data.subdata(in: function5Offset..<endOffset)
            
            print("Function 5 Data (first \(bytesToRead) bytes): \(function5Data.map { String(format: "%02X", $0) }.joined(separator: " "))")
            
            // Read the number of inventory items at offset 0x48 within Function 5
            let numItemsOffset = function5Offset + 0x48
            let numItemsData = data.subdata(in: numItemsOffset..<(numItemsOffset + 4))
            let numItems = numItemsData.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            
            print("Number of items in inventory: \(numItems)")
            
            // Calculate the size of Function 5
            let function5Size = calculateFunction5Size(function5Offset: function5Offset)
            print("Function 5 Size: \(function5Size) bytes")
            
            // Calculate the offset for Function 6
            let function6Offset = function5Offset + function5Size
            print("Function 6 starts at offset: \(function6Offset)")
        } else {
            print("Pattern for Function 5 not found.")
        }
    }

    
    func inspectFunction6() {
        guard let function5Offset = findFunction5Offset() else {
            print("Function 5 not found, unable to locate Function 6.")
            return
        }
        
        // Calculate Function 6 offset as directly after Function 5
        let function6Offset = function5Offset + calculateFunction5Size(function5Offset: function5Offset)
        
        
        // Helper function to read and print a stat at a given offset
        func readStat(at offset: Int, description: String) -> UInt32 {
            let dataOffset = offset
            let statData = data.subdata(in: dataOffset..<(dataOffset + 4))
            let statValue = statData.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            print("\(description): \(statValue) (Raw bytes: \(statData.map { String(format: "%02X", $0) }.joined(separator: " ")))")
            return statValue
        }
        
    }

}
