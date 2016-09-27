//
//  Plist.swift
//  Square Root Marbles
//
// Copied from www.learncoredata.com/plist


import Foundation

struct Plist{
    enum PlistError: Error{
        case fileNotWritten
        case fileDoesNotExist
    }
    
    let name: String
    
    var sourcePath: String?{
        guard let path = Bundle.main.path(forResource: name, ofType: "plist") else {return .none}
        return path
    }
    
    var destPath: String?{
        guard sourcePath != .none else {return .none}
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (dir as NSString).appendingPathComponent("\(name).plist")
    }
    
    init?(name: String){
        self.name = name
        let fileManager = FileManager.default
        
        guard let source = sourcePath else {return nil}
        guard let destination = destPath else {return nil}
        guard fileManager.fileExists(atPath: source) else {return nil}
        
        if !fileManager.fileExists(atPath: destination){
            do{
                try fileManager.copyItem(atPath: source, toPath: destination)
            }catch let error as NSError{
                print("Unable to copy file. ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    func getValuesInPlistFile() -> NSDictionary?{
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!){
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .none}
            return dict
        }else{
            return .none
        }
    }
    
}
