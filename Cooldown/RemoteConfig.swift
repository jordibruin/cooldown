//
//  RemoteConfig.swift
//  Cooldown
//
//  Created by Jordi Bruin on 05/11/2021.
//

import Foundation
import AppKit

struct CooldownConfig: Decodable {
    var latestVersion: Int
}

class ConfigManager: ObservableObject {
    
    @Published var allowedVersion: Int = 0
    @Published var shouldUpdate: Bool = false
    
    init() {
        checkForUpdates()
    }
    
    func checkForUpdates() {
        loadJson(fromURLString: "https://simplejsoncms.com/api/") { result in
            switch result {
            case let .success(data):
                //                    print("Got data")
                let config: CooldownConfig = try! JSONDecoder().decode(CooldownConfig.self, from: data)
                print(config.latestVersion)
                DispatchQueue.main.async { [unowned self] in
                    self.allowedVersion = config.latestVersion
                    self.checkIfBuildIsNewEnough()
                }
                
            case let .failure(error):
                print("error:", error.localizedDescription)
                self.shouldUpdate = true
            }
        }
    }
    
    private func checkIfBuildIsNewEnough() {
        if let buildVersion = Bundle.main.buildVersionNumber {
            if let buildVersionInt = Int(buildVersion) {
                //                print(buildVersionInt)
                
                if self.allowedVersion <= buildVersionInt {
//                    print(buildVersionInt)
//                    print("User is up to date")
                } else {
//                    print(buildVersionInt)
//                    print("User is using an older version of the app")
                    DispatchQueue.main.async { [unowned self] in
                        //                        self.shouldUpdate = true
                        let alert = NSAlert()
                        alert.messageText = "Update Available"
                        alert.informativeText = "A new version of Cooldown is available."
                        alert.alertStyle = NSAlert.Style.warning
                        alert.addButton(withTitle: "Update now")
                        alert.addButton(withTitle: "Cancel")
                        
                        let modalResult = alert.runModal()
                        
                        switch modalResult {
                        case .alertFirstButtonReturn: // NSApplication.ModalResponse.alertFirstButtonReturn
                            if let url = URL(string: "https://goodsnooze.gumroad.com/l/cooldown") {
                                if NSWorkspace.shared.open(url) {
                                    print("Opened Gumroad")
                                }
                            }
                        default:
                            print("Cancel clicked")
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    private func loadJson(fromURLString urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            let urlSession = URLSession(configuration: .ephemeral).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                }
                
                if let data = data {
                    completion(.success(data))
                }
            }
            urlSession.resume()
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

//Bundle.main.releaseVersionNumber
//Bundle.main.buildVersionNumber

