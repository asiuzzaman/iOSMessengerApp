//
//  Extensions.swift
//  MyiOSMesserger
//
//  Created by Md. Asiuzzaman on 30/1/23.
//

import Foundation
import UIKit

extension UIView {
    
    public var width: CGFloat {
        return self.frame.size.width
    }
    public var height: CGFloat {
        return self.frame.size.height
    }
    public var top: CGFloat {
        return self.frame.origin.y
    }
    public var bottom: CGFloat {
        return self.frame.origin.y + height
    }
    
    public var left: CGFloat {
        return self.frame.origin.x
    }
    
    public var right: CGFloat {
        return self.frame.size.width + left 
    }
    
}

extension Notification.Name {
    static let didLogInNotification = Notification.Name("didLogInNotification")
}
