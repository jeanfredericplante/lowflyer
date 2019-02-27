//
//  EmailComposer.swift
//  LowFlyer
//
//  Created by Jean Frederic Plante on 4/8/15.
//  Copyright (c) 2015 Jean Frederic Plante. All rights reserved.
//

import Foundation
import MessageUI
import UIKit


class EmailComposer: MFMailComposeViewController, MFMailComposeViewControllerDelegate {
    
    func canSendMail() -> Bool
    {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController
    {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["jfrederic.plante@gmail.com"])
        mailComposerVC.setSubject("Flyer feedback")
        mailComposerVC.setMessageBody("", isHTML: false)
        
        return mailComposerVC
    }
    
    
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!)
    {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
