//
//  ViewController.swift
//  FlowerRecognition
//
//  Created by Magdalena on 25.07.18.
//  Copyright © 2018 Magdalena Nieznalska. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let userPickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            imageView.image = userPickedImage
            
            guard let ciImage = CIImage(image: userPickedImage) else {
                
                fatalError("Could not convert UIImage to CIImage")
            }
            
            detect(flowerImage: ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }

    func detect(flowerImage: CIImage) {
        
        guard let flowerModel = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            
            fatalError("Loading CoreML Model Failed.")
            
        }
        
        let detectionRequest = VNCoreMLRequest(model: flowerModel) { (detectionRequest, error) in
            
            guard let detectionResult = detectionRequest.results as? [VNClassificationObservation] else {
                
                fatalError("Model failed to process image.")
                
            }
            
            self.navigationItem.title = detectionResult.first?.identifier.capitalized
        
        }
        
        let handler = VNImageRequestHandler(ciImage: flowerImage)
        
        do {
            try handler.perform([detectionRequest])
        }
        catch {
            print("Error detecting Image \(error)")
        }
    }

    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

