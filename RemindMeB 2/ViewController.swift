//
//  ViewController.swift
//  RemindMeB 2
//
//  Created by Prem on 10/15/17.
//  Copyright © 2017 Prem Bhanderi. All rights reserved.
//

import UIKit

//Global Array
var remindersText = [[String]]()
//var subjectsText = [String]()

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var connectionsLabel: UILabel!
    @IBOutlet weak var inputMessages: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var sentMessages: UITextView!
    @IBOutlet weak var remindersTableView: UITableView!
    @IBOutlet weak var subjectTableView: UITableView!
    @IBOutlet weak var inputReminder: UITextField!
    @IBOutlet weak var inputSubject: UITextField!
    
    
    let messageSend = ConnectMe()
    var packet = String()
    var selectedReminder = Int()
    var selectedSubject = Int()
    var maxSubjects = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedSubject = 0
        selectedReminder = 0
        maxSubjects = 0
        
        messageSend.delegate = self
        
        remindersTableView.dataSource = self
        remindersTableView.delegate = self
        remindersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        subjectTableView.dataSource = self
        subjectTableView.delegate = self
        subjectTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell1")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //Test message sender between 2 devices via MultiPeerConnectivity
    @IBAction func btnSend(_ sender: UIButton) {
        packet = inputMessages.text!
        messageSend.send(messageS: "0" + packet)
        inputMessages.text = ""
    }
    
    //Adds a reminder and reloads the table view
    @IBAction func btnAddReminder(_ sender: UIButton) {
        if inputReminder.text != ""{
            remindersText[selectedSubject].append(inputReminder.text!)//NEW STUFF
            inputReminder.text = ""
            remindersTableView.reloadData()
        }
    }
    
    @IBAction func btnEditReminder(_ sender: UIButton) {
        //remindersText[selectedReminder] = inputReminder.text!******************
        inputReminder.text = ""
        remindersTableView.reloadData()
    }
    
    @IBAction func btnAddSubject(_ sender: UIButton) {
        remindersText.append([""])
        remindersText[maxSubjects][0] = inputSubject.text!
        maxSubjects = maxSubjects + 1
        //remindersText[selectedSubject].append(inputSubject.text!)
        inputSubject.text = ""
        subjectTableView.reloadData()
    }
    
    //TableView Stuff HERE
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return remindersText.count
    }
    
    //Cell creation
    @available(iOS 2.0, *)
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        var cell:UITableViewCell?
        
        if tableView == self.remindersTableView{
            print("REMINDERS COUNT: ")
            print(remindersText.count)
            print("REMINDERS SELECTED SUBJECT COUNT: ")
            print(remindersText[selectedSubject].count)
            print("INDEX PATH: ")
            print(indexPath.row)
            if indexPath.row <= (remindersText[selectedSubject].count)-1{//HERE!!!!!!!
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
                cell?.textLabel?.text = remindersText[selectedSubject][indexPath.row]
            }
        }
        
        if tableView == self.subjectTableView{
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell1")
            cell?.textLabel?.text = remindersText[indexPath.row][0]
        }
        
        return cell!
    }
    
    //Called when you delete a row from reminders
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if tableView == self.remindersTableView{
            if editingStyle == UITableViewCellEditingStyle.delete{
                remindersText.remove(at: indexPath.row)
                remindersTableView.reloadData()
            }
        }
        
        if tableView == self.subjectTableView{
            if editingStyle == UITableViewCellEditingStyle.delete{
                //subjectsText.remove(at: indexPath.row)
                remindersText.remove(at: indexPath.row)
                subjectTableView.reloadData()
                remindersTableView.reloadData()
            }
        }
    }
    
    // Called after the user changes the selection.
    @available(iOS 2.0, *)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if tableView == self.remindersTableView{
            selectedReminder = indexPath.row
        }
        if tableView == self.subjectTableView{
            selectedSubject = indexPath.row
        }
        
        //inputReminder.text = remindersText[indexPath.row]******************
    }
    
}

//Connection Extension
extension ViewController : ConnectMeDelegate {
    func connectedDevicesChanged(manager: ConnectMe, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionsLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func messageSent(manager: ConnectMe, messageR: String) {
        OperationQueue.main.addOperation {
            if(String(messageR.substring(index: 0, length: 1))=="0"){
                self.sentMessages.text = self.sentMessages.text + "\n" + messageR.substring(left: 1, right: messageR.length)
            }
        }
    }
}

//String: Substring extension
extension String {
    
    /// the length of the string
    var length: Int {
        return self.characters.count
    }
    
    /// Get substring, e.g. "ABCDE".substring(index: 2, length: 3) -> "CDE"
    ///
    /// - parameter index:  the start index
    /// - parameter length: the length of the substring
    ///
    /// - returns: the substring
    public func substring(index: Int, length: Int) -> String {
        if self.length <= index {
            return ""
        }
        let leftIndex = self.index(self.startIndex, offsetBy: index)
        if self.length <= index + length {
            return self.substring(from: leftIndex)
        }
        let rightIndex = self.index(self.endIndex, offsetBy: -(self.length - index - length))
        return self.substring(with: leftIndex..<rightIndex)
    }
    
    /// Get substring, e.g. -> "ABCDE".substring(left: 0, right: 2) -> "ABC"
    ///
    /// - parameter left:  the start index
    /// - parameter right: the end index
    ///
    /// - returns: the substring
    public func substring(left: Int, right: Int) -> String {
        if length <= left {
            return ""
        }
        let leftIndex = self.index(self.startIndex, offsetBy: left)
        if length <= right {
            return self.substring(from: leftIndex)
        }
        else {
            let rightIndex = self.index(self.endIndex, offsetBy: -self.length + right + 1)
            return self.substring(with: leftIndex..<rightIndex)
        }
    }
}
