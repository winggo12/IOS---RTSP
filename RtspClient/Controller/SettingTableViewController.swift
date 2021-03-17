
import UIKit

class SettingTableViewController: UITableViewController {

//    let cellTitles: [String] = ["Server IP Address", "Camera Address"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        self.navigationItem.title = "Setting"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: SettingTableViewCell
        
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableCellID1", for: indexPath) as! SettingTableViewCell
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableCellID2", for: indexPath) as! SettingTableViewCell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "SettingTableCellID1", for: indexPath) as! SettingTableViewCell
            cell.settingTitle.text = "Server IP Address"
        }
        return cell
    }

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "EditServer") {
            let target = segue.destination as! EditServerController
            target.serverIPData = Json.addressData.server_ip
            target.serverPortData = String(Json.addressData.server_port)
        }
        if (segue.identifier == "EditCam") {
            let target = segue.destination as! EditCamViewController
            target.addressList = Json.addressData.cam_urls
        }
        
    }
    
    
    @IBAction func returned(sender: UIStoryboardSegue) {
        if (sender.identifier == "EditServerSave") {
            let sourceView = sender.source as! EditServerController
            print("returned from server save")
            Json.addressData.server_ip = sourceView.serverIPData
            Json.addressData.server_port = Int(sourceView.serverPortData) ?? 0
            Json.writeJson()
        }
        if (sender.identifier == "EditCamSave") {
            let sourceView = sender.source as! EditCamViewController
            print("returned from cam save")
            Json.addressData.cam_urls = sourceView.addressList
            Json.writeJson()
        }
    }

}
