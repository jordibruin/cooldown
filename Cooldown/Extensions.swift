//
//  Extensions.swift
//  Cooldown
//
//  Created by Jordi Bruin on 05/11/2021.
//

import Foundation
import AppKit

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()

        return image
    }
}
