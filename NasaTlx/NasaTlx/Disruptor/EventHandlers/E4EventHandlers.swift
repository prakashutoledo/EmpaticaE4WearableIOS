//
//  E4EventHandlers.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 8/12/21.
//
import AsyncHTTPClient
import Disruptor
import Foundation

final class ElasticsearchEventHandler: EventHandler {
    let elasticsearchService: ElasticsearchService = ElasticsearchService.singleton
    
    var elasticsearchEvents: [ElasticsearchEvent] = []
    
    func onEvent(_ event: ElasticsearchEvent, sequence: Int64, endOfBatch: Bool) {
        elasticsearchEvents.append(event);
        if elasticsearchEvents.count == 30 {
            let batchEvents = self.elasticsearchEvents
            self.elasticsearchEvents = []
            elasticsearchService.bulkRequest(elasticsearchEvents: batchEvents)
        }
    }
    
    typealias Event = ElasticsearchEvent
}
