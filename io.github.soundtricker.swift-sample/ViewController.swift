//
//  ViewController.swift
//  io.github.soundtricker.swift-sample
//
//  Created by soundTricker on .
//  Copyright (c) 2014 Keisuke Oohashi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {


    let KEY_CHAIN_ITEM_NAME : String = "SwiftGCEApp"

    //clientId and clientSecret should be make on https://console.developers.google.com/
    let CLIENT_ID : String = "your client id"
    let CLIENT_SECRET : String = "your client secret"

    var signedIn = false

    let service : GTLServiceSwiftsampleapi

    init(coder aDecoder: NSCoder!)  {
        service = GTLServiceSwiftsampleapi()

        service.retryEnabled = true
        GTMHTTPFetcher.setLoggingEnabled(true)

        super.init(coder : aDecoder)
    }

    @IBOutlet var message : UITextField
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveMessage(sender : AnyObject) {
        if !signedIn {
            let alert = UIAlertController(title: "Error", message: "Is not Loggedin", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }

        let param = GTLSwiftsampleapiPostReq()
        param.message = message.text

        let query : GTLQuerySwiftsampleapi = GTLQuerySwiftsampleapi.queryForMessagePostWithObject(param) as GTLQuerySwiftsampleapi

        self.service.executeQuery(query, completionHandler: { (ticket : GTLServiceTicket!, object : AnyObject!, error : NSError!) -> Void in


            if error != nil {
                NSLog("\(error)")
                return
            }
            let res  = object as GTLSwiftsampleapiPostRes
            self.message.text = "\(res.message) \(res.identifier) \(res.registeredAt) \(res.email)"
            })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func authorize(sender : AnyObject) {
        let viewController = GTMOAuth2ViewControllerTouch(scope : "https://www.googleapis.com/auth/userinfo.email" , clientID: CLIENT_ID, clientSecret:CLIENT_SECRET, keychainItemName : KEY_CHAIN_ITEM_NAME, delegate : self, finishedSelector : "viewController:finishedWithAuth:error:")

        self.presentModalViewController(viewController,  animated: true)
    }

    @objc(viewController:finishedWithAuth:error:)
    func finishedWithAuth(viewController :GTMOAuth2ViewControllerTouch , finishedWithAuth auth:GTMOAuth2Authentication,error:NSError){
        self.dismissModalViewControllerAnimated(true)

        if error != nil {

        } else {
            self.service.authorizer = auth
            auth.authorizationTokenKey = "id_token"
            signedIn = true
        }
    }



    @IBAction func greeting(sender : AnyObject) {
        let query : GTLQuerySwiftsampleapi = GTLQuerySwiftsampleapi.queryForMessageGet() as GTLQuerySwiftsampleapi

        self.service.executeQuery(query, completionHandler: { (ticket : GTLServiceTicket!, object : AnyObject!, error : NSError!) -> Void in


            if error != nil {
                NSLog("\(error)")
                return
            }

            self.message.text = (object as GTLSwiftsampleapiGetRes).message
            
        })
    }

}

