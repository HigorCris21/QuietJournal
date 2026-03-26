//
//  Untitled.swift
//  QuietJournal
//
//  Created by Higor  Lo Castro on 25/03/26.
//

import Foundation

extension String {

    // Valida se a string tem formato de email
    var isValidEmail: Bool {
        let regex = #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
       
        return range(of: regex, options: .regularExpression) != nil
    }
}
