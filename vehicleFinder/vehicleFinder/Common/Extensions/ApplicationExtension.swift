//
//  ApplicationExtension.swift
//  vehicleFinder
//
//  Created by Zeinab Khosravinia on 4/21/22.
//

import Foundation
import UIKit

extension UIApplication {
    static func getBottomSafeArea() -> CGFloat {
        if let window = UIApplication.shared.windows.first {
            let bottomPadding = window.safeAreaInsets.bottom
            return bottomPadding
        }
        
        return 0
    }
}
