//
//  BaseFloatEventFactory.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 6/3/21.
//
import Disruptor

class ElasticsearchFactory: EventFactory {
    func newInstance() -> Event {
        return ElasticsearchEvent()
    }
    
    typealias Event = ElasticsearchEvent
}
