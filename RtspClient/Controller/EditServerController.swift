//
//  EditController.swift
//  RtspClient
//
//  Created by hkuit155 on 18/2/2021.
//  Copyright © 2021 Andres Rojas. All rights reserved.
//

import UIKit

class EditServerController: UIViewController {

    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var serverIP: UITextField!
    @IBOutlet weak var serverPort: UITextField!
    
    var serverIPData: String = ""
    var serverPortData: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serverIP.delegate = self
        serverPort.delegate = self
        serverIP.text = serverIPData
        serverPort.text = serverPortData
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EditServerSave") {
            self.serverIPData = self.serverIP.text ?? ""
            self.serverPortData = self.serverPort.text ?? ""
        }
    }

}

extension EditServerController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveBtn.isEnabled = false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveBtn.isEnabled = true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // User finished typing (hit return): hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
} // UITextFieldDelegate
