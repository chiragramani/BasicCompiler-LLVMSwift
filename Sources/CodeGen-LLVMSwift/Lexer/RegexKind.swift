//
//  File.swift
//  
//
//  Created by Chirag Ramani on 02/05/21.
//

import Foundation

enum RegexKind {
    static let float = try! NSRegularExpression(pattern: "[0-9]+\\.[0-9]*")
    static let integer = try! NSRegularExpression(pattern: "[0-9]+")
    static let string = try! NSRegularExpression(pattern: "\".*\"")
    static let identifier = try! NSRegularExpression(pattern: "[a-zA-Z][a-zA-Z0-9]*")
    static let spacesNewLinesTabs = try! NSRegularExpression(pattern: "[ \t\n]+")
}

extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
