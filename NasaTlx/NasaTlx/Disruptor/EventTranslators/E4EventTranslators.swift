//
//  E4EventTranslators.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 8/12/21.
//
import Disruptor

class ElasticsearchEventTranslator: EventTranslator {
    func translateTo(_ event: inout ElasticsearchEvent, sequence: Int64, input: ElasticsearchEvent) {
        event.indexName = input.indexName
        event.jsonEvent = input.jsonEvent
    }
    
    typealias Event = ElasticsearchEvent
    typealias Input = ElasticsearchEvent
}
