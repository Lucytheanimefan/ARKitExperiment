//
//  AnimeSceneViewController.swift
//  ARKitExperiment
//
//  Created by Lucy Zhang on 1/2/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import ARKit

class AnimeSceneViewController: ARViewController {
    
    var anchors = [ARAnchor]()
    // set isPlaneSelected to true when user taps on the anchor plane to select.
    var isPlaneSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectExistingPlane(location: CGPoint) {
        // Hit test result from intersecting with an existing plane anchor, taking into account the plane’s extent.
        let hitResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        if hitResults.count > 0 {
            let result: ARHitTestResult = hitResults.first!
            if let planeAnchor = result.anchor as? ARPlaneAnchor {
                for anchor in anchors {
                    if anchor.identifier != planeAnchor.identifier{
                        sceneView.node(for: anchor)?.removeFromParentNode()
                        sceneView.session.remove(anchor: anchor)
                    }
                }

                // keep track of selected anchor only
                anchors = [planeAnchor]
                // set isPlaneSelected to true
                isPlaneSelected = true
                //setPlaneTexture(node: sceneView.node(for: planeAnchor)!, imageFilePath: "Hardwood")
            }
        }
    }
    
    // checks if anchors are already created. If created, clones the node and adds it the anchor at the specified location
    func addNodeAtLocation(location: CGPoint) {
        guard anchors.count > 0 else {
            print("anchors are not created yet")
            return
        }
        
        let hitResults = sceneView.hitTest(location, types: .existingPlaneUsingExtent)
        if hitResults.count > 0 {
            let result: ARHitTestResult = hitResults.first!
            let newLocation = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
            let newNode = loadNodeObject(fileName: "ReachPeng", name: "Peng")
            
            
            newNode.position = newLocation
            
            // Deal with offset since centered
            let height = newNode.boundingBox.max.y - newNode.boundingBox.min.y
            newNode.position.y += height/2
            sceneView.scene.rootNode.addChildNode(newNode)
            
            
        }
    }
    

}

extension AnimeSceneViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let arPlaneAnchor = anchor as? ARPlaneAnchor{
            let plane = VirtualPlane(anchor: arPlaneAnchor)
            plane.setPlaneMaterial(imageName: "Hardwood")
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: sceneView)
        if !isPlaneSelected {
            selectExistingPlane(location: location)
        } else {
            addNodeAtLocation(location: location)
        }
    }
}
