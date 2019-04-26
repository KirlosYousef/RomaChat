//
//  RoomsViewController.swift
//  RomaChat-V2
//
//  Created by Kirlos Yousef on 2019. 02. 06..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import UIKit
import Firebase

class RoomsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
	
	@IBOutlet weak var roomsTable: UITableView!
	@IBOutlet weak var newRoomTextField: UITextField!
  @IBOutlet weak var newRoomPasswordTextField: UITextField!
  var rooms = [Room]()
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
	@IBAction func didPressLogout(_ sender: UIBarButtonItem) {
		try! Auth.auth().signOut()
		self.presentLoginScreen()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.roomsTable.delegate = self
		self.roomsTable.dataSource = self
		observeRooms()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
    self.roomsTable.addGestureRecognizer(tapGesture)
	}
	
  @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
    self.newRoomPasswordTextField.resignFirstResponder()
    self.newRoomTextField.resignFirstResponder()
    sender.cancelsTouchesInView = false
  }
  
	func observeRooms() {
		let databaseRef = Database.database().reference()
		databaseRef.child("rooms").observe(.childAdded) { (snapshot) in
			if let dataArray = snapshot.value as? [String: Any] {
				if let roomName = dataArray["roomName"] as? String {
          let password = dataArray["password"] as? String 
          let room = Room.init(roomID: snapshot.key, roomName: roomName, password: password)
					self.rooms.append(room)
          self.roomsTable.reloadData()
          
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let room = self.rooms[indexPath.row]
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "roomCell")!
		cell.textLabel?.text = room.roomName
		return cell
	}
	
	
	@IBAction func didPressCreateNewRoom(_ sender: UIButton) {
		guard let roomName = self.newRoomTextField.text, roomName.isEmpty == false else {
			return
		}
		let databaseRef = Database.database().reference()
		let room = databaseRef.child("rooms").childByAutoId()
		let password = self.newRoomPasswordTextField.text!
    let dataArray:[String: Any] = ["roomName": roomName, "password": password]
		room.setValue(dataArray) { (error, ref) in
			if (error == nil){
				self.newRoomTextField.text = ""
        self.newRoomPasswordTextField.text = ""
			}
		}
    self.view.endEditing(true)
	}
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let selectedRoom = self.rooms[indexPath.row]
    let chatRoomView = self.storyboard?.instantiateViewController(withIdentifier: "chatRoom") as! ChatRoomViewController
    
    if (selectedRoom.password != ""){
      let alert = UIAlertController.init(title: "Password", message: "Please enter the room password!", preferredStyle: .alert)
      let wrongPassword = UIAlertController.init(title: "Wrong!", message: "You entered a wrong password!", preferredStyle: .alert)
      let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: {(alert: UIAlertAction!) in self.viewWillAppear(true)})
      
      alert.addTextField { (passwordTextField) in
        passwordTextField.placeholder = "Enter the password..."
        passwordTextField.isSecureTextEntry = true
      }
      
      
      alert.addAction(cancelAction)
      self.present(alert, animated: true)
      let okAction = UIAlertAction.init(title: "Ok", style: .default) { (enterPasswordAction) in
        let passwordFieldEntered = alert.textFields![0]
        if  passwordFieldEntered.text == selectedRoom.password {
          chatRoomView.room = selectedRoom
          self.navigationController?.pushViewController(chatRoomView, animated: true)
        } else {
          wrongPassword.addAction(cancelAction)
          self.present(wrongPassword, animated: true)
        }

      }
      alert.addAction(okAction)

    } else {
    chatRoomView.room = selectedRoom
    self.navigationController?.pushViewController(chatRoomView, animated: true)
    }
  }
	
	override func viewDidAppear(_ animated: Bool) {
		if (Auth.auth().currentUser == nil){
			self.presentLoginScreen()
		}
	}
  
  override func viewWillAppear(_ animated: Bool) {
    if let index = self.roomsTable.indexPathForSelectedRow {
        self.roomsTable.deselectRow(at: index, animated: true)
      
    }
  }
	
	func presentLoginScreen(){
		let formScreen = self.storyboard?.instantiateViewController(withIdentifier: "LoginScreen") as! ViewController
		self.present(formScreen, animated: true)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.rooms.count
	}
  
}
