//
//  Jupyter.swift
//  JupyterLab
//
//  Created by Valentin on 01.04.2020.
//  Copyright © 2020 Valentin Shinkarev. All rights reserved.
//

import Foundation

var Jupyter: Process?
let JupyterPath = "/usr/local/bin/jupyter"

enum JupyterError: Error {
    case installationNotFound
    case wrongFileProvided(String)
    
    var description: String {
        switch self {
            case .installationNotFound:
            return "Jupyter from '\(JupyterPath)' failed to launch"
            
            case let .wrongFileProvided(filepath):
            return "Wrong file provided: '\(filepath)'"
        }
    }
}

func getJupyterURL() throws -> URL {
    
    var filename: String
    
    if CommandLine.arguments.last!.contains("file://") {
        filename = CommandLine.arguments.last!
        
    } else {
        (Jupyter, filename) = try startJupyterLab(JupyterPath)
    }
    
    return try getURL(fromFile: filename)
}

func getURL(fromFile file: String) throws -> URL {
    
    guard file.count >= 7 else { throw JupyterError.wrongFileProvided(file) }
    let path = String(file[file.index(file.startIndex, offsetBy: 7)...])

    do {
        let data =  try String(contentsOfFile: path)
        let start = data.range(of: "http://localhost:",
                               options: NSString.CompareOptions.literal,
                               range: data.startIndex..<data.endIndex,
                               locale: nil)!

        let end = data.range(of: "\"",
                             options: NSString.CompareOptions.literal,
                             range: start.upperBound..<data.endIndex,
                             locale: nil)!

        return URL(string: "http://127.0.0.1:" + data[start.upperBound..<end.lowerBound])!
        
    } catch { throw JupyterError.wrongFileProvided(file) }
}

func startJupyterLab(_ path: String) throws -> (Process, String) {
    
    let task = Process()
    task.executableURL = URL(fileURLWithPath: path)
    task.arguments = ["lab", "--browser=\"echo %s\""]
    
    let outputPipe = Pipe()
    task.standardOutput = outputPipe

    do { try task.run() }
    catch { throw JupyterError.installationNotFound }
    
    var filename = ""
    while true {
        if let out = try? outputPipe.fileHandleForReading.read(upToCount: 1) {
            filename += String(decoding: out, as: UTF8.self)
            
            if filename.hasSuffix(".html") { break }
            
        } else { break }
    }
    
    return (jupyter: task, filename: filename)
}

func terminateJupyterLab() {
    Jupyter?.interrupt()
    sleep(1)
    Jupyter?.interrupt()
}
