//
//  LoginViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 7/24/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Foundation
import SVProgressHUD
import TextFieldEffects

protocol LoginViewControllerDelegate: class {
    func finishLoggingIn()
}



class LoginViewController: UIViewController , LoginViewControllerDelegate {
    //Login Controller Instance
   // var loginController: LoginViewController?
    weak var delegate : LoginViewControllerDelegate?
    let signUpTransition = SignUpViewController()
    let forgotPasswordTransition = ForgotPasswordViewController()

    lazy var logoImageView: CustomImageView = {
        let iv = CustomImageView()
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "logoWithWords")
        return iv
    }()
    
    
    // creates a UITextField
    
    let emailTextField : HoshiTextField = {
        let textField = HoshiTextField()
//        textField.placeholderColor = UIColor.logoColor
        textField.placeholderColor = UIColor.black
        textField.placeholder = "Email"
        textField.placeholderLabel.font = UIFont(name: "Futura", size: 14)
        textField.placeholderFontScale = 0.85
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.borderStyle = .none
        textField.borderInactiveColor = UIColor.black
        textField.borderActiveColor = UIColor.black
        textField.textColor = .black
        return textField
    }()

    // creates a UITextField
    let passwordTextField : HoshiTextField = {
        let textField = HoshiTextField()
//        textField.placeholderColor = UIColor.logoColor
        textField.placeholderColor = UIColor.black
        textField.placeholder = "Password"
        textField.placeholderFontScale = 0.85
        textField.placeholderLabel.font = UIFont(name: "Futura", size: 14)
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 0
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.borderStyle = .none
        textField.borderInactiveColor = UIColor.black
        textField.borderActiveColor = UIColor.black
        textField.textColor = .black
        return textField
    }()
    // creates a UIButton and transitions to a different screen after button is selected
    
    lazy var loginButton: UIButton  = {
        let button = UIButton(type: .system)
        button.setTitle("LOGIN", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "Futura", size: 14)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.backgroundColor = UIColor.rgb(red: 44, green: 152, blue: 229)
        return button
    }()
    
    @objc func handleLogin(){
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and a a password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            SVProgressHUD.show(withStatus: "Logging in...")
            AuthService.signIn(controller: self, email: emailTextField.text!, password: passwordTextField.text!) { [unowned self] (user) in
                guard user != nil else {
                    // look back here
           
                    print("error: FiRuser dees not exist")
                    return
                }
              //  print("user is signed in")
                UserService.show(forUID: (user?.uid)!) {[unowned self] (user) in
                    if let user = user {
                        User.setCurrent(user, writeToUserDefaults: true)
                        self.finishLoggingIn()
                }
                    else {
                        print("error: User does not exist!")
                        return
                    }
                }
            }
        }

    }
    
    func finishLoggingIn() {
       // print("Finish logging in from LoginController")
        let homeController = HomeViewController()
        self.view.window?.rootViewController = homeController
        self.view.window?.makeKeyAndVisible()
    }
    
    //creatas a UILabel
    let signUpLabel: UILabel = {
        let signUp = UILabel()
        signUp.text = "Don't Have An Account?"
        signUp.textColor = UIColor.black
        signUp.font = UIFont(name: "Futura", size: 13)
        return signUp
    }()
    
    //will create the signup button
    let signUpButton: UIButton = {
        let signUpButton = UIButton(type: .system)
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font = UIFont(name: "Futura", size: 13)
        signUpButton.setTitleColor(UIColor.rgb(red: 45, green: 162, blue: 232), for: .normal)
        signUpButton.addTarget(self, action: #selector(handleSignUpTransition), for: .touchUpInside)
        return signUpButton
    }()
    

    lazy var forgotPasswordButton: UIButton = {
        let forgotPasswordButton = UIButton(type: .system)
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        forgotPasswordButton.setTitleColor(UIColor.black, for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(handleForgotPasswordTransition), for: .touchUpInside)
        return forgotPasswordButton
    }()
    
    override func viewDidLoad() {
        // Every view that I add is from the top down imagine a chandeler that you are just hanging things from
        print("app begun")
        super.viewDidLoad()
        // will add each of the screen elements to the current view
        self.view.backgroundColor = UIColor.white

        
       // self.view.backgroundColor = UIColor(r: 255, g: 255 , b: 255)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        self.view.addGestureRecognizer(tap)
        setupLoginScreen()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.observeKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObserveKeyboardNotifications()
    }
    
    var stackView: UIStackView?
    fileprivate func setupLoginScreen(){
        self.view.addSubview(logoImageView)
        logoImageView.anchor(top: view.safeTopAnchor, left: view.safeLeftAnchor, bottom: nil, right: view.safeRightAnchor, paddingTop: view.bounds.height / 5, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 0)
       
        stackView = UIStackView(arrangedSubviews: [ emailTextField, passwordTextField,loginButton])
        self.view.addSubview(stackView!)
        stackView?.distribution = .fillEqually
        stackView?.axis = .vertical
        stackView?.spacing = 15.0
        stackView?.anchor(top: logoImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 50, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 152)
        self.addBottomMostItems()
        self.addForgotPasswordItem()
        NotificationCenter.default.post(name: heartAttackNotificationName, object: nil)
    }
    fileprivate func addForgotPasswordItem(){
        let midView = UIView()
        midView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(midView)
        NSLayoutConstraint.activateViewConstraints(midView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: 20.0)
                _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: self.loginButton, secondView:midView , andSeparation: 9.0)
        midView.addSubview(self.forgotPasswordButton)
        self.forgotPasswordButton.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activateViewConstraints(self.forgotPasswordButton, inSuperView: midView, withLeading: 6.0, trailing: 6.0, top: 0.0, bottom: 0.0)

        
    }
    
    fileprivate func addBottomMostItems() {
        //UIView that explicitly contains the label and button for signing up a user that is placed at the bottom
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(bottomView)
        NSLayoutConstraint.activateViewConstraints(bottomView, inSuperView: self.view, withLeading: 0.0, trailing: 0.0, top: nil, bottom: nil, width: nil, height: 20.0)
        _ = NSLayoutConstraint.activateVerticalSpacingConstraint(withFirstView: bottomView, secondView: self.bottomLayoutGuide, andSeparation: 10.0)
        
        let pseudoView1 = UIView()
        pseudoView1.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(pseudoView1)
        NSLayoutConstraint.activateViewConstraints(pseudoView1, inSuperView: bottomView, withLeading: 0.0, trailing: nil, top: 0.0, bottom: 0.0)
        
        self.signUpLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(self.signUpLabel)
        NSLayoutConstraint.activateViewConstraints(self.signUpLabel, inSuperView: bottomView, withLeading: nil, trailing: nil, top: 0.0, bottom: 0.0)
        _ = NSLayoutConstraint.activateHorizontalSpacingConstraint(withFirstView: pseudoView1, secondView: self.signUpLabel, andSeparation: 0.0)
        _ = NSLayoutConstraint.activateWidthConstraint(view: self.signUpLabel, withWidth: 1.0, andRelation: .greaterThanOrEqual)
        
        self.signUpButton.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(self.signUpButton)
        NSLayoutConstraint.activateViewConstraints(self.signUpButton, inSuperView: bottomView, withLeading: nil, trailing: nil, top: 0.0, bottom: 0.0)
        _ = NSLayoutConstraint.activateHorizontalSpacingConstraint(withFirstView: self.signUpLabel, secondView: self.signUpButton, andSeparation: 5.0)
        _ = NSLayoutConstraint.activateWidthConstraint(view: self.signUpButton, withWidth: 1.0, andRelation: .greaterThanOrEqual)
        
        let pseudoView2 = UIView()
        pseudoView2.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addSubview(pseudoView2)
        NSLayoutConstraint.activateViewConstraints(pseudoView2, inSuperView: bottomView, withLeading: nil, trailing: 0.0, top: 0.0, bottom: 0.0)
        _ = NSLayoutConstraint.activateHorizontalSpacingConstraint(withFirstView: self.signUpButton, secondView: pseudoView2, andSeparation: 0.0)
        _ = NSLayoutConstraint.activateEqualWidthConstraint(withView: pseudoView2, referenceView: pseudoView1)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.view.endEditing(true)
    }
    
    //will open a new ViewController when forgot password button is pressed
    @objc func handleForgotPasswordTransition(){
        print("forgot password tapped")
        present(self.forgotPasswordTransition, animated: true, completion: nil)
    }
    
    // will open a new ViewController When login button is selected
    @objc func handleSignUpTransition(){
        present(self.signUpTransition, animated: true, completion: nil)
    }
    
    // Will move the UI Up on login Screen when keyboard appears
    
    fileprivate func  observeKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    fileprivate func  removeObserveKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            UIView.animate(withDuration: 0.2, animations: {
                self.view.frame.origin.y = -keyboardHeight
            })
        }
    }
    
    
    // will properly hide keyboard
    @objc func keyboardWillHide(sender: NSNotification) {
        UIView.animate(withDuration: 0.2, animations: {
            self.view.frame.origin.y = 0
        })
    }
    
}


extension UIColor{
    convenience init(r: CGFloat, g: CGFloat, b:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}


class LeftPaddedTextField: UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 12, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
    
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: bounds.origin.x + 12, y: bounds.origin.y, width: bounds.width + 10, height: bounds.height)
    }
}


