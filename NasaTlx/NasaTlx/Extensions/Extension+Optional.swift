//
//  Extension+Optional.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 8/11/21.
//

extension Optional {
    public var isEmpty: Bool {
        guard case Optional.none = self else {
            return false
        }
        return true
    }

    public var isPresent: Bool {
        return !self.isEmpty
    }
    
    public func orElse(_ newValue: Wrapped) -> Wrapped! {
        if self.isEmpty {
            return newValue
        }
        return self.unsafelyUnwrapped
    }
}
