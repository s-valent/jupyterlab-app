//
//  AppDelegate.swift
//  JupyterLab
//
//  Created by Valentin on 01.04.2020.
//  Copyright © 2020 Valentin Shinkarev. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    
    @IBAction func copyJupyterLink(_ sender: NSMenuItem) {
        if let url = JupyterURL {
            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.setString(url.absoluteString, forType: .URL)
            pasteBoard.setString(url.absoluteString, forType: .string)
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        do {
            try JupyterURL = getJupyterURL()
            
        } catch let e as JupyterError {
            let alert = NSAlert(error: e)
            alert.messageText = e.description
            alert.runModal()
            terminateJupyterLab()
            return
            
        } catch let e {
            NSAlert(error: e).runModal()
            terminateJupyterLab()
            return
        }
        
        let contentView = ContentView()
            .frame(minWidth: 900, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        
        window.center()
        window.setFrameAutosaveName("Main")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        terminateJupyterLab()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        terminateJupyterLab()
        sender.terminate(self)
        return true
    }
}
