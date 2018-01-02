//
//  ViewController.swift
//  ARKitExperiment
//
//  Created by Lucy Zhang on 1/1/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import ARKit
import AnimeManager

class ViewController: ARViewController {
    
    
    let MAL = MyAnimeList(username: "Silent_Muse", password: nil)
    
    var myAnimeList:[[String:Any]]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.delegate = self
        generateList()
        sceneSetup()
        //addBox()
        addTapGestureToSceneView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sceneSetup(){
        
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        
        let scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.scene.rootNode.addChildNode(lightNode)
        
    }
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2){
        createBoxNode(x: x, y: y, z: z, layer: nil)
        //sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    func createBoxNode(x: Float = 0, y: Float = 0, z: Float = -0.2, width:CGFloat = 0.1, height:CGFloat = 0.1, length:CGFloat = 0.1, layer:CALayer?){
        let box = SCNBox(width: width, height: height, length: length, chamferRadius: 0.5)
        if (layer != nil)
        {
            box.firstMaterial?.diffuse.contents = layer
        }
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3Make(x, y, z)
        // return boxNode
        sceneView.scene.rootNode.addChildNode(boxNode)
    }
    
    func textLayer(title:String) -> CALayer{
        let layer = CALayer()
        layer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        layer.backgroundColor = UIColor.orange.cgColor
        
        let textLayer = CATextLayer()
        textLayer.frame = layer.bounds
        textLayer.fontSize = 12
        textLayer.string = title
        textLayer.alignmentMode = kCAAlignmentLeft
        textLayer.foregroundColor = UIColor.green.cgColor
        textLayer.display()
        layer.addSublayer(textLayer)
        
        return layer
    }
    
    func generateList() {
        let sema = DispatchSemaphore(value: 0)
        MAL.getAnimeList(status: .all, completion: { (animes) in
            self.myAnimeList = animes
            sema.signal()
        }) { (error) in
            print(error)
            sema.signal()
        }
        sema.wait()
        
    }
    
    func addTapGestureToSceneView(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            let hitTestResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
            
            if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
                if (self.myAnimeList.count > 0){
                    let anime = self.myAnimeList.removeFirst()
                    
                    let layer = textLayer(title: anime["anime_title"] as! String)
                    
                    //anime_image_path
                    let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                    
                    if let score = anime["score"] as? Int
                    {
                        let floatScore = CGFloat(Float(score) * 0.050)
                        createBoxNode(x: translation.x, y: translation.y, z: translation.z, width: floatScore, height: floatScore, length: floatScore, layer: layer)
                    }
                    else
                    {
                        createBoxNode(x: translation.x, y: translation.y, z: translation.z, layer: layer)
                    }
                }
            }
            return
            
        }
        node.removeFromParentNode()
    }
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

extension ViewController: ARSCNViewDelegate{
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor{
            let plane = VirtualPlane(anchor: arPlaneAnchor)
            self.planes[arPlaneAnchor.identifier] = plane
            node.addChildNode(plane)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor, let plane = self.planes[arPlaneAnchor.identifier]{
            plane.updateWithNewAnchor(arPlaneAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor, let index = planes.index(forKey: arPlaneAnchor.identifier){
            planes.remove(at: index)
        }
    }
    
    
    
    
}
