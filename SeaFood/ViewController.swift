//
//  ViewController.swift
//  SeaFood
//
//  Created by Anup Saud on 2024-08-21.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classificationLabel: UILabel!
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        classificationLabel.text = "Classification"
        
        // Set up the image picker to select an image from the photo library
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }

    // Handle the selected image from the photo library
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            // Display the selected image
            imageView.image = userPickedImage
            
            // Convert UIImage to CIImage for CoreML processing
            guard let ciImage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert the UIImage into CIImage")
            }
            
            // Call the detect function to process the image
            detect(image: ciImage)
        }
        
        // Dismiss the image picker
        imagePicker.dismiss(animated: true, completion: nil)
    }

    // Detect objects in the image using the Inceptionv3 model
    func detect(image: CIImage) {
        do {
            // Load the CoreML model with configuration
            let model = try VNCoreMLModel(for: Inceptionv3(configuration: MLModelConfiguration()).model)
            
            // Create a CoreML request for image classification
            let request = VNCoreMLRequest(model: model) { request, error in
                // Handle the results of the classification
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("Model failed to process image")
                }
                
                // Get the top classifications and their confidence levels
                let topClassifications = results.prefix(5).map { classification in
                    return "\(classification.identifier): \(classification.confidence * 100)%"
                }.joined(separator: "\n")
                
                // Display the classifications on the screen
                DispatchQueue.main.async {
                    self.classificationLabel.text = topClassifications
                }
                
                // Print the classification results in the console
                print(topClassifications)
            }
            
            // Perform the request on the image
            let handler = VNImageRequestHandler(ciImage: image)
            try handler.perform([request])
        } catch {
            // Handle errors in loading the model or processing the image
            print("Error loading CoreML Model: \(error)")
        }
    }

    // Trigger the image picker when the camera button is tapped
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}
