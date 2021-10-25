//
//  HomeViewController.swift
//  AI read
//
//  Created by 越川将人 on 2021/10/22.
//

import UIKit
import Vision
import VisionKit

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var image: UIImage!
    var requests = [VNRequest]()
    var resultingText = ""
    
    @IBAction func handleCameraButton(_ sender: Any) {
        // カメラを起動して画像を取得する
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
    }
    
    @IBAction func handleLibraryButton(_ sender: Any) {
        // カメラロールから画像を取得する
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any] ) {

        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage
            picker.dismiss(animated: false)
            
            let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
            postViewController.image = image
            
            self.present(postViewController, animated: true, completion: nil)

        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // ImageSelectViewController画面を閉じてタブ画面に戻る
        picker.dismiss(animated: true, completion: nil)
    }
        
}
extension HomeViewController: VNDocumentCameraViewControllerDelegate {
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
        postViewController.image = scan.imageOfPage(at: 0)
        controller.dismiss(animated: false, completion: nil)
        
        self.present(postViewController, animated: true, completion: nil)
    }
}
