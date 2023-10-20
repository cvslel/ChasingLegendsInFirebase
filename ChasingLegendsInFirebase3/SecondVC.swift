//
//  SecondVC.swift
//  ChasingLegendsInFirebaseStorage
//
//  Created by Cenker Soyak on 19.10.2023.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore
import FirebaseStorage
import SDWebImage
import SnapKit

class SecondVC: UIViewController {
    
    let imageNameLabel = UILabel()
    var imageArray = [String]()
    var downloadButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createUI()
        fetchDataFromFirestore()
    }
    func createUI(){
        view.backgroundColor = .white
        
        imageNameLabel.font = .systemFont(ofSize: 20)
        imageNameLabel.numberOfLines = 0
        imageNameLabel.textAlignment = .center
        imageNameLabel.text = "test"
        view.addSubview(imageNameLabel)
        imageNameLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.left.right.equalToSuperview().inset(20)
        }
        downloadButton.setTitle("Download The Photo", for: .normal)
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.configuration = .filled()
        downloadButton.addTarget(self, action: #selector(downloadClicked), for: .touchUpInside)
        view.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(40)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-40)
            make.height.equalTo(100)
        }
    }
    func fetchDataFromFirestore() {
        let firestoreDatabase = Firestore.firestore()
        firestoreDatabase.collection("Posts").addSnapshotListener { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "Error")
            } else {
                if snapshot?.isEmpty != true && snapshot != nil {
                    for document in snapshot!.documents {
                        if let url = document.get("imageUrl") as? String {
                            self.imageNameLabel.text = url
                        }
                    }
                }
            }
        }
    }
    @objc func downloadClicked(){
        let storageRef = Storage.storage().reference()
        let reference = storageRef.child("media/image1.jpg")
        // Load the image using SDWebImage
        reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                if let image = UIImage(data: data!){
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            }
        }
    }
}
