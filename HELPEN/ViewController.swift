//
//  ViewController.swift
//  HELPEN
//
//  Created by YUMAKOMORI on 2016/03/14.
//  Copyright © 2016年 YUMAKOMORI. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation
import MediaPlayer


class ViewController: UIViewController , CLLocationManagerDelegate{
    
    //音量MAX
    // 参照保持用にスライダーを宣言。
    var volumeSlider: UISlider!
    var myLocationManager:CLLocationManager!
    
    //var myComposeView : SLComposeViewController!
    
    // 緯度表示用のラベル.
    var myLatitude:String!
    
    // 経度表示用のラベル.
    var myLongitude:String!
    
    
    
    let defaultImage = UIImage(named: "HELPEN-Button1.png")!
    let dangerousImage = UIImage(named: "HELPEN-Button2.png")!
    
    var imageJudge: Bool = true
    
    var sendJudge:Bool!
    
    var timerState:Bool = false
    
    
    
    
    let redHelp = UIImage(named: "HELP-red.png")
    let grayHelp = UIImage(named: "HELP-gray.png")
    let image = UIImage(named: "setting.png")
    
    var audio: AVAudioPlayer!
    
    var songNum:Int = 0
    
    //インスタンス化
    let music = MusicList()
    
    let setting = SettingViewController()
    
    let location = Position()
    
    let objc = MailController()
    
    
    
    //NSTimer設定
    var dateFormatter: NSDateFormatter{
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter
    }
    
    var timer1:NSTimer!
    var timer2:NSTimer!
    
    
    @IBOutlet var helpButton: SpringButton!
    
    @IBOutlet var helpImage: UIImageView! = UIImageView()
    
    @IBOutlet weak var settingButton: UIBarButtonItem!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sendJudge = false
        
        if((setting.userDef.UserSetting.objectForKey("SONGNUM")) != nil){
            // Keyを指定して読み込み
            songNum = setting.userDef.UserSetting.objectForKey("SONGNUM") as! Int
        }
        
        //音量MAX
        let mpVolumeView = MPVolumeView(frame: self.view.bounds)
        
        // 音量調整用のスライダーを取得
        for childView in mpVolumeView.subviews {
            // UISliderクラスで探索
            if (childView.isKindOfClass(UISlider)){
                self.volumeSlider = childView as! UISlider
            }
        }
        self.volumeSlider.setValue(1.0, animated: false)
        
