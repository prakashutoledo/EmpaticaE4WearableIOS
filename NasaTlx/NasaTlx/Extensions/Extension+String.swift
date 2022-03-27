//
//  Extension+String.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/9/22.
//

import Foundation

extension String {
    func format(_ varArg: CVarArg...) -> String {
        return String.init(format: self, arguments: varArg)
    }
}

extension String: Error {
    
}
