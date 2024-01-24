//
//  ContentView.swift
//  Cooldown
//
//  Created by Jordi Bruin on 05/11/2021.
//

import SwiftUI

// Only used for debugging
struct ContentView: View {
    
    @State var LPMActive = false
    
    var body: some View {
        VStack {
            Text("Low Power Mode")
                .bold()
            Text(LPMActive ? "Enabled" : "Disabled")
            Button {
                togglePowerMode()
            } label: {
                Text(LPMActive ? "Disable LPM" : "Enable LPM")
            }
        }
//        .frame(width: 200, height: 200)
        .background(LPMActive ? Color.yellow : Color.gray)
        .onAppear {
            _ = isLPMActive()
        }
    }
    
    func isLPMActive() -> Bool {
        guard let response = run("pmset -g | grep PowerMode") else {
            print("Could not get anything from terminal")
            return false
        }
        
        LPMActive = response.contains("1")
        return response.contains("1")
    }
    
    func togglePowerMode() {
        if isLPMActive() {
            if let _ = run("osascript -e 'do shell script \"sudo pmset -a PowerMode 0\" with prompt \"Cooldown\" with administrator privileges'") {
                print("Disabled Low Power Mode")
                _ = isLPMActive()
            }
        } else {
            if let _ = run("osascript -e 'do shell script \"sudo pmset -a PowerMode 1\" with prompt \"Cooldown\" with administrator privileges'") {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
