//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // Declare instance variables here
    var messageArray = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self
        
        
        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessages()
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.avatarImageView.image = UIImage(named: "egg")
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    // Called AUTOMATICALLY when you start interacting with the UITextField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50 + 258 // Height of keyboard is always constant 258
            self.view.layoutIfNeeded() // Update the change in constraint (REQUIRED)
        }
        
        
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    // Need to be called MANUALLY
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        
        //TODO: Send the message to Firebase and save it in our database
        
        // Disable the text field and send button in order to prevent duplicate data when the user repeatedly click send when the async task (i.e. saving data to the firebase is still taking its time)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = Database.database().reference().child("Messages")
        
        let messageDictionary = ["sender": Auth.auth().currentUser?.email,
                                 "messageBody": messageTextfield.text!]
        
        messagesDB.childByAutoId().setValue(messageDictionary) { (error, reference) in
            if error != nil {
                print(error!)
            } else {
                print("Message saved successfully")
                
                self.messageTextfield.text = ""
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
            }
        }
        
        
        
        
    }
    
    //TODO: Create the retrieveMessages method here:
    func retrieveMessages() {
        
        let messagesDB = Database.database().reference().child("Messages")
        
        // Observer (.childAdded) that works asynchronously when a new entry is added to the database (it is more efficient because it is not grabbing the ENTIRE data every time a new entry is added. However, it only gets triggered when a new entry in the database is added)
        
        // snapshot is the new data retrieved from the database
        messagesDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            
            self.messageArray.append(Message(sender: snapshotValue["sender"]!, messageBody: snapshotValue["messageBody"]!))
            
            self.configureTableView()
            self.messageTableView.reloadData()
            SVProgressHUD.dismiss()
        }
        
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        //TODO: Log out the user and send them back to WelcomeViewController
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error loggin out")
        }
        
        
    }
    


}
