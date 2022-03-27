//
//  ElastisearchClientService.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 1/9/22.
//

import AsyncHTTPClient

class ElasticsearchService: NSObject {
    private let httpClient: HTTPClient
    private let applicationPropertiesService: ApplicationPropertiesService
    
    private init(httpClient: HTTPClient, applicationPropertiesService: ApplicationPropertiesService) {
        self.httpClient = httpClient
        self.applicationPropertiesService = applicationPropertiesService
    }
}

extension ElasticsearchService {
    public static let singleton: ElasticsearchService = ElasticsearchService(
        httpClient: HTTPClient(eventLoopGroupProvider: .createNew),
        applicationPropertiesService: ApplicationPropertiesService.singleton
    )
    private static let indexJsonFormat: String = "{\"index\":{\"_index\":\"%@\"}}"
}

extension ElasticsearchService {
    public func bulkRequest(elasticsearchEvents: [ElasticsearchEvent]) -> Void {
        elasticsearchEvents.chunks(into: 30).forEach {
            self.bulkRequest(limitedEvents: $0)
        }
    }
    
    private func bulkRequest(limitedEvents: [ElasticsearchEvent]) -> Void {
        var mapped = limitedEvents
            .map({ "\(ElasticsearchService.indexJsonFormat.format($0.indexName))\n\($0.jsonEvent)"})
        let initialString = mapped.removeFirst()
        let postBody = mapped.reduce(initialString, { "\($0)\n\($1)" }) + "\n"
        self.bulkRequest(postBody: postBody)
    }
    
    private func bulkRequest(postBody: String) -> Void {
        do {
            var request = try HTTPClient.Request(
                url:self.applicationPropertiesService.getProperty(propertyName: "elasticsearch.bulk.uri")!,
                method: .POST
            )
            
            var headers = request.headers
            if let authenticationKey = self.applicationPropertiesService.getProperty(propertyName: "elasticsearch.authentication.key") {
                headers.add(
                    name: "Authorization",
                    value: "Basic \(authenticationKey)"
                )
                
            }
            headers.add(
                name: "Content-Type",
                value: "application/json"
            )
            
            request.body = .string(postBody)
            httpClient.execute(request: request).whenComplete(self.onResponseComplete)
        } catch {
            print("Error: Unable to perform request")
        }
    }
    
    private func onResponseComplete(result: Result<HTTPClient.Response, Error>) -> Void {
        switch result {
        case .failure(let error):
            print(error)
        case .success(let response):
            if var responseBody = response.body {
                let readbleBytes = responseBody.readableBytes
                let json = responseBody.readString(length: readbleBytes, encoding: .utf8)
                print(response.status.code)
                print(json ?? "No content")
            }
        }
    }
}
