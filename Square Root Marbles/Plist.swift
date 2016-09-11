//
//  Plist.swift
//  Square Root Marbles
//
// Copied from www.learncoredata.com/plist


import Foundation

struct Plist{
    enum PlistError: ErrorType{
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let name: String
    
    var sourcePath: String?{
        guard let path = NSBundle.mainBundle().pathForResource(name, ofType: "plist") else {return .None}
        return path
    }
    
    var destPath: String?{
        guard sourcePath != .None else {return .None}
        let dir = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        return (dir as NSString).stringByAppendingPathComponent("\(name).plist")
    }
    
    init?(name: String){
        self.name = name
        let fileManager = NSFileManager.defaultManager()
        
        guard let source = sourcePath else {return nil}
        guard let destination = destPath else {return nil}
        guard fileManager.fileExistsAtPath(source) else {return nil}
        
        if !fileManager.fileExistsAtPath(destination){
            do{
                try fileManager.copyItemAtPath(source, toPath: destination)
            }catch let error as NSError{
                print("Unable to copy file. ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    func getValuesInPlistFile() -> NSDictionary?{
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(destPath!){
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .None}
            return dict
        }else{
            return .None
        }
    }
    
}