//
//  Coordinator.swift
//  ModernImageSearchUIKit
//
//  Created by Wellington Moreno on 1/21/26.
//

import Combine
import Foundation
import UIKit


class Coordinator {
    private let window: UIWindow
    private var mainVC: MainVC!
    private var imageSearchAPI: ImageSearchAPI!
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        mainVC = MainVC()
        window.rootViewController = mainVC
        window.makeKeyAndVisible()
    }
    
    func finish() {
        window.rootViewController = nil
        mainVC = nil
    }
}
