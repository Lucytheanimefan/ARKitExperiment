//
//  ARViewController.swift
//  ARKitExperiment
//
//  Created by Lucy Zhang on 1/2/18.
//  Copyright © 2018 Lucy Zhang. All rights reserved.
//

import UIKit
import ARKit

class ARViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    var planes:[UUID: VirtualPlane]! = [UUID: VirtualPlane]()
    var configuration: ARWorldTrackingConfiguration!
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSceneView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func initializeSceneView() {
        // Set the view's delegate
        sceneView.delegate = self as? ARSCNViewDelegate
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create new scene and attach the scene to the sceneView
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        
        // Add the SCNDebugOptions options
        // showConstraints, showLightExtents are SCNDebugOptions
        // showFeaturePoints and showWorldOrigin are ARSCNDebugOptions
        //sceneView.debugOptions  = [SCNDebugOptions.showConstraints, SCNDebugOptions.showLightExtents, ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        
        //shows fps rate
        sceneView.showsStatistics = true
        
        sceneView.automaticallyUpdatesLighting = true
    }
    
    func startSession() {
        configuration = ARWorldTrackingConfiguration()
        //currenly only planeDetection available is horizontal.
        configuration!.planeDetection = ARWorldTrackingConfiguration.PlaneDetection.horizontal
        sceneView.session.run(configuration!, options: [ARSession.RunOptions.removeExistingAnchors,
                                                        ARSession.RunOptions.resetTracking])
        
    }
    
    func setPlaneTexture(node: SCNNode, imageFilePath:String) {
        if let geometryNode = node.childNodes.first {
            if node.childNodes.count > 0 {
                geometryNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imageFilePath)
                geometryNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
                geometryNode.geometry?.firstMaterial?.diffuse.wrapS = SCNWrapMode.repeat
                geometryNode.geometry?.firstMaterial?.diffuse.wrapT = SCNWrapMode.repeat
                geometryNode.geometry?.firstMaterial?.diffuse.mipFilter = SCNFilterMode.linear
            }
        }
    }

    
    func loadNodeObject(fileName:String, name:String) -> SCNNode
    {
        let box = SCNBox(width: 0.001, height: 0.1, length: 0.1, chamferRadius: 0)
        box.firstMaterial?.diffuse.contents = UIImage(named: fileName)
        let boxNode = SCNNode()
        boxNode.geometry = box
        return boxNode
    }
    
    func stopPlaneDetection(){
        if let configuration = self.sceneView.session.configuration as? ARWorldTrackingConfiguration
        {
            configuration.planeDetection = []
            self.sceneView.session.run(configuration)
        }
    }
    
    // want to shine it down so rotate 90deg around the
    // x-axis to point it down
    func insertSpotlight(position:SCNVector3){
        let spotlight = SCNLight()
        spotlight.type = .spot
        spotlight.spotInnerAngle = 45
        spotlight.spotOuterAngle = 45
        
        let node = SCNNode()
        node.light = spotlight
        node.position = position
        
        node.eulerAngles = SCNVector3Make(Float(-Double.pi/2), 0, 0)
        self.sceneView.scene.rootNode.addChildNode(node)
    }

    

}
