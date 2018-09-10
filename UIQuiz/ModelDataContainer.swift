//
//  ModelDataContainer.swift
//  UIQuiz
//
//  Created by Niels Andreas Østman on 10/09/2018.
//  Copyright © 2018 Niels Østman. All rights reserved.
//

import Foundation
import UIKit
struct ModelDataContainer : Codable {
    var keyName:String
    var description:String
    var pictureFileURL:URL
}
struct FailableDecodable<Base : Decodable> : Decodable {
    
    let base: Base?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.base = try? container.decode(Base.self)
    }
}
