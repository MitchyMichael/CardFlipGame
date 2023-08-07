//
//  UIViewRepresentable.swift
//  CardFlipGame
//
//  Created by Michael Wijaya Sutrisna on 07/08/23.
//

import SwiftUI
import RealityKit

struct UIViewRepresentable : UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        let viewController = ViewController.init(arScene: ARView(frame(.zero)))
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = ViewController
}
