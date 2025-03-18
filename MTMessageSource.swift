//
//  MTMessageSource.swift
//  
//
//  Created by Waseem Akram on 03/10/21.
//

import Foundation

public struct MTMessageSource: Decodable {
    
    public let id: String
    public let downloadURL: String
    public let data: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case downloadURL = "downloadUrl"
        case data
    }
    
}
