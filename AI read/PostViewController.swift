//
//  PostViewController.swift
//  AI read
//
//  Created by 越川将人 on 2021/10/22.
//

import UIKit
import Vision
import VisionKit	
import Alamofire

class PostViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    var requests = [VNRequest]()
    var resultingText = ""
    var activityIndicator: UIActivityIndicatorView!


    var text: String? = ""
    var image: UIImage!
    
    @IBAction func handleCancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func handlePostButton(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()

        self.imageView.image = self.image

        let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                             qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        textRecognitionWorkQueue.async {
            DispatchQueue.main.async(execute: {
                self.resultingText = ""
                if let postImage = self.imageView.image?.cgImage {
                    let requestHandler = VNImageRequestHandler(cgImage: postImage, options: [:])
                    do {
                        try requestHandler.perform(self.requests)
                        } catch {
                            print(error)
                    }
                }
                self.textView.text = self.resultingText
                self.textView.isEditable = false
                self.textView.isSelectable = false
            })
        }
    }
    
    // Setup Vision request as the request can be reused
    private func setupVision() {
        let textRecognitionRequest = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("The observations are of an unexpected type.")
                return
            }
            // 解析結果の文字列を連結する
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                self.resultingText += candidate.string + "\n"
            }
        }
        // 文字認識のレベルを設定
        textRecognitionRequest.recognitionLevel = .accurate
        self.requests = [textRecognitionRequest]
    }

    // 文字認識できる言語の取得
    private func getSupportedRecognitionLanguages() {
        let accurate = try! VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequestRevision1)
        print(accurate)
    }
}
