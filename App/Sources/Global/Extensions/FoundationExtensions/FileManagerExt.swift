// Copyright © 2020 Pharos Solutions. All rights reserved.

import Foundation

extension FileManager {
    func localUrl(ofFileName fileName: String) -> URL? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let filePath = URL(fileURLWithPath: path).appendingPathComponent(fileName).path
        if FileManager.default.fileExists(atPath: filePath) {
            return URL(fileURLWithPath: filePath)
        }
        return nil
    }

    func clearAllFiles(inPath path: String, on shouldDelete: (String) -> Bool) throws {
        let documentDirUrl = try url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        guard changeCurrentDirectoryPath(documentDirUrl.path) else { return }

        for file in try contentsOfDirectory(atPath: path) where shouldDelete(file) {
            try removeItem(atPath: file)
        }
    }

    public func moveItem(_ itemName: String, at url: URL, to searchPathDirectory: SearchPathDirectory = .documentDirectory) throws -> URL {
        let documentDirectory = try self.url(for: searchPathDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let destinationUrl = documentDirectory.appendingPathComponent(itemName)
        if fileExists(atPath: destinationUrl.path) {
            try removeItem(at: destinationUrl)
        }
        try moveItem(at: url, to: destinationUrl)
        return destinationUrl
    }
}
