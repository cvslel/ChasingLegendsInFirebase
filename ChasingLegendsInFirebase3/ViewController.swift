//
//  ViewController.swift
//  ChasingLegendsInFirebaseStorage
//
//  Created by Cenker Soyak on 19.10.2023.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseFirestore
import SnapKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let photo = UIImage(systemName: "photo.artframe.circle")
    let imageView = UIImageView()
    let uploadButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
    }
    func createUI(){
        view.backgroundColor = .white
        
        imageView.image = UIImage(named: "photo")
        imageView.layer.borderColor = UIColor(.black).cgColor
        imageView.layer.borderWidth = 1
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(gesture)
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(40)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-40)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-300)
        }
        uploadButton.setTitle("Upload", for: .normal)
        uploadButton.isEnabled = false
        uploadButton.configuration = .filled()
        uploadButton.addTarget(self, action: #selector(uploadButtonClicked), for: .touchUpInside)
        view.addSubview(uploadButton)
        uploadButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
    }
    func makeAlert(titleInput: String, messageInput: String){
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    @objc func chooseImage(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
        uploadButton.isEnabled = true
    }
    @objc func uploadButtonClicked(){
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaFolder = storageRef.child("media")
        if let imageData = imageView.image?.jpegData(compressionQuality: 0.5){
            let imageReference = mediaFolder.child("image1.jpg")
            imageReference.putData(imageData) { metadata, error in
                if error != nil {
                    self.makeAlert(titleInput: "Error!", messageInput: error?.localizedDescription ?? "Error")
                    return
                } else {
                    imageReference.downloadURL { url, error in
                        if error != nil {
                            print(error!.localizedDescription)
                            return
                        } else {
                            let imageUrl = url?.absoluteString
                            //Database
                            let firestoreDatabase = Firestore.firestore()
                            var firestoreRef: DocumentReference?
                            
                            let firestorePost = ["imageUrl": imageUrl!] as [String: Any]
                            
                            firestoreRef = firestoreDatabase.collection("Posts").addDocument(data: firestorePost, completion: { error in
                                if error != nil{
                                    self.makeAlert(titleInput: "Error", messageInput: error?.localizedDescription ?? "Error")
                                } else{
                                    let vc = SecondVC()
                                    vc.modalPresentationStyle = .fullScreen
                                    self.present(vc, animated: true)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
}
    
