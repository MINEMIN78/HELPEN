//
//  SettingViewController.swift
//  HELPEN
//
//  Created by YUMAKOMORI on 2016/03/15.
//  Copyright © 2016年 YUMAKOMORI. All rights reserved.
//

import UIKit
import AudioToolbox

class SettingViewController: UIViewController ,UITableViewDelegate ,UITableViewDataSource {
    
    let userDef = UserDefault()
    
    let music = MusicList()
    
    
    
    let cellID = "MyCell"
    
    var name = " "
    
    var pin = " "
    
    var mail = " "
    
    var selectedNum:Int = 0
    
    var songCount:Int = 0
    
    //空の配列を用意
    var names: [String] = []
    
    
    @IBOutlet weak var table: UITableView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //前回の保存内容があるかどうかを判定
        if((self.userDef.UserSetting.objectForKey("MAIL")) != nil){
            
            // Keyを指定して読み込み
            mail = self.userDef.UserSetting.objectForKey("MAIL") as! String
            
            pin = self.userDef.UserSetting.objectForKey("PIN") as! String
            
            name = self.userDef.UserSetting.objectForKey("NAME") as! String
            
            songCount = self.userDef.UserSetting.objectForKey("SONGNUM") as! Int
            
        }
        
        NSLog("%d",songCount)
        
        
        
        
        table.delegate = self
        
        table.dataSource = self
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        let VC = ViewController()
        
        VC.audioSetting(songCount)
        
        

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func  save() {
        self.userDef.UserSetting.setObject(self.mail, forKey:"MAIL")
        
        self.userDef.UserSetting.setObject(self.pin, forKey:"PIN")
        
        self.userDef.UserSetting.setObject(self.name, forKey:"NAME")
        
        self.userDef.UserSetting.setObject(self.songCount, forKey:"SONGNUM")
        
        
        
        
        // シンクロを入れないとうまく動作しないときがあります
        self.userDef.UserSetting.synchronize()
        
        let alert:UIAlertController = UIAlertController(title:"DONE",
            message: "保存が完了しました",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            
        }
        
        alert.addAction(okAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func pushAlert(alert:UIAlertController) {
        //textfiledの追加
        alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
            
        })
        
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル",
            style: .Cancel,
            handler:{
                (action:UIAlertAction!) -> Void in
                print("キャンセル")
        })
        
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
            let textFields:Array<UITextField>? =  alert.textFields as Array<UITextField>?
            if textFields != nil {
                for textField:UITextField in textFields! {
                    //各textにアクセス
                    if self.selectedNum == 0{
                        self.mail = textField.text!
                    }else if self.selectedNum == 1{
                        self.pin = textField.text!
                    }else if self.selectedNum == 2{
                        self.name = textField.text!
                    }
                    
                    self.table.reloadData()
                }
            }
        }
        
        
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        
        
        
        presentViewController(alert, animated: true, completion: nil)
        
        
    }
    
    
    //ここからtableview関連
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let lst = ["保護者連絡先（メール）","PINコード","ユーザー名（本名）","サウンド"]
        
        return lst[section]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let secs = [
            1,1,1,music.fileNameArray.count
        ]
        
        return secs[section]
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellID)
        
        switch indexPath.section {
        case 0:
            
            cell.textLabel?.text = mail
        case 1:
            cell.textLabel?.text = pin
            
        case 2:
            cell.textLabel?.text = name
            
        case 3:
            if indexPath.row == songCount {
                cell.accessoryType = .Checkmark
            }
            cell.textLabel?.text = music.fileNameArray[indexPath.row]
            
    
            
        default: break
        }
        
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellID)
        
        switch indexPath.section {
        case 0:
            let alert:UIAlertController = UIAlertController(title:"保護者連絡先（メール）",
                message: "保護者のメールアドレスを入力してください",
                preferredStyle: UIAlertControllerStyle.Alert)
            selectedNum = 0
            pushAlert(alert)
            
        case 1:
            let alert:UIAlertController = UIAlertController(title:"PINコード",
                message: "4桁の番号を入力してください",
                preferredStyle: UIAlertControllerStyle.Alert)
            selectedNum = 1
            pushAlert(alert)
        case 2:
            let alert:UIAlertController = UIAlertController(title:"ユーザー名（本名）",
                message: "ユーザー名を入力してください",
                preferredStyle: UIAlertControllerStyle.Alert)
            selectedNum = 2
            pushAlert(alert)
        case 3:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
            
            // Hoge は UITableViewCell とリンクする enum です。
            // セルの数だけループしてすべてのセルのチェックマークをはずしています。
            for i in 0..<self.music.fileNameArray.count {
                let indexPath: NSIndexPath = NSIndexPath(forRow: i, inSection: indexPath.section)
                if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath) {
                    cell.accessoryType = .None
                }
            }
            
            // 対象のセルにチェックマークを付けます
            if let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath) {
                NSLog("%d",indexPath.row)
                songCount = indexPath.row
                
                cell.accessoryType = .Checkmark
                
                
            }
            
        default: break
        }
    }

    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
