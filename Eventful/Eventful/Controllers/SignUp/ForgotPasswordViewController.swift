//
//  ForgotPasswordViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 1/30/18.
//  Copyright © 2018 Make School. All rights reserved.
//

import UIKit
import TextFieldEffects

class ForgotPasswordViewController: UIViewController {
    fileprivate var contentScrollView:UIScrollView!
    fileprivate var scrollViewContent:UIView!
    fileprivate var bottomPadding:NSLayoutConstraint!
    fileprivate var activeTextField:UITextField?
    var stackView: UIStackView?
    var instructionsStackVIew: UIStackView?
    
    let forgotPasswordLabel: UILabel = {
        let  forgotPassword = UILabel()
         forgotPassword.textColor = .black
        let myString = "Forgot Password?"
        let myAttribute = [NSAttributedStringKey.font:UIFont(name: "Times New Roman", size: 30)!]
        let myAttrString = NSAttributedString(string: myString, attributes: myAttribute)
         forgotPassword.attributedText = myAttrString
        return forgotPassword
        
    }()
    
    let instructionsLabel: UILabel = {
        let  instructionsLabel = UILabel()
        instructionsLabel.textColor = .black
        instructionsLabel.numberOfLines = 0
        instructionsLabel.text = "Enter your email"
        instructionsLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
        return instructionsLabel
        
    }()
    
    // creates a email UITextField to hold the email
    let emailTextField : HoshiTextField = {
        let emaiilText = HoshiTextField()
        emaiilText.placeholderColor = .black
        emaiilText.placeholder = "Email"
        emaiilText.placeholderFontScale = 0.85
        emaiilText.layer.borderColor = UIColor.lightGray.cgColor
        emaiilText.layer.borderWidth = 0
        emaiilText.borderInactiveColor = .black
        emaiilText.borderActiveColor = .black
        emaiilText.textColor = .black
        return emaiilText
    }()
    
    // creates a UIButton that will sign up the user
    let sendResetEmail: UIButton  = {
        let button = UIButton(type: .system)
        button.setTitle("Send Reset Link", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.regular)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(resetPassword), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(red: 45, green: 162, blue: 232)
        return button
    }()
    
    //will create the signup button
    let signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reurn to Login Screen", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.setTitleColor(UIColor.black, for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    @objc func handleCancel(){
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func resetPassword(){
        print("reset password tapped")
        if let email = emailTextField.text {
            print("User email is \(email)")
            AuthService.resetUserPassword(controller: self, for: email, completion: { [unowned self] (completed) in
                if completed {
                    let succesAlert = UIAlertController(title: "Password reset processed", message:
                        "Check email for further instructions", preferredStyle: UIAlertControllerStyle.alert)
                    succesAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { (alertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(succesAlert, animated: true, completion: nil)
                }else{
                    let failureAlert = UIAlertController(title: "We seem to be having some network errors at the moment", message:
                        "Try back later", preferredStyle: UIAlertControllerStyle.alert)
                    failureAlert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default,handler: nil))
                    self.present(failureAlert, animated: true, completion: nil)
                }
            })
        }
        
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
    @objc func setupForgotPasswordLabel(){
        instructionsStackVIew =  UIStackView(arrangedSubviews: [instructionsLabel])
        self.view.addSubview(instructionsStackVIew!)
        instructionsStackVIew?.distribution = .fillEqually
        instructionsStackVIew?.axis = .vertical
        instructionsStackVIew?.alignment = .center
        instructionsStackVIew?.spacing = 0
         instructionsStackVIew?.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 10, paddingLeft: 70, paddingBottom: 0, paddingRight: 70, width: 0, height: 80)
        
    }
    @objc func setupForgotPasswordScreen(){
        
        stackView = UIStackView(arrangedSubviews: [ emailTextField, sendResetEmail])
         self.view.addSubview(stackView!)
        stackView?.distribution = .fillEqually
        stackView?.axis = .vertical
        stackView?.spacing = 15.0
        stackView?.anchor(top: self.instructionsStackVIew?.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 200, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 100)
        
    }
    
    @objc func setupReturnToLogin(){
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bottomView)
        NSLayoutConstraint.activateViewConstraints(bottomView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: 20.0)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: bottomView, secondView: view.safeAreaLayoutGuide.bottomAnchor, andSeparation: 10.0)
        
        bottomView.addSubview(self.signInButton)
        self.signInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activateViewConstraints(self.signInButton, inSuperView: bottomView, withLeading: 0.0, trailing: 0.0, top: 0.0, bottom: 0.0)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ForgotPasswordViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        self.setupForgotPasswordLabel()
        self.setupForgotPasswordScreen()
        self.setupReturnToLogin()
        self.view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
}