        audioSetting(songNum)
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // ナビゲーションを透明にする処理
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
        self.settingButton.image = image
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 透明にしたナビゲーションを元に戻す処理
        self.navigationController!.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController!.navigationBar.shadowImage = nil
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func warning() {
        
        if sendJudge == false{
            //位置情報を取得
            getLocation()
            
        }
        
        //初回
        imageChange()
        
        buttonAnimate()
        
        audio.play()
        
        // ホールド
        let longPress = UILongPressGestureRecognizer(target: self, action: "pressedLong:")
        longPress.minimumPressDuration = 2.0
        self.helpButton.addGestureRecognizer(longPress)
        
        
        if timerState == false {
            timerState == true
            //=一定間隔で実行
            timer1 = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "imageChange", userInfo: nil, repeats: true)
            
            timer2 = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "buttonAnimate", userInfo: nil, repeats: true)
        }
        
    }
    
    func buttonAnimate(){
        helpButton.animation = "pop"
        helpButton.duration = 0.6
        helpButton.animate()
    }
    
    func imageChange() {
        if imageJudge == true{
            helpButton.setImage(dangerousImage, forState: .Normal)
            helpImage.image = redHelp
            imageJudge = false
        }else{
            helpButton.setImage(defaultImage, forState: .Normal)
            helpImage.image = grayHelp
            imageJudge = true
        }
    }
    
    func pressedLong(sender: UILongPressGestureRecognizer!) {
        // 長押ししたときの処理
        
        // ジェスチャーの状態に応じて処理を分ける
        switch sender.state {
        case .Began:
            timer1.invalidate()
            timer2.invalidate()
            audio.stop()
            
            break
        case .Cancelled:
            break
        case .Ended:
            timerState = false
            sendJudge = false
            
            if imageJudge == false {
                helpButton.setImage(defaultImage, forState: .Normal)
                helpImage.image = grayHelp
            }
            
            break
        case .Failed:
            break
        default:
            break
        }
    }
    
    
    func audioSetting(num:Int) {
        
        if let audioPath = NSBundle.mainBundle().pathForResource(music.songNameArray[num],ofType: "wav"){
            let url = NSURL(fileURLWithPath: audioPath)
            
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                audio = try! AVAudioPlayer(contentsOfURL: url)
                NSLog("%@",music.songNameArray[num])
                //音楽を再生するメソッド
            } catch {
                //audioが生成できない時エラーになる
                fatalError("プレイヤーが作れませんでした")
            }
        } else {
            //audioPathに値がはいらなかったらエラー
            fatalError("Urlがnilです。再生できません。")
        }
        
        audio.numberOfLoops = -1
        
        audio.prepareToPlay()
    }
    
    
    //ここから下で位置情報関連のコード
    func getLocation() {
        // 現在地の取得.
        myLocationManager = CLLocationManager()
        
        myLocationManager.delegate = self
        
        // セキュリティ認証のステータスを取得.
        let status = CLLocationManager.authorizationStatus()
        
        // まだ認証が得られていない場合は、認証ダイアログを表示.
        if(status == CLAuthorizationStatus.NotDetermined) {
            print("didChangeAuthorizationStatus:\(status)");
            // まだ承認が得られていない場合は、認証ダイアログを表示.
            self.myLocationManager.requestAlwaysAuthorization()
        }
        
        // 取得精度の設定.
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 取得頻度の設定.
        //myLocationManager.distanceFilter = 100
        
        myLocationManager.startUpdatingLocation()
        
    }
    
    func sendLocation() {
        
        if sendJudge == false {
            if myLatitude != nil && myLongitude != nil{
                //NSLog("hoge")
                
                location.lat = myLatitude
                location.long = myLongitude
                
                if((setting.userDef.UserSetting.objectForKey("MAIL")) != nil){
                    
                    // Keyを指定して読み込み
                    location.mail = setting.userDef.UserSetting.objectForKey("MAIL") as! String
                    
                    location.pin = setting.userDef.UserSetting.objectForKey("PIN") as! String
                    
                    location.name = setting.userDef.UserSetting.objectForKey("NAME") as! String
                    
                }
                
                
                //                NSLog("緯度だよ〜%@",location.lat)
                //                NSLog("経度だよ〜%@",location.long)
                
            }
            sendJudge = StockPositions.postLocation(location)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        print("didChangeAuthorizationStatus");
        
        // 認証のステータスをログで表示.
        var statusStr = "";
        switch (status) {
        case .NotDetermined:
            statusStr = "NotDetermined"
        case .Restricted:
            statusStr = "Restricted"
        case .Denied:
            statusStr = "Denied"
        case .AuthorizedAlways:
            statusStr = "AuthorizedAlways"
        case .AuthorizedWhenInUse:
            statusStr = "AuthorizedWhenInUse"
        }
        print(" CLAuthorizationStatus: \(statusStr)")
    }
    
    // 位置情報取得に成功したときに呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        //NSLog("位置情報取得成功")
        
        // 緯度・経度の表示.
        myLatitude = String(manager.location!.coordinate.latitude)
        //myLatitudeLabel.textAlignment = NSTextAlignment.Center
        
        myLongitude = String(manager.location!.coordinate.longitude)
        //myLongitudeLabel.textAlignment = NSTextAlignment.Center
        
        if sendJudge == false{
            sendLocation()
            
            //Eメールを自動で送信する
            objc.sendEmail("smtp.mail.yahoo.co.jp","465","toufuou0708","iromoko338228032","toufuou0708@yahoo.co.jp","f.yamanaka1127@gmail.com","【HELPEN】緊急です！")
            
            
            /*@"smtp.mail.yahoo.co.jp";   // SMTPサーバのアドレス
             smtpSession.port = 465;
             smtpSession.username = @"toufuou0708";           // SMTPサーバのユーザ名
             smtpSession.password = @"iromoko338228032";*/
            
            sendJudge = true
        }
        
        
        //f.yamanaka1127@gmail.com
        
    }
    
    // 位置情報取得に失敗した時に呼び出されるデリゲート.
    func locationManager(manager: CLLocationManager!,didFailWithError error: NSError!){
        print("error")
        if sendJudge == false{
            getLocation()
        }
    }
    
    
}

