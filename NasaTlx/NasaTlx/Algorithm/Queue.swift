//
//  Queue.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 8/11/21.
//
public class Queue<Element> {
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
    
    public func enqueue(_ element: Element) {
        list.append(element)
    }

    public func dequeue() -> Element? {
        guard let _ = list.first else {
            return nil
        }
       
        return list.removeFirst()
    }

    public func peek() -> Element? {
        return list.first
    }
    
    public func size() -> Int {
        return list.count
    }
}
