//
//  File.swift
//  
//
//  Created by Andy on 12/11/2023.
//

import Foundation

extension Date {
    init?(id3String dateString: String) {
        let dateStringFormatter = DateFormatter()
        if dateString.count == 4 {
            dateStringFormatter.dateFormat = "yyyy"
        }
        else if dateString.count == 10 {
            dateStringFormatter.dateFormat = "yyyy-MM-dd"
        }
        else if dateString.count == 13 {
            dateStringFormatter.dateFormat = "yyyy-MM-dd HH"
        }
        else if dateString.count == 16 {
            dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        }
        else if dateString.count == 19 {
            dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        }
        else {
            return nil
        }
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        if let date = dateStringFormatter.date(from: dateString.replacingOccurrences(of: "T", with: " ")) {
            self.init(timeInterval:0, since:date)
        }
        else {
            return nil
        }
    }
    
    var id3String: String {
        let dateFormatter = DateFormatter()
        /*
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let str = dateFormatter.string(from: self)
        return str.replacingOccurrences(of: " ", with: "T")
         */
        // Using a simpler format to match the behaviour of other taggers.
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let str = dateFormatter.string(from: self)
        return str
    }
}
