//
//  StockPositions.swift
//  HELPEN
//
//  Created by YUMAKOMORI on 2016/03/14.
//  Copyright © 2016年 YUMAKOMORI. All rights reserved.
//

import UIKit
import Alamofire

class StockPositions: NSObject {
    // 保存ボタンが押されたときに呼ばれるメソッドを定義
    class func postLocation(position: Position) -> Bool{
        
        var params: [String: AnyObject] = [
            "lat": position.lat,
            "long": position.long,
            "mail": position.mail,
            "pin": position.pin,
            "name": position.name
        ]
        
        let VC = ViewController()
        
        var sendJudge:Bool = false
        
        // HTTP通信
        Alamofire.request(.POST, "https://helpen-tatsumu.c9users.io/api/positions", parameters: params, encoding: .URL).responseJSON { (request, response, error) in
            
            NSLog("=============request=============")
            NSLog(String(request))
            NSLog("=============response============")
            NSLog(String(response))
            //            print("=============JSON================")
            //            print(JSON)
            NSLog("=============error===============")
            
            if String(error) == "SUCCESS"{
                
                NSLog("ばかやろう")
                sendJudge = true
            }else{
                sendJudge = false
            }
            NSLog(String(error))
            NSLog("=================================")
        }
        return sendJudge
    }
}
