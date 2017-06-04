import Foundation
import Files
import CoreGraphics
import AVFoundation

func getPhotoDate(_ filePath:String) -> Date? {
    let imageURL = URL(fileURLWithPath: filePath)
    
    guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil) else {
        print("💥  Cannot find image at '\(filePath)'")
        return nil
    }
    
    let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as Dictionary?
    let exifDict = imageProperties?[kCGImagePropertyExifDictionary]
    if let dateTimeOriginal = exifDict?[kCGImagePropertyExifDateTimeOriginal] as? String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        let date = dateFormatter.date(from:dateTimeOriginal)
        return date
    } else {
        print("not a string date")
    }
    return nil
}

func getVideoDate(_ fileUrl: URL) -> Date? {
    
    let asset = AVURLAsset(url: fileUrl, options: nil)
    if let creationDate = asset.creationDate {
        return creationDate.dateValue
    }
    return nil
}


func copy(atPath:String, toPath: String) -> Bool {
    //print("cp \(atPath) \(toPath)")
    
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: toPath) {
        print("\(atPath) already exists")
        return false
    }
    
    // Create a FileManager instance
    do {
        try fileManager.copyItem(atPath: atPath, toPath: toPath)
        return true
    }
    catch let error as NSError {
        print("Ooops! Something went wrong: \(error)")
    }
    return false
}

let arguments = CommandLine.arguments

guard arguments.count >= 2 else {
    print("👮  Expected 2 arguments: <source-directory> <destination-directory> <photo-identifier>")
    exit(1)
}

let fileManager = FileManager.default
var isDir : ObjCBool = false

let sourcePath = arguments[1]
let sourceUrl = URL(fileURLWithPath: sourcePath)

let destPath = arguments[2]
let destUrl = URL(fileURLWithPath: destPath)

var photoIdentifer:String?
if arguments.count >= 4 {
    photoIdentifer = arguments[3]
}

// Check if directory exists and is a directory
if fileManager.fileExists(atPath: sourcePath, isDirectory:&isDir) {
    if !isDir.boolValue {
        print("\(sourceUrl) is not a directory")
        exit(1)
    }
} else {
    // file does not exist
    print("\(sourceUrl) directory does not exist")
    exit(1)
}

// Check if directory exists and is a directory
if fileManager.fileExists(atPath: destPath, isDirectory:&isDir) {
    if !isDir.boolValue {
        print("\(destPath) is not a directory")
        exit(1)
    }
} else {
    // file does not exist
    print("\(destPath) directory does not exist")
    exit(1)
}

let destFolder = try Folder(path: destPath)

// Create Sub Folders for Images, Videos and Errors
let  imageDestFolder = try destFolder.createSubfolderIfNeeded(withName: "image")
let  videoDestFolder = try destFolder.createSubfolderIfNeeded(withName: "video")
let  errorDestFolder = try destFolder.createSubfolderIfNeeded(withName: "error")

for file in try Folder(path: sourcePath).files {
    print("Processing \(file.name)...")
    var date:Date?
    var success = false
    var destFolderPath = imageDestFolder.path
    if let fileExtension = file.extension {
        switch fileExtension.uppercased() {
        case "JPG", "PNG":
            date = getPhotoDate(file.path)
        case "MOV", "MP4", "M4V":
            date = getVideoDate(URL(fileURLWithPath: file.path))
            destFolderPath = videoDestFolder.path
            
            // Live Photo should go in image directory
            let livePhotoPath = file.path.replacingOccurrences(of: fileExtension, with: "JPG")
            //print("livePhotoPath: \(livePhotoPath)")
            if fileManager.fileExists(atPath: livePhotoPath) {
                print("Live Photo")
                destFolderPath = imageDestFolder.path
            }
            
        default:
            print("No valid extension found for: \(fileExtension.uppercased())")
        }
    }
    
    
    if let date = date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd-HHmmss"
        let fDate = dateFormatter.string(from: date)
        let filename:String?
        
        if let photoIdentifier = photoIdentifer {
            filename  = "\(fDate)-\(photoIdentifier)-\(file.name)"
        } else {
            filename  = "\(fDate)-\(file.name)"
        }
        
        if let newUrl = NSURL(fileURLWithPath: destFolderPath).appendingPathComponent(filename!) {
            //print("Processing \(newUrl)...")
            success = copy(atPath: file.path, toPath: newUrl.path)
        }
    } else {
        success = false
    }
    
    if !success {
        print("Error - moving to error directory")
        if let newUrl = NSURL(fileURLWithPath: errorDestFolder.path).appendingPathComponent(file.name) {
            success = copy(atPath: file.path, toPath: newUrl.path)
        }
    }
}
