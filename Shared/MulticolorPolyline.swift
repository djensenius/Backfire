//
//  MulticolorPolyline.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-08.
//

import Foundation
import MapKit

// extension MKPolyline {
class MulticolorPolyline: MKPolyline {
    #if os(iOS) || os(visionOS)
        var color = UIColor.black
    #else
        var color = NSColor.black
    #endif
}
