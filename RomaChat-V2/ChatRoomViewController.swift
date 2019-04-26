//
//  ChatRoomViewController.swift
//  RomaChat-V2
//
//  Created by Kirlos Yousef on 2019. 02. 08..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import UIKit
import Firebase

class ChatRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  @IBOutlet weak var chatTextField: UITextField!
  var room:Room?
  @IBOutlet weak var keyboardHeightLayoutConstraint: NSLayoutConstraint!
  @IBOutlet weak var chatTableView: UITableView!
  var chatMessages = [Message]()

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    chatTableView.delegate = self
    chatTableView.dataSource = self
    
    title = room?.roomName
      
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWasShown(notification:)),
      name: UIResponder.keyboardDidShowNotification, object: nil)
    
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.keyboardWasHidden(notification:)),
      name: UIResponder.keyboardWillHideNotification, object: nil)
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
    self.view.addGestureRecognizer(tapGesture)
    
    chatTableView.separatorStyle = .none
    chatTableView.allowsSelection = false
    observeMessages()
  }
  
  func observeMessages(){
    guard let roomId = self.room?.roomID else { return }
    
    let databaseRef = Database.database().reference()
    databaseRef.child("rooms").child(roomId).child("messages").observe(.childAdded) { (snapshot) in
      if let dataArray = snapshot.value as? [String: Any] {
        guard let senderName = dataArray["senderName"] as? String, let messageText = dataArray["text"] as? String, let userId = dataArray["senderId"] as? String else {
          return
        }
        let message = Message.init(key: snapshot.key, senderName: senderName, text: messageText, userId: userId)
        self.chatMessages.append(message)
        self.chatTableView.reloadData()
      }
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = chatTableView.dequeueReusableCell(withIdentifier: "chatCell") as! ChatCell
    
    let message = self.chatMessages[indexPath.row]
    cell.setMessageData(message: message)

    if (message.userId == Auth.auth().currentUser?.uid){
      cell.setBubbleType(type: .outgoing)
    } else {
      cell.setBubbleType(type: .incoming)
    }
    return cell
  }
  
  /////////
  @objc func dismissKeyboard(_ sender: UIGestureRecognizer){
    self.view.endEditing(true)
  }
  
  @objc func keyboardWasHidden(notification: NSNotification){
    UIView.animate(withDuration: 0.1, animations: { () -> Void in
      self.keyboardHeightLayoutConstraint.constant = 0
    })
  }
  
  @objc func keyboardWasShown(notification: NSNotification) {
    let info = notification.userInfo!
    let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
    
    UIView.animate(withDuration: 0.1, animations: { () -> Void in
      self.keyboardHeightLayoutConstraint.constant = keyboardFrame.size.height - 25
      
      self.view.layoutIfNeeded()
    })
  }
  
  func getUsernameWithID(id: String, completion: @escaping (_ userName: String?) -> ()){
    let databaseRef = Database.database().reference()
    let user = databaseRef.child("users").child(id)
    
    user.child("username").observeSingleEvent(of: .value) { (snapshot) in
      if let userName =  snapshot.value as? String {
        completion(userName)
      } else {
        completion(nil)
      }
    }
  }
  
  
  func sendMessage(text: String, completion: @escaping (_ isSuccess: Bool) -> ()){
    guard let userID = Auth.auth().currentUser?.uid else {
      return
    }
    let databaseRef = Database.database().reference()
    
    getUsernameWithID(id: userID) { (userName) in
      if let userName = userName{
      if let roomID = self.room?.roomID, let userId = Auth.auth().currentUser?.uid{
      
        let dataAraay: [String:Any] = ["senderName": userName, "text": text, "senderId": userId]
        let room = databaseRef.child("rooms").child(roomID)
        room.child("messages").childByAutoId().setValue(dataAraay, withCompletionBlock: { (error, ref) in
          if (error == nil){
            completion(true)
            //              self.chatTextField.text = ""
            //              print("Room Added to database successfuly")
          } else {
            completion(false)
          }
        })
        
      }
    }
  }
}



@IBAction func didPressSendButton(_ sender: UIButton) {
  guard let chatText = self.chatTextField.text, chatText.isEmpty == false else {
    return
  }
  sendMessage(text: chatText) { (isSuccess) in
    if (isSuccess){
      self.chatTextField.text = ""
    }
  }
}

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.chatMessages.count
  }

  
}
