//
//  LRSSender.swift
//  MLQuiz
//
//  Created by Niels Østman on 16/02/2018.
//  Copyright © 2018 Niels Andreas Østman. All rights reserved.
//

import Alamofire
class LRSSender {
    static var ObjectIdMLQuiz = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}activities\u{2215}MLQuiz"
    static var ObjectIdQuiz = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}activities\u{2215}Quiz"
    static var ObjectIdTest = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}activities\u{2215}Test"
    static var ObjectIdExplore = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}activities\u{2215}Explore"
    static var ObjectIdOptions = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}activities\u{2215}Options"
    static var ObjectIdCategory = "http:\u{2215}\u{2215}id.tincanapi.com\u{2215}activitytype\u{2215}category"
    static var ObjectIdWebpage = "https:\u{2215}\u{2215}w3id.org\u{2215}xapi\u{2215}acrossx\u{2215}activities\u{2215}webpage"
    
    static var VerbIdChose = "https:\u{2215}\u{2215}w3id.org\u{2215}xapi\u{2215}dod-isd\u{2215}verbs\u{2215}chose"
    static var VerbIdRegistered = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}verbs\u{2215}registered"
    static var VerbIdInitialized = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}verbs\u{2215}initialized"
    static var VerbIdTerminated = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}verbs\u{2215}terminated"
    static var VerbIdPassed = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}verbs\u{2215}passed"
    static var VerbIdFailed = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}verbs\u{2215}failed"
    static var VerbIdSuspended = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}verbs\u{2215}suspended"
    static var VerbIdResumed = "http:\u{2215}\u{2215}adlnet.gov\u{2215}expapi\u{2215}verbs\u{2215}resumed"
    
    static var UserId = ""
    
    static var currentPage = ""
    static var currentActivityName = ""
    
    static func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return ""
    }
    static func sendDataToLRS(actorObjectType: String = "Agent", verbId: String, verbDisplay:String, activityId: String,  activityName:String, activityDescription:String){
        let standardDefaults = UserDefaults.standard
        let json: [String: Any] = [
            "actor": [
                "name": standardDefaults.string(forKey: "Name"),
                "mbox": "mailto:" + standardDefaults.string(forKey: "Email")!,
                "objectType": actorObjectType
            ],
            "verb": [
                "display": [
                    "en-US":verbDisplay
                ],
                "id":verbId
            ],
            "object":[
                "objectType": "Activity",
                "definition": [
                    "description": [
                        "en-US": activityDescription
                    ],
                    "name": [
                        "en-US": activityName
                    ]
                ],
                "id":activityId
            ]
        ]
        print(LRSSender.stringify(json: json))
        let username = "281952f03d4e45540fa67e463ffdbada545b2875"
        let password = "515a7b69ceb7de02ae8c96e058973f02d9e297b4"
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64LoginString = loginData.base64EncodedString()
        
        // create the request
        let url = URL(string: "https://competenceanalytics.com/data/xAPI/statements")
        let headers = ["X-Experience-API-Version": "1.0.1", "Authorization": "Basic \(base64LoginString)"]
        Alamofire.request(url!, method: .post, parameters: json, encoding: JSONEncoding.default, headers:headers)
            .responseJSON { response in
                print(response)
        }
    }
}
