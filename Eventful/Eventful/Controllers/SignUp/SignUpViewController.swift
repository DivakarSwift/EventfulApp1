//
//  SignUpViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 7/25/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD
import TextFieldEffects
import Firebase
import GeoFire



class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var selectedImageFromPicker: UIImage?
    //creating a variable of type geofire
    var geoFire: GeoFire!
    var geoFireRef: DatabaseReference!
    // creates a signup UILabel
    var userLocation:String?
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "camblack").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        return button
    }()
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
     plusPhotoButton.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage =
            info["UIImagePickerControllerOriginalImage"] as? UIImage {
            plusPhotoButton.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width/2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 3
        
        dismiss(animated: true, completion: nil)
    }
    
    let nameTextField : HoshiTextField = {
        let nameText = HoshiTextField()
        nameText.placeholderColor = .black
        nameText.placeholder = "Username"
        nameText.placeholderFontScale = 0.85

        nameText.layer.borderColor = UIColor.lightGray.cgColor
        nameText.layer.borderWidth = 0
        nameText.borderStyle = .none
        nameText.borderInactiveColor = .black
        nameText.borderActiveColor = .black
        nameText.textColor = .black
        return nameText
    }()
    
    // creates a email UITextField to hold the email
    let emailTextField : HoshiTextField = {
        let emaiilText = HoshiTextField()
        emaiilText.placeholderColor = .black
        emaiilText.placeholderFontScale = 0.85

        emaiilText.placeholder = "Email"
        emaiilText.layer.borderColor = UIColor.lightGray.cgColor
        emaiilText.layer.borderWidth = 0
        emaiilText.borderStyle = .none
        emaiilText.borderInactiveColor = .black
        emaiilText.borderActiveColor = .black
        emaiilText.textColor = .black
        return emaiilText
    }()
    
    //creates a password UItextield
    let passwordTextField : HoshiTextField = {
        let passwordText = HoshiTextField()
        passwordText.placeholderColor = .black
        passwordText.placeholderFontScale = 0.85

        passwordText.placeholder = "Password"
        passwordText.layer.borderColor = UIColor.lightGray.cgColor
        passwordText.layer.borderWidth = 0
        passwordText.isSecureTextEntry = true
        passwordText.borderStyle = .none
        passwordText.borderInactiveColor = .black
        passwordText.borderActiveColor = .black
        passwordText.textColor = .black
        return passwordText
    }()
    
    //creates a confirm password UItextfield
    let confirmPasswordTextField : HoshiTextField = {
        let confirmPasswordText = HoshiTextField()
        confirmPasswordText.placeholderFontScale = 0.85
        confirmPasswordText.placeholderColor = .black
        confirmPasswordText.placeholder = "Confirm Password"
        confirmPasswordText.layer.borderColor = UIColor.lightGray.cgColor
        confirmPasswordText.layer.borderWidth = 0
        confirmPasswordText.isSecureTextEntry = true
        confirmPasswordText.borderStyle = .none
        confirmPasswordText.borderInactiveColor = .black
        confirmPasswordText.borderActiveColor = .black
        confirmPasswordText.textColor = .black
        return confirmPasswordText
    }()
    
    // creates a UIButton that will sign up the user
    let signupButton: UIButton  = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN UP", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(red: 33, green: 154, blue: 233)
        return button
    }()
    
    // will handle the  sign up of a user
    @objc func handleSignUp(){
        print("entered sign up")
        // first we cant to take sure that all of the fields are filled
        var profilePic: String = ""
        // will take the user selected image and load it to firebase
        let imageName = NSUUID().uuidString
        guard let username = self.nameTextField.text?.lowercased(),
            let confirmPassword = self.confirmPasswordTextField.text,
            let email = self.emailTextField.text,
            let password = self.passwordTextField.text,
            !username.isEmpty,
            !email.isEmpty,
            !password.isEmpty,
            !confirmPassword.isEmpty
            else {
                print("Required fields are not all filled!")
                return
        }
        if self.validateEmail(enteredEmail:email) != true{
            let alertController = UIAlertController(title: "Error", message: "Please Enter A Valid Email", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        // will make sure user is validated before it even tries to create user
        // will make sure the password and confirm password textfields have the same value if so it will print an error
        if self.passwordTextField.text != self.confirmPasswordTextField.text {
            let alertController = UIAlertController(title: "Error", message: "Passwords Don't Match", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        if selectedImageFromPicker == nil {
            let alertController = UIAlertController(title: "Error", message: "Select a Profile Picrue", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        //create a reference to the sotrage database in firebase
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).PNG")
        //following function does the work of putting it into firebase
        //notice I also set the value of profilepic oo it can be saved in the updated user instance in the database
        if let userImage = selectedImageFromPicker,let uploadData = UIImageJPEGRepresentation(userImage, 0.1){
            //will ensure that each user has a unique username
            AuthService.checkUserNameAlreadyExist(newUserName: username, completion: { [unowned self] (isUnique) in
                if isUnique {
                    //username exists so user has to try again
                    print("Login already exist")
                    self.showAlertThatLoginAlreadyExists()
                }else{
                    //username does not exist and will authenticate user
                    AuthService.createUser(controller: self, email: email, password: password) {[unowned self] (authUser) in
                        guard let firUser = authUser else{
                            return
                        }
                        storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error ?? "")
                                return
                            }
                            profilePic = (metadata?.downloadURL()!.absoluteString)!
                            //printing to make sure values are contained in these strings
                            print(profilePic)
                            print(username)
                            
                            UserService.create(firUser, username: username, profilePic: profilePic, completion: { [unowned self](user) in
                                guard let user = user else {
                                    print("User not loaded into firebase db")
                                    return
                                }
                                User.setCurrent(user, writeToUserDefaults: true)
                                // will set the current user for userdefaults to work
                                print(user.profilePic ?? "")
                                print(user.username ?? "")
                                // self.delegate?.finishSigningUp()
                                self.finishSigningUp()
                            })
                        })
                    }
                }
            })
        }
       // self.present(alertController, animated: true, completion: nil)

    }
    
    private func showAlertThatLoginAlreadyExists() {
        let alert = UIAlertController(title: "Registration failed!",
                                      message: "Username already exists.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func finishSigningUp() {
        print("Finish signing up from signup view controller")
        print("Attempting to return to root view controller")
        let homeController = HomeViewController()
        //should change the root view controller to the homecontroller when done signing up
        self.view.window?.rootViewController = homeController
        self.view.window?.makeKeyAndVisible()
    }
    
    
    // will validate email entry so user can not enter false text
    
    func validateEmail(enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }

    
    
    // will create a cancel button so users can go back to login screen if they actually want to log in
    // Buton setup as well as cancel will be in this code block
    let cancelButton : UIButton = {
        let cancel = UIButton()
        cancel.setTitle("Cancel", for: .normal)
        cancel.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        cancel.setTitleColor(.black, for: .normal)
        cancel.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return cancel
    }()
    
    @objc func handleCancel(){
        
        self.dismiss(animated: true, completion: nil)
    }

    // Will move the UI Up on login Screen when keyboard appears
    
    fileprivate func observeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    // will properly show keyboard
    @objc func keyboardWillShow(sender: NSNotification) {
        let keyboardInfo = sender.userInfo
        let keyboardFrameBegin = keyboardInfo?[UIKeyboardFrameEndUserInfoKey]
        let keyboardFrameBeginRect = (keyboardFrameBegin as! NSValue).cgRectValue
        let keyboardHeight = keyboardFrameBeginRect.size.height
        var extraPadding:CGFloat?
        if self.activeTextField != nil {
            let textBottom = self.activeTextField!.frame.origin.y + self.activeTextField!.bounds.size.height
            let totalHeight = self.scrollViewContent.bounds.size.height
            if totalHeight < (textBottom + keyboardHeight) {
                extraPadding = textBottom + keyboardHeight - totalHeight + 30.0
            }
        }
        DispatchQueue.main.async {
            if extraPadding != nil {
                self.contentScrollView.setContentOffset(CGPoint(x: 0, y: extraPadding!), animated: true)
            }
            self.bottomPadding.constant = keyboardHeight + 30.0
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // will properly hide keyboard
    @objc func keyboardWillHide(sender: NSNotification) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.bottomPadding.constant = 30.0
            })
        }
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.bgGradientLayer.frame = self.view.layer.bounds
//        self.view.layer.addSublayer(self.bgGradientLayer)
        view.backgroundColor = .white
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        let ref = Database.database().reference()
        geoFireRef = ref.child("userlocations")
        geoFire = GeoFire(firebaseRef: geoFireRef)
        view.addGestureRecognizer(tap)
        self.addScrollView()
        self.insertViewsInScrollView()
        self.addBottomMostItems()


    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.observeKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeKeyboardNotifications()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
    }
    
    
    //MARK:- View Builder
    fileprivate var contentScrollView:UIScrollView!
    fileprivate var scrollViewContent:UIView!
    fileprivate var bottomPadding:NSLayoutConstraint!
    fileprivate var activeTextField:UITextField?
    
    //creatas a UILabel
    let signInLabel: UILabel = {
        let signUp = UILabel()
        signUp.textColor = UIColor.black
        signUp.font = UIFont.boldSystemFont(ofSize: 13)
        signUp.text = "Already have an account?"
        return signUp
    }()
    
    //will create the signup button
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign in", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.setTitleColor(UIColor.rgb(red: 45, green: 162, blue: 232), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    fileprivate func addScrollView() {
        
        let pseudoView = UIView()
        pseudoView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pseudoView)
        NSLayoutConstraint.activateViewConstraints(pseudoView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.topLayoutGuide, secondView: pseudoView, andSeparation: 0.0)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: pseudoView, secondView: self.bottomLayoutGuide, andSeparation: 0.0)
        
        self.contentScrollView = UIScrollView()
        self.contentScrollView.translatesAutoresizingMaskIntoConstraints = false
        pseudoView.addSubview(self.contentScrollView)
        NSLayoutConstraint.activateViewConstraints(self.contentScrollView, inSuperView: pseudoView, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: 0.0)
        
        self.scrollViewContent = UIView()
        self.scrollViewContent.translatesAutoresizingMaskIntoConstraints = false
        self.contentScrollView.addSubview(self.scrollViewContent)
        NSLayoutConstraint.activateViewConstraints(self.scrollViewContent, inSuperView: self.contentScrollView, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: 0.0)
        _ = NSLayoutConstraint.activateEqualWidthConstraint(withView: self.scrollViewContent, referenceView: pseudoView)
        let cons = NSLayoutConstraint.addEqualHeightConstraint(withView: self.scrollViewContent, referenceView: pseudoView)
        cons.priority = UILayoutPriority.defaultLow
        NSLayoutConstraint.activate([cons])
    }
    
    fileprivate func insertViewsInScrollView() {
        self.plusPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        self.scrollViewContent.addSubview(self.plusPhotoButton)
        NSLayoutConstraint.activateViewConstraints(self.plusPhotoButton, inSuperView: self.scrollViewContent, withLeading: nil, trailing: nil, top: 50.0, bottom: nil, width: 140.0, height: 140.0)
        _ = NSLayoutConstraint.activateCentreXConstraint(withView: self.plusPhotoButton, superView: self.scrollViewContent)
        
        
        let textFieldHeight:CGFloat = 47.5
        
        self.nameTextField.translatesAutoresizingMaskIntoConstraints = false
        self.nameTextField.delegate = self
        self.scrollViewContent.addSubview(self.nameTextField)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.plusPhotoButton, secondView: self.nameTextField, andSeparation: 40.0)
        NSLayoutConstraint.activateViewConstraints(self.nameTextField, inSuperView: self.scrollViewContent, withLeading: 40.0, trailing: -40.0, top: nil, bottom: nil, width: nil, height: textFieldHeight)
        
        self.emailTextField.translatesAutoresizingMaskIntoConstraints = false
        self.emailTextField.delegate = self
        self.scrollViewContent.addSubview(self.emailTextField)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.nameTextField, secondView: self.emailTextField, andSeparation: 10.0)
        NSLayoutConstraint.activateViewConstraints(self.emailTextField, inSuperView: self.scrollViewContent, withLeading: 40.0, trailing: -40.0, top: nil, bottom: nil, width: nil, height: textFieldHeight)
        
        self.passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.passwordTextField.delegate = self
        self.scrollViewContent.addSubview(self.passwordTextField)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.emailTextField, secondView: self.passwordTextField, andSeparation: 10.0)
        NSLayoutConstraint.activateViewConstraints(self.passwordTextField, inSuperView: self.scrollViewContent, withLeading: 40.0, trailing: -40.0, top: nil, bottom: nil, width: nil, height: textFieldHeight)
        
        self.confirmPasswordTextField.translatesAutoresizingMaskIntoConstraints = false
        self.confirmPasswordTextField.delegate = self
        self.scrollViewContent.addSubview(self.confirmPasswordTextField)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.passwordTextField, secondView: self.confirmPasswordTextField, andSeparation: 10.0)
        NSLayoutConstraint.activateViewConstraints(self.confirmPasswordTextField, inSuperView: self.scrollViewContent, withLeading: 40.0, trailing: -40.0, top: nil, bottom: nil, width: nil, height: textFieldHeight)
        
        self.signupButton.translatesAutoresizingMaskIntoConstraints = false
        self.scrollViewContent.addSubview(self.signupButton)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.confirmPasswordTextField, secondView: self.signupButton, andSeparation: 20.0)
        NSLayoutConstraint.activateViewConstraints(self.signupButton, inSuperView: self.scrollViewContent, withLeading: 40.0, trailing: -40.0, top: nil, bottom: nil, width: nil, height: textFieldHeight)
        
        
    }
    
    fileprivate func addBottomMostItems() {
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.scrollViewContent.addSubview(bottomView)
        NSLayoutConstraint.activateViewConstraints(bottomView, inSuperView: self.scrollViewContent, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: 20.0)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.signupButton, secondView: bottomView, andSeparation: 10.0)
        
        let pseudoView1 = UIView()
        pseudoView1.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(pseudoView1)
        NSLayoutConstraint.activateViewConstraints(pseudoView1, inSuperView: bottomView, withLeading: 0.0, trailing: nil, top: 0.0, bottom: 0.0)
        
        self.signInLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(self.signInLabel)
        NSLayoutConstraint.activateViewConstraints(self.signInLabel, inSuperView: bottomView, withLeading: nil, trailing: nil, top: 0.0, bottom: 0.0)
        _ = NSLayoutConstraint.activateHorizontalSpacingConstraint(withFirstView: pseudoView1, secondView: self.signInLabel, andSeparation: 0.0)
        _ = NSLayoutConstraint.activateWidthConstraint(view: self.signInLabel, withWidth: 1.0, andRelation: .greaterThanOrEqual)
        
        self.signInButton.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(self.signInButton)
        NSLayoutConstraint.activateViewConstraints(self.signInButton, inSuperView: bottomView, withLeading: nil, trailing: nil, top: 0.0, bottom: 0.0)
        _ = NSLayoutConstraint.activateHorizontalSpacingConstraint(withFirstView: self.signInLabel, secondView: self.signInButton, andSeparation: 5.0)
        _ = NSLayoutConstraint.activateWidthConstraint(view: self.signInButton, withWidth: 1.0, andRelation: .greaterThanOrEqual)
        
        let pseudoView2 = UIView()
        pseudoView2.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(pseudoView2)
        NSLayoutConstraint.activateViewConstraints(pseudoView2, inSuperView: bottomView, withLeading: nil, trailing: 0.0, top: 0.0, bottom: 0.0)
        _ = NSLayoutConstraint.activateHorizontalSpacingConstraint(withFirstView: self.signInButton, secondView: pseudoView2, andSeparation: 0.0)
        _ = NSLayoutConstraint.activateEqualWidthConstraint(withView: pseudoView2, referenceView: pseudoView1)
        
        let pseudoView3 = UIView()
        pseudoView3.translatesAutoresizingMaskIntoConstraints = false
        self.scrollViewContent.addSubview(pseudoView3)
        NSLayoutConstraint.activateViewConstraints(pseudoView3, inSuperView: self.scrollViewContent, withLeading: 0.0, trailing: 0.0, top: nil, bottom: 0.0)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: bottomView, secondView: pseudoView3, andSeparation: 0.0)
        self.bottomPadding = NSLayoutConstraint.addHeightConstraint(view: pseudoView3, withHeight: 30.0)
        NSLayoutConstraint.activate([self.bottomPadding])
    }
    
}

extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}

