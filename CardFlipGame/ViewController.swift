//
//  ViewController.swift
//  CardFlipGame
//
//  Created by Michael Wijaya Sutrisna on 02/08/23.
//

import UIKit
import RealityKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2, 0.2])
        arView.scene.addAnchor(anchor)
        
        var cards: [Entity] = []
        for _ in 1...16 {
            let box = MeshResource.generateBox(width: 0.04, height: 0.002, depth: 0.04)
            let metalMaterial = SimpleMaterial(color: .gray, isMetallic: true)
            let model = ModelEntity(mesh: box, materials: [metalMaterial])
            
            model.generateCollisionShapes(recursive: true)
            
            cards.append(model)
        }
        
        for (index, card) in cards.enumerated() {
            let x = Float(index % 4)
            let z = Float(index / 4)
            
            card.position = [x*0.1, 0, z*0.1]
            anchor.addChild(card)
        }
        
        let boxSize: Float = 0.7
        let occlusionBoxMesh = MeshResource.generateBox(size: boxSize)
        let occlusionBox = ModelEntity(mesh: occlusionBoxMesh, materials: [OcclusionMaterial()])
        occlusionBox.position.y = -boxSize / 2
        anchor.addChild(occlusionBox)
        
        var cancellable : AnyCancellable? = nil
        
        cancellable = ModelEntity.loadModelAsync(named: "sneaker_pegasustrail")
            .append(ModelEntity.loadModelAsync(named: "toy_biplane_idle"))
            .append(ModelEntity.loadModelAsync(named: "toy_drummer_idle"))
            .append(ModelEntity.loadModelAsync(named: "pie_lemon_meringue"))
            .append(ModelEntity.loadModelAsync(named: "tv_retro"))
            .append(ModelEntity.loadModelAsync(named: "fender_stratocaster"))
            .append(ModelEntity.loadModelAsync(named: "gramophone"))
            .append(ModelEntity.loadModelAsync(named: "flower_tulip"))
            .collect()
            .sink(receiveCompletion: { error in
                print ("Error: \(error)")
                cancellable?.cancel()
            }, receiveValue: { entities in
                var objects : [ModelEntity] = []
                for entity in entities {
                    entity.setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
                    entity.generateCollisionShapes(recursive: true)
                    for _ in 1...2 {
                        objects.append(entity.clone(recursive: true))
                    }
                }
                objects.shuffle()
                
                for (index, object) in objects.enumerated() {
                    cards[index].addChild(object)
                    cards[index].transform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
                }
                
                cancellable?.cancel()
            })
    }
    
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        if let card = arView.entity(at: tapLocation) {
            if card.transform.rotation.angle == .pi {
                var flipDownTransform = card.transform
                flipDownTransform.rotation = simd_quatf(angle: 0, axis: [1, 0, 0])
                card.move(to: flipDownTransform, relativeTo: card.parent, duration:0.25, timingFunction: .easeInOut)
            } else {
                var flipUpTransform = card.transform
                flipUpTransform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
                card.move(to: flipUpTransform, relativeTo: card.parent, duration:0.25, timingFunction: .easeInOut)
            }
        }
    }
}
