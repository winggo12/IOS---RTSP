//
//  EditCamViewController.swift
//  RtspClient
//
//  Created by hkuit155 on 19/2/2021.
//  Copyright © 2021 Andres Rojas. All rights reserved.
//

import UIKit

class EditCamViewController: UIViewController {
    
    @IBOutlet weak var saveBtn: UIBarButtonItem!
    @IBOutlet weak var cam1Address: UITextField!
    @IBOutlet weak var cam2Address: UITextField!
    @IBOutlet weak var cam3Address: UITextField!
    @IBOutlet weak var cam4Address: UITextField!
    
    var addressList: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cam1Address.delegate = self
        cam2Address.delegate = self
        cam3Address.delegate = self
        cam4Address.delegate = self
        assignAddress()
    }
    
    func assignAddress() {
        let camList: [UITextField] = [cam1Address, cam2Address, cam3Address, cam4Address]
        for index in 0..<addressList.count {
            camList[index].text = addressList[index]
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let camList: [UITextField] = [cam1Address, cam2Address, cam3Address, cam4Address]
        var tempList: [String] = []
        if (segue.identifier == "EditCamSave") {
            for index in 0..<4 {
                tempList.append(camList[index].text ?? "")
            }
            addressList = tempList
        }
    }
    
}

extension EditCamViewController: UITextFieldDelegate {
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
