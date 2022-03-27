//
//  Stack.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 8/12/21.
//
public class Stack<Element> {
    fileprivate var list: [Element]

    public convenience init() {
        self.init(nil)
    }
    
    public init(_ list: [Element]?) {
        if let newList = list {
            self.list = newList
        }
        else {
            self.list = []
        }
    }

    public func empty() -> Bool {
        return list.isEmpty
    }
    
    public func push(_ element: Element) {
        list.append(element)
    }

    public func pop() -> Element? {
        guard let _ = list.last else {
            return nil
        }
        return list.removeLast()
    }

    public func peek() -> Element? {
        return list.last
    }
    
    public func size() -> Int {
        return list.count
    }
}
