//
//  ContentView.swift
//  localMerterial
//
//  Created by aaron on 2020/12/17.
//

import SwiftUI
import RealityKit
import AVFoundation

struct ContentView : View {
    var body: some View {
        return ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        spawnTV(in: arView)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func spawnTV(in arView: ARView) {
        let dimensions: SIMD3<Float> = [1.23,0.046,0.7]
        //Create TV housing
        let housingMesh = MeshResource.generateBox(size: dimensions)
        let housingMat = SimpleMaterial(color: .black,roughness: 0.4 ,isMetallic: false)
        let housingEntity = ModelEntity(mesh: housingMesh,materials: [housingMat])
        
        //Create TV Screen
        let screenMesh = MeshResource.generatePlane(width: dimensions.x, depth: dimensions.z)
        let screenMat = SimpleMaterial(color: .black,roughness: 0.2, isMetallic: false)
        let scrennEntity = ModelEntity(mesh: screenMesh,materials: [screenMat])
        scrennEntity.name = "tvScreen"
        
        //Add Tv Screen to housing
        housingEntity.addChild(scrennEntity)
        scrennEntity.setPosition([0,dimensions.y/2+0.001,0], relativeTo: housingEntity)
        
        //Create anchor to place TV on wall
        let anchor = AnchorEntity(plane: .vertical)

        anchor.addChild(housingEntity)
        arView.scene.addAnchor(anchor)
        
        arView.enableTapGesture()
        housingEntity.generateCollisionShapes(recursive: true)
        
    }
}

extension ARView{
    func enableTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognize:)))
        self.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func handleTap(recognize:UITapGestureRecognizer){
        let  tapLocation = recognize.location(in: self)
        
        if let entity  = self.entity(at: tapLocation) as?ModelEntity,entity.name == "tvScreen"{
            loadVideoMaterial(for: entity)
        }
    }
    
    func loadVideoMaterial(for entity: ModelEntity) {
        let asset = AVAsset(url: Bundle.main.url(forResource: "zombieByDeekay", withExtension: "mov")!)
        let playerItem = AVPlayerItem(asset: asset)
        
        let player = AVPlayer()
        entity.model?.materials = [VideoMaterial(avPlayer: player)]
        
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
}
