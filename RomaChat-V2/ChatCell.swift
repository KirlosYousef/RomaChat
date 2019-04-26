//
//  ChatCell.swift
//  RomaChat-V2
//
//  Created by Kirlos Yousef on 2019. 02. 23..
//  Copyright © 2019. Kirlos Yousef. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {
  @IBOutlet weak var usernameLabel: UILabel!
  @IBOutlet weak var chatTextView: UITextView!
  @IBOutlet weak var chatStack: UIStackView!
  @IBOutlet weak var chatTextBubble: UIView!
  
  enum bubbleType{
    case incoming
    case outgoing
  }
  
  override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    chatTextBubble.layer.cornerRadius = 6
    
    }

  func setMessageData(message: Message){
    usernameLabel.text = message.senderName
    chatTextView.text = message.text
    
  }
  
  func setBubbleType(type: bubbleType){
    if (type == .incoming){
      chatStack.alignment = .leading
      chatTextBubble.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
      chatTextView.textColor = .black
    } else if (type == .outgoing){
      chatStack.alignment = .trailing
      chatTextBubble.backgroundColor = #colorLiteral(red: 0.2058265507, green: 0.7433094382, blue: 0.8982071877, alpha: 1)
      chatTextView.textColor = .white
    }
  }
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
