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

class PostViewController: UIViewController, UINavigationControllerDelegate, URLSessionDelegate {

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
        
        var alertTextField: UITextField?

        let alert = UIAlertController(
            title: "ファイル転送",
            message: "物件CDを入力してください",
            preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(
            configurationHandler: {(textField: UITextField!) in
                alertTextField = textField
                textField.text = ""
                // textField.placeholder = "Mike"
                // textField.isSecureTextEntry = true
        })
        alert.addAction(
            UIAlertAction(
                title: "キャンセル",
                style: UIAlertAction.Style.cancel,
                handler: nil))
        alert.addAction(
            UIAlertAction(
                title: "転送",
                style: UIAlertAction.Style.default) { _ in
                if let text = alertTextField?.text {
                    let imageJpgData = self.imageView.image!.jpegData(compressionQuality: 1)
                    let textData = self.textView.text.data(using: .utf8)
                    let propertyCode = text.data(using: .utf8)
                    // let propertyCode = self.textField.text!.data(using: .utf8)

                    AF.upload(
                        multipartFormData: { multipartFormData in
                            multipartFormData.append(imageJpgData!, withName: "upload_img_jpg" , fileName: "test01.jpg", mimeType: "image/jpeg")
                            multipartFormData.append(textData!, withName: "upload_txt" , fileName: "test01.txt", mimeType: "text/plain")
                            multipartFormData.append(propertyCode!, withName: "upload_code" , fileName: "code.txt", mimeType: "text/plain")
                        },
                        // to: "http://192.168.97.160/test2.php", method: .post
                        to: "https://sf.489501.jp/kotei/d2b/test2.php", method: .post
                        )
                        .response { resp in
                            switch resp.result {
                                case .success:
                                    print("response is:", resp)
                                    DispatchQueue.main.async {
                                        self.dismiss(animated: true)
                                        // 正常終了メッセージ表示実装
                                        
                                    }
                                case let .failure(error):
                                    print(error)
                                        // 異常終了メッセージ表示実装
                            }
                        }
                }
            }
        )
        self.present(alert, animated: true, completion: nil)
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
