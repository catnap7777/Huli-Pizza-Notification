//
//  NotificationCenterDelegate.swift
//  HuliPizzaNotifications
//
//  Created by Steven Lipton on 10/9/18.
//  Copyright © 2018 Steven Lipton. All rights reserved.
//

import UIKit
import UserNotifications

//..*****************************************************************
//.. THIS CLASS/SWIFT FILE NEEDED FOR IN-APP NOTIFICATIONS; THERE ARE CHANGES
//..    IN APPDELEGATE.SWIFT NEEDED ALSO
//.. add UNUserNotificationCenterDelegate here; needed for in-app notifications ***kam
class NotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
   
    //..*****************************************************************
    //.. function needed for IN-APP notifications.. also need to change AppDelegate.swift file ***kam
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let action = response.actionIdentifier
        let request = response.notification.request
        let content = request.content.mutableCopy() as! UNMutableNotificationContent
        if action == "text.input"{
            let textResponse = response as! UNTextInputNotificationResponse
            let newContent = request.content.mutableCopy() as! UNMutableNotificationContent
            newContent.subtitle = textResponse.userText
            let request = UNNotificationRequest(identifier: request.identifier, content: newContent, trigger: request.trigger)
            UNUserNotificationCenter.current().add(request) { (error) in
                self.printError(error, location: "Text Input action")
            }        }
        
        if action == "cancel"{
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
        }
        if action == "snooze"{
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5.0, repeats: false)
            let request = UNNotificationRequest(identifier: request.identifier, content: request.content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { (error) in
                self.printError(error, location: "Snooze Action")
            }
        }
        if action == "next.step"{
            guard var step = content.userInfo["step"] as? Int else {return}
            step += 1
            if step < pizzaSteps.count {
                content.body = pizzaSteps[step]
                content.userInfo["step"] = step
                let request = UNNotificationRequest(identifier: request.identifier, content: content, trigger: request.trigger)
                UNUserNotificationCenter.current().add(request) { (error) in
                    self.printError(error, location: "Next Step action")
                }
            } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [request.identifier])
            }
        }
        completionHandler()
    }
    
    
    //MARK: - Support Methods
    let surferBullet = "🏄🏽‍♀️ "
    // A function to print errors to the console
    func printError(_ error:Error?,location:String){
        if let error = error{
            print("Error: \(error.localizedDescription) in \(location)")
        }
    }
}
