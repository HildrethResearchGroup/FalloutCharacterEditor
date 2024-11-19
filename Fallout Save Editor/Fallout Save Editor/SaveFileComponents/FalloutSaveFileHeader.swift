//
//
// FalloutSaveFileHeader.swift
//
// This file is to layout the SAVE.DAT header section of the binary file. Reference the
// https://falloutmods.fandom.com/wiki/SAVE.DAT_File_Format to see the breakdown of this section.
//
//

import Foundation

class FalloutSaveFileHeader {
    // Header properties
    var fileSignature: String?
    var gameVersion: UInt32?
    var releaseLetter: String?
    var playerName: String?
    var saveGameName: String?
    var saveDay: UInt16?
    var saveMonth: UInt16?
    var saveYear: UInt16?
    var saveTime: UInt32?
    var inGameMonth: UInt16?
    var inGameDay: UInt16?
    var inGameYear: UInt16?
    var inGameDate: UInt32?
    var currentMapNumber: UInt32?
    var currentMapFilename: String?

    init(data: Data) {
        // File Signature
        let signatureData = data.subdata(in: 0x00..<(0x00 + 0x18))
        fileSignature = String(data: signatureData, encoding: .utf8)
        
        // Game Version
        let versionData = data.subdata(in: 0x18..<(0x18 + 0x04))
        gameVersion = versionData.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        
        // Release Letter
        let releaseLetterData = data.subdata(in: 0x1C..<(0x1C + 0x01))
        releaseLetter = String(data: releaseLetterData, encoding: .utf8)
        
        // Player Name
        let playerNameData = data.subdata(in: 0x1D..<(0x1D + 0x20))
        playerName = String(data: playerNameData, encoding: .utf8)
        
        // Savegame Name
        let saveGameNameData = data.subdata(in: 0x3D..<(0x3D + 0x1E))
        saveGameName = String(data: saveGameNameData, encoding: .utf8)
        
        // Save Day
        let saveDayData = data.subdata(in: 0x5B..<(0x5B + 0x02))
        saveDay = saveDayData.withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
        
        // Save Month
        let saveMonthData = data.subdata(in: 0x5D..<(0x5D + 0x02))
        saveMonth = saveMonthData.withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
        
        // Save Year
        let saveYearData = data.subdata(in: 0x5F..<(0x5F + 0x02))
        saveYear = saveYearData.withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
        
        // Save Time (Hours and Minutes)
        let saveTimeData = data.subdata(in: 0x61..<(0x61 + 0x04))
        saveTime = saveTimeData.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        
        // In-Game Month
        let inGameMonthData = data.subdata(in: 0x65..<(0x65 + 0x02))
        inGameMonth = inGameMonthData.withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
        
        // In-Game Day
        let inGameDayData = data.subdata(in: 0x67..<(0x67 + 0x02))
        inGameDay = inGameDayData.withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
        
        // In-Game Year
        let inGameYearData = data.subdata(in: 0x69..<(0x69 + 0x02))
        inGameYear = inGameYearData.withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
        
        // In-Game Date
        let inGameDateData = data.subdata(in: 0x6B..<(0x6B + 0x04))
        inGameDate = inGameDateData.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        
        // Map Number
        let mapNumberData = data.subdata(in: 0x6F..<(0x6F + 0x04))
        currentMapNumber = mapNumberData.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
        
        // Map Filename
        let mapFilenameData = data.subdata(in: 0x73..<(0x73 + 0x10))
        currentMapFilename = String(data: mapFilenameData, encoding: .utf8)
    }
}
