//
//  ModelDataContainer.swift
//  UIQuiz
//
//  Created by Niels Andreas Østman on 10/09/2018.
//  Copyright © 2018 Niels Østman. All rights reserved.
//

import Foundation
struct ModelDataContainer : Codable {
    var key:String
    var description:String
    var correctAnswerDescription:String
    var wrongAnswerDescription:String
    var title:String
    var pictureName:String
    var coreDescription:String
    var optional:String
}
