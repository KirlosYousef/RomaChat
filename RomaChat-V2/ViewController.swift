//
//  ViewController.swift
//  RomaChat-V2
//
//  Created by Kirlos Yousef on 2019. 02. 01..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var mainView: UIView!
  @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
    self.view.addGestureRecognizer(tapGesture)
    
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWasShown(notification:)),
      name: UIResponder.keyboardDidShowNotification, object: nil)
    
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWasHidden(notification:)),
      name: UIResponder.keyboardWillHideNotification, object: nil)
  }
  
  /////////
  
  @objc func keyboardWasShown(notification: NSNotification) {
    UIView.animate(withDuration: 0.5, animations: { () -> Void in
      self.keyboardHeightLayoutConstraint.constant = -195
      
      self.view.layoutIfNeeded()
    })
  }
  @objc func keyboardWasHidden(notification: NSNotification) {
    UIView.animate(withDuration: 1, animations: { () -> Void in
      self.keyboardHeightLayoutConstraint.constant = 0
      
      self.view.layoutIfNeeded()
    })
  }
  @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
   self.view.endEditing(true) //.resignFirstResponder()
    
  }
  
  ////////
  
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "formCell", for: indexPath) as! FormCell
    if (indexPath.row == 0) { // Sign in cell
      cell.userNameContainer.isHidden = true
      cell.actionButton.setTitle("Login", for: .normal)
      cell.slideButton.setTitle("Sign Up 👉", for: .normal)
      cell.slideButton.addTarget(self, action: #selector(slideToCell(_:)), for: .touchUpInside)
      cell.actionButton.addTarget(self, action: #selector(didpressSignIn(_:)), for: .touchUpInside)
    } else if(indexPath.row == 1) { // Sign up cell
      cell.userNameContainer.isHidden = false
      cell.actionButton.setTitle("Sign Up", for: .normal)
      cell.slideButton.setTitle("👈 Sign In", for: .normal)
      cell.slideButton.addTarget(self, action: #selector(slideToSignUp(_:)), for: .touchUpInside)
      
      cell.actionButton.addTarget(self, action: #selector(didPressSignUp(_:)), for: .touchUpInside)
    }
    
    return cell
  }
  
  @objc func didpressSignIn(_ sender: UIButton){
    let indexPath = IndexPath(row: 0, section: 0)
    let cell = self.collectionView.cellForItem(at: indexPath) as! FormCell
    guard let emailAddress = cell.emailAddressTextField.text,
      let password = cell.passwordTextField.text else {
        return
    }
    if (emailAddress.isEmpty == true || password.isEmpty == true){
      self.displayError(errorText: "Please fill empty fields!")
    } else {
      Auth.auth().signIn(withEmail: emailAddress, password: password) { (result, error) in
        if(error == nil){
          self.dismiss(animated: true, completion: nil)
        } else {
          self.displayError(errorText: "Wrong username or password")
        }
      }
    }
  }
  func displayError(errorText: String){
    let alert = UIAlertController.init(title: "Error", message: errorText, preferredStyle: .alert)
    
    let dismissButton = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
    
    alert.addAction(dismissButton)
    
    self.present(alert ,animated: true, completion: nil)
  }
  
  
  @objc func didPressSignUp(_ sender: UIButton){
    let indexPath = IndexPath(row: 1, section: 0)
    let cell = self.collectionView.cellForItem(at: indexPath) as! FormCell
    guard let emailAddress = cell.emailAddressTextField.text,
      let password = cell.passwordTextField.text,
      let username = cell.userNameTextField.text
      else {
        return
    }
    if (emailAddress.isEmpty == true || password.isEmpty == true || username.isEmpty == true){
      self.displayError(errorText: "Please fill empty fields!")
    } else {
      Auth.auth().createUser(withEmail: emailAddress, password: password) { (result, error) in
        if (error == nil ){
          guard let userID = result?.user.uid
            else {
              return
          }
          self.dismiss(animated: true, completion: nil)
          let reference = Database.database().reference()
          let user = reference.child("users").child(userID)
          let dataArray:[String: Any] = ["username": username]
          user.setValue(dataArray)
          
        }
      }
    }
  }
  
  @objc func slideToCell(_ sender: UIButton) {
    let indexPath = IndexPath(row: 1, section: 0)
    self.collectionView.scrollToItem(at: indexPath, at: [.centeredHorizontally], animated: true)
  }
  
  @objc func slideToSignUp(_ sender: UIButton){
    let indexPath = IndexPath(row: 0, section: 0)
    collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 2
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return collectionView.frame.size
  }
  
}

