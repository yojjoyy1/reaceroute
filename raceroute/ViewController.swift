//
//  ViewController.swift
//  raceroute
//
//  Created by Cxicl on 2017/9/19.
//  Copyright © 2017年 Cxicl. All rights reserved.
//

import UIKit

class ViewController: UIViewController,TraceRouteDelegate,UITextFieldDelegate
{
    @IBOutlet weak var textV: UITextView!
    @IBOutlet weak var textF: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var okbtn: UIButton!
    var traceRoute:TraceRoute = TraceRoute()
    var prefs = UserDefaults()
    let ttl: Int32 = 10
    let timeout: Int32 = 5000000
    let port: Int32 = 80
    let maxAttempts: Int32 = 1
    var hos:Hop!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        textF.delegate = self
        traceRoute = TraceRoute(maxTTL: ttl, timeout: timeout, maxAttempts: maxAttempts, port: port)
        traceRoute.delegate = self
        prefs = UserDefaults.standard
        textV.isEditable = false
        textV.isSelectable = false
        let lastHost = prefs.string(forKey: "LastHost")
        if (lastHost != nil)
        {
            textF.text! = lastHost!
            print("lastHost:\(lastHost!)")
        }
        print("lastHost:\(lastHost!)")
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func ok(_ sender: UIButton)
    {
        textF.resignFirstResponder()
        if traceRoute.isRunning()
        {
            traceRoute.stopTrace()
            okbtn.setTitle("開始", for: UIControlState())
            print("ok traceRoute is running")
        }
        else
        {
            prefs.set(textF.text!, forKey: "LastHost")
            prefs.synchronize()
            let addressInput = textF.text!
            print("addressInput:\(addressInput)")
            Thread.detachNewThreadSelector(Selector("doTraceRoute:"), toTarget: traceRoute, with: addressInput)
            //Thread.detachNewThreadSelector(#selector(traceRoute.do(_:)), toTarget: traceRoute, with: addressInput)
            okbtn.setTitle("停止", for: UIControlState())
            textV.text = ""
            label.text = "traceroute \(addressInput)"
            print("ok traceRoute is stopping")
            
        }
    }
    func aaa()
    {
        let addressInput = textF.text!
        Thread.detachNewThreadSelector(Selector("doTraceRoute:"), toTarget: traceRoute, with: addressInput)
    }
    func newHop(_ hop: Hop!)
    {
        print("newHop:Hop:\(hop.debugDescription),\(hop.hostAddress!),\(hop.hostName),\(hop.time),\(hop.ttl)")
        let output = textV.text!
        print("output:\(output)")
//        for i in 0...hop.ttl
//        {
            //print("i:\(i)")
            if hop.hostName == nil
            {
                textV.text = "\(output) 第\(hop.ttl)次 \(hop.hostAddress!) 反應時間:\(hop.time) ms\n"
            }
            else
            {
                textV.text = "\(output) 第\(hop.ttl)次 \(hop.hostAddress!) \(hop.hostName!) 反應時間:\(hop.time) ms\n"
                //textV.setContentOffset(CGPoint(x:0,y:textV.frame.size.height), animated: true)
            }

//        }
    }
    func end()
    {
        print("end")
        okbtn.setTitle("開始", for: UIControlState())
    }
    func error(_ errorDesc: String!)
    {
        print("ERROR: \(errorDesc)")
        end()
    }
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        textF.text! = textField.text!
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }



}

