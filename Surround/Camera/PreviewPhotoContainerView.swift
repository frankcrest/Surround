//
//  PreviewPhotoContainerView.swift
//  InstagramClone
//
//  Created by Frank Chen on 2019-03-12.
//  Copyright © 2019 Frank Chen. All rights reserved.
//

import UIKit
import Photos
import Firebase
import JGProgressHUD
import CoreLocation

class PreviewPhotoContainerView: UIView{
    
     let colours = ["#1abc9c", "#2ecc71", "#3498db", "#9b59b6", "#34495e", "#16a085", "#27ae60", "#2980b9", "#8e44ad","#2c3e50","#f1c40f","#e67e22","#e74c3c","#ecf0f1","#95a5a6","#f39c12","#d35400","#c0392b","#bdc3c7","#7f8c8d"]
    
    let previewImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "cancel_shadow"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    let saveButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "verify-sign"), for: .normal)
        button.addTarget(self, action: #selector(handleSave), for: .touchUpInside)
        return button
    }()
    
    @objc func handleSave(){
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading"
        hud.show(in: self)
        
        guard let previewImage = previewImageView.image else {return}
        guard let uploadData = previewImage.jpegData(compressionQuality: 0.5) else {return}
        
        let filename = NSUUID().uuidString
        
        let storageRef = Storage.storage().reference().child("posts").child(filename)
        
        storageRef.putData(uploadData, metadata: nil) { (metadata, err) in
            if let err = err{
                print("Failed to upload post image", err)
                return
            }
            storageRef.downloadURL(completion: { (downloadUrl, err) in
                if let err = err{
                    print("Failed to download image url", err)
                    return
                }
                guard let imageUrl = downloadUrl?.absoluteString else {return}
                print("Succesfully uploaded post image", imageUrl)
                
                self.saveToDatabaseWithImageUrl(imageUrl: imageUrl)
                hud.dismiss()
            })
        }
    }
    
    fileprivate func saveToDatabaseWithImageUrl(imageUrl: String){
        
        let myAppDelegate = UIApplication.shared.delegate as! AppDelegate
        let currentLocation = myAppDelegate.currentLocation
        let latitude : Double = currentLocation?.coordinate.latitude ?? 0
        let longitude : Double = currentLocation?.coordinate.longitude ?? 0
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let timeStamp = NSDate().timeIntervalSince1970
        let timeStampString = String(format: "%f", timeStamp)
        let randomColour = colours.randomItem()
        
        let docData = ["id": uid,
                       "date":timeStamp,
                       "imageUrl": imageUrl,
                       "latitude": latitude,
                       "longitude":longitude,
                       "colour": randomColour ?? ""] as [String : Any]
        
        Firestore.firestore().collection("posts").document(timeStampString).setData(docData) { (err) in
            if let err = err {
                print("Failed to save user settings:", err)
                return
            }
            
            self.removeFromSuperview()
            let tabBarController = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
            tabBarController.selectedIndex = 0
            
            print("Succesfully stored to firebase")
        }
    }
    
    
    @objc func handleCancel(){
        self.removeFromSuperview()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        
        addSubview(previewImageView)
        addSubview(cancelButton)
        addSubview(saveButton)
        
        previewImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        
        cancelButton.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 25, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 50, height: 50)
        
        saveButton.anchor(top: nil, left: leftAnchor, bottom: bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 12, paddingBottom: 24, paddingRight: 0, width: 50, height: 50)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
