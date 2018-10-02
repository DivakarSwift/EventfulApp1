//
//  EditProfile.swift
//  Eventful
//
//  Created by Shawn Miller on 7/16/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import Foundation
import UIKit
import Eureka
import ImageRow
import AlamofireImage
import Firebase
import FirebaseStorage
import SVProgressHUD

class EditProfile: FormViewController {
    var currentProfilePic: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBackButton()
        setupDoneButton()
    }
    @objc func setupBackButton(){
        self.navigationItem.title = "Edit Profile"
        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(self.GoBack))
        self.navigationItem.leftBarButtonItem = backButton
    }
    @objc func GoBack(){
        self.dismiss(animated: true, completion: nil)
    }

    @objc func setupDoneButton(){
        //begin saving to firebase
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.saveChanges))
        doneButton.tintColor = UIColor.black
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func saveChanges(){
        let valuesDictionary = form.values()
        SVProgressHUD.show(withStatus: "Saving Changes")
        print(valuesDictionary["usernameTag"] as Any)
        print(valuesDictionary["nameTag"] as Any)
        print(valuesDictionary["bioTag"] as Any)
        
        guard let username = valuesDictionary["usernameTag"] as? String, let nameTag = valuesDictionary["nameTag"] as? String, let bio = valuesDictionary["bioTag"] as? String  else{
            return
        }
        //creates a unique id for storing images in firebase storage
        let imageName = NSUUID().uuidString
        //create a reference to the sotrage database in firebase
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).PNG")
        
        if let userImage = valuesDictionary["imageRowTag"], let uploadData = UIImageJPEGRepresentation(userImage as! UIImage, 0.1){
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print(error ?? "")
                    return
                }
                
                storageRef.downloadURL(completion: { (downloadURL, error) in
                    guard let profileImageURL = downloadURL?.absoluteString else {
                        return
                    }
                     print("Successfully uploaded profile image:", profileImageURL)
                    
                    
                    UserService.editProfileImage(url: profileImageURL, completion: {(user) in
                        if let user = user {
                            User.setCurrent(user, writeToUserDefaults: true)
                        }
                    })
                    
                    
                    UserService.edit(username: username, bio: bio, name: nameTag) {(user) in
                        guard let user = user else {
                            return
                        }
                        User.setCurrent(user, writeToUserDefaults: true)
                        
                        SVProgressHUD.dismiss(completion: {
                            self.dismiss(animated: true, completion: nil)
                        })
                        
                    }
                   
                    
                })
            }
            
        }
    }
    
    @objc func setupViews(){
        form +++ Section("Change Profile Picture")
            <<< ImageRow("imageRowTag") {
                $0.title = "Profile Picture"
                $0.sourceTypes = [.PhotoLibrary, .SavedPhotosAlbum]
                $0.clearAction = .yes(style: UIAlertActionStyle.destructive)
                $0.allowEditor = true
                
                if let image = currentProfilePic {
                    $0.value = image
                }
                $0.useEditedImage = true
                $0.add(rule: RuleRequired())
                }
                .cellUpdate { cell, row in
                    cell.accessoryView?.layer.cornerRadius = 17
                    cell.accessoryView?.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
                    row.reload()
                    print(row.value as Any)
        }
        form +++ Section("General Info")
            <<< NameRow("nameTag"){ row in
                row.value = User.current.name
                row.title = "Name"
                row.placeholder = "Name"
        }
            <<< TextRow("usernameTag"){ row in
                row.title = "Username"
                row.value = User.current.username
                row.placeholder = "Username"
                row.add(rule: RuleRequired())
        }
            <<< TextAreaRow("bioTag"){
                $0.value = User.current.bio
                $0.placeholder = "Bio"
        }
    }
}
