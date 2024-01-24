//
//  StatusBar.swift
//  Cooldown
//
//  Created by Jordi Bruin on 05/11/2021.
//

import SwiftUI
import Foundation
import AppKit

class StatusBarDelegate: NSObject, NSApplicationDelegate {
            
    var statusBar: StatusBar?
    
    lazy var windows = NSWindow()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBar = StatusBar.init()
    }
}

class StatusBar {

    private var statusItem: NSStatusItem
    
    init() {

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(systemSymbolName: "bolt.batteryblock.fill", accessibilityDescription: "Cooldown")?.tint(color: .green)
            
            statusBarButton.image?.size = NSSize(width: 26.0, height: 26.0)
            statusBarButton.image?.isTemplate = false
            statusBarButton.action = #selector(self.doSomeAction(sender:))
            statusBarButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
            statusBarButton.target = self
            
        }
        
        _ = isLPMActive()
    }
    
    @objc func doSomeAction(sender: NSStatusItem) {
        toggleLPowerMode()
    }
    
    func tintedImage(_ image: NSImage, tint: NSColor) -> NSImage {
        guard let tinted = image.copy() as? NSImage else { return image }
        tinted.lockFocus()
        tint.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)
//        NSRectFillUsingOperation(imageRect, .sourceAtop)

        tinted.unlockFocus()
        return tinted
    }

    
    
    func isLPMActive() -> Bool {
        guard let response = run("pmset -g | grep LPowerMode") else {
            print("Could not get anything from terminal")
            return false
        }
        
        let isActive = response.contains("1")
        
        // To add colors in the future
        if let image = NSImage(systemSymbolName: isActive ? "bolt.batteryblock.fill" : "bolt.batteryblock", accessibilityDescription: "Cooldown") {
//            let newImage = tintedImage(image, tint: isActive ? NSColor(red: 11/255, green: 157/255, blue: 142/255, alpha: 1) : .white)
//            newImage.isTemplate = isActive ? false : true
            statusItem.button?.image = image
        }
        
        statusItem.button?.toolTip = isActive ? "Disable Low Power Mode" : "Enable Low Power Mode"
        
        return response.contains("1")
    }
    
    func toggleLPowerMode() {
        if isLPMActive() {
            if let _ = run("osascript -e 'do shell script \"sudo pmset -a LPowerMode 0\" with prompt \"🔋 Cooldown wants to disable Low Power Mode\" with administrator privileges'") {
                print("Disabled Low Power Mode")
                _ = isLPMActive()
            }
        } else {
            if let _ = run("osascript -e 'do shell script \"sudo pmset -a LPowerMode 1\" with prompt \"🔋 Cooldown wants to enable Low Power Mode\" with administrator privileges'") {
                print("Enabled Low Power Mode")
                _ = isLPMActive()
            }
        }
    }
    
    func run(_ cmd: String) -> String? {
        let pipe = Pipe()
        let process = Process()
        process.launchPath = "/bin/sh"
        process.arguments = ["-c", String(format:"%@", cmd)]
        process.standardOutput = pipe
        let fileHandle = pipe.fileHandleForReading
        process.launch()
        return String(data: fileHandle.readDataToEndOfFile(), encoding: .utf8)
    }
}
