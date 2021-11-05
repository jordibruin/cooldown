//
//  CooldownApp.swift
//  Cooldown
//
//  Created by Jordi Bruin on 05/11/2021.
//

import SwiftUI

@main
struct CooldownApp: App {
    
    @NSApplicationDelegateAdaptor(StatusBarDelegate.self) var appDelegate
    
    @StateObject var config = ConfigManager()
    
    var body: some Scene {
        WindowGroup {
            Color.clear
                .frame(width: 0, height: 0)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
    }
        
    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
}

