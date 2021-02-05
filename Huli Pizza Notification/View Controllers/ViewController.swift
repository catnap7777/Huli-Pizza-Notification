//
//  ViewController.swift
//  Huli Pizza Notification
//
//  Created by Steven Lipton on 11/23/18.
//  Copyright © 2018 Steven Lipton. All rights reserved.
//

import UIKit
import UserNotifications

// a global constant
let pizzaSteps = ["Make pizza", "Roll Dough", "Add Sauce", "Add Cheese", "Add Ingredients", "Bake", "Done"]


class ViewController: UIViewController {
    var counter = 0
   
    @IBAction func schedulePizza(_ sender: UIButton) {
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            let status = settings.authorizationStatus
            if status == .denied || status == .notDetermined {
//** either one of these dispatchqueues works
//                DispatchQueue.main.async {
//                    self.accessDeniedAlert()
//                }
                DispatchQueue.main.async(execute: {
                    self.accessDeniedAlert()
                })
                return
            }
            if status == .provisional {
                print("Karen, you have provisional set")
            }
            //.. this was called in lesson 1 but below are new ways:
            //..   #1 uses static notification content - for scheduling a pizza
            //..   #2 uses dynamic notification content - for making a pizza (below)
            //self.introNotification()
            
            //.. #1
            //.. putting this in here makes this static notification content,
            //..  which is ok if you don't have many of these... but it might
            //..  be better to use dynamic notification content if you do (it's
            //..  more flexible
            self.counter += 1
            let content = UNMutableNotificationContent()
            content.title = "KAM - A Scheduled Pizza"
            content.body = "Time to make a pizza! \(self.counter)"
            content.badge = self.counter as NSNumber
            //.. #2
            //.. calls the function we created notificationContent to
            //.. dynamically set content
//            let content = self.notificationContent(title: "A timed pizza step", body: "Making Pizza!!!")
            
            var dateComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: Date())
            //.. instead of setting a particular date to trigger, we're just
            //..  going to set 15 seconds into the future for this lesson/class
            dateComponents.second = dateComponents.second! + 15
            //.. calendar trigger
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            //.. schedule notification
            let identifier = "message.scheduled"
            self.addNotification(trigger: trigger, content: content, identifier: identifier)
//
            
        }
    }
    
    
    @IBAction func makePizza(_ sender: UIButton) {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            let status = settings.authorizationStatus
            if status == .denied || status == .notDetermined {
//** either one of these dispatchqueues works
                DispatchQueue.main.async {
                    self.accessDeniedAlert()
                }
//                DispatchQueue.main.async(execute: {
//                    self.accessDeniedAlert()
//                })
                return
            }
            //.. this was called in lesson 1 but below are new ways:
            //..   #1 uses static notification content - for scheduling a pizza (above)
            //..   #2 uses dynamic notification content - for making a pizza
            //self.introNotification()
            
            //.. #1
            //.. putting this in here makes this static notification content,
            //..  which is ok if you don't have many of these... but it might
            //..  be better to use dynamic notification content if you do (it's
            //..  more flexible
//            let content = UNMutableNotificationContent()
//            content.title = "A Scheduled Pizza"
//            content.body = "Time to make a pizza!"
            
            //.. #2
            //.. calls the function we created notificationContent to
            //.. dynamically set content
            self.counter += 1
            let content = self.notificationContent(title: "KAM - A timed pizza step", body: "Making Pizza!!! \(self.counter)")
            content.badge = self.counter as NSNumber
            
            //.. time interval trigger
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10.0, repeats: false)
            //.. schedule notification
            let identifier = "message.pizza"
            self.addNotification(trigger: trigger, content: content, identifier: identifier)

        }
    }
    
    //.. function to schedule notifications (comprised of creating request and adding it
    //..   to notification center
    func addNotification(trigger: UNNotificationTrigger, content: UNMutableNotificationContent, identifier: String) {
        
        //.. create request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        //.. add it to notification center
        UNUserNotificationCenter.current().add(request) { (error) in
            self.printError(error, location: "Add request for identifier: " + identifier)
        }
    }
    
    //..used for dynamic notification content
    func notificationContent(title: String, body: String) -> UNMutableNotificationContent {
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.userInfo = ["step":0]
        return content
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.isNavigationBarHidden = true
    }

    //MARK: - Support Methods
    
    // A function to print errors to the console
    func printError(_ error:Error?,location:String){
        if let error = error{
            print("Error: \(error.localizedDescription) in \(location)")
        }
    }
    
    //A sample local notification for testing - from lesson 1
    //..  Notice the 4 parts - content, trigger, request, schedule
    //..     Since this function is not used in lesson 2 (because we use
    //..      static and dynamic content settings) these parts/steps are
    //..      incorporated in those functions above instead - in schedulePizza,
    //..      makePizza, and notificationContent functions
    func introNotification(){
        // a Quick local notification.
        let time = 15.0
        counter += 1
        //Content
        let notifcationContent = UNMutableNotificationContent()
        notifcationContent.title = "Hello, Pizza!!"
        notifcationContent.body = "Just a message to test permissions \(counter)"
        notifcationContent.badge = counter as NSNumber
        //Trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        
        //Request
        let request = UNNotificationRequest(identifier: "intro", content: notifcationContent, trigger: trigger)
        //Schedule
        UNUserNotificationCenter.current().add(request) { (error) in
            self.printError(error, location: "Add introNotification")
        }
    }
    //An alert to indicate that the user has not granted permission for notification delivery.
    func accessDeniedAlert(){
        // presents an alert when access is denied for notifications on startup. give the user two choices to dismiss the alert and to go to settings to change thier permissions.
        let alert = UIAlertController(title: "Huli Pizza", message: "Huli Pizza needs notifications to work properly, but they are currently turned off. Turn them on in settings.", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
            }
        }
        alert.addAction(okayAction)
        alert.addAction(settingsAction)
        present(alert, animated: true) {
        }
    }
}

