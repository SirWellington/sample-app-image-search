//
//  Models.swift
//  ModernImageSearchUIKit
//
//  Created by Wellington Moreno on 1/21/26.
//

import Foundation

struct Image: Equatable{
    let id: String
    let fullSizeURL: URL
    let thumbnailURL: URL
    let size: CGSize
}
