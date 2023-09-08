//
//  String+Extension.swift
//  GitHubSearch-reactorkit-demo
//
//  Created by 9oya on 9/6/23.
//

import UIKit

extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
    func firstLetter() -> String? {
        guard let first = self.first else { return nil }
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9가-힣ㄱ-ㅎ].*")
            if let _ = regex.firstMatch(in: String(first), range: NSMakeRange(0, 1)) {
                // 특수문자
                return String(first)
            }
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
        
        // 숫자
        if let _ = Int(String(first)) {
            return String(first)
        }
        
        // 영문
        if let asciiVal = self.uppercased().first?.asciiValue,
           asciiVal >= 65,
           asciiVal <= 95 {
            return String(UnicodeScalar(UInt8(asciiVal)))
        }
        
        // 한글
        let unicode = UnicodeScalar(String(first))?.value
        guard let unicodeChar = unicode else { return nil }
        // 초성
        let x = (unicodeChar - 0xac00) / 28 / 21
        // 중성
        // let y = ((unicodeChar - 0xac00) / 28) % 21
        // let j = UnicodeScalar(0x1161 + y)
        // 종성
        // let z = (unicodeChar - 0xac00) % 28
        // let k = UnicodeScalar(0x11a6 + 1 + z)
        
        if let i = UnicodeScalar(0x1100 + x) {
            return String(i)
        }
        
        return nil
    }
}

