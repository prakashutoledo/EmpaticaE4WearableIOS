//
//  ApplicationPropertiesService.swift
//  NasaTlx
//
//  Created by Prakash Khadka on 3/27/22.
//

class ApplicationPropertiesService : NSObject, ObservableObject {
    private var properties: [String : String]
    
    private override init() {
        self.properties = [:]
    }
}

extension ApplicationPropertiesService {
    public static let singleton: ApplicationPropertiesService = ApplicationPropertiesService()
    private static let propertiesFileName = "ApplicationProperties"
}

extension ApplicationPropertiesService {
    public func getProperty(propertyName: String) -> String? {
        return self.properties[propertyName]
    }
    
    public func load() -> Void {
        let applicationProperties = self.jsonToDictionary(
            fileName: "ApplicationProperties",
            fileExtension: "json"
        )
        let localApplicationProperties = self.jsonToDictionary(
            fileName: "ApplicationProperties.json",
            fileExtension: ".local")
            
        properties.merge(applicationProperties) { (_, newValue) in newValue }
        properties.merge(localApplicationProperties) { (_, newValue) in newValue }
    }
    
    private func jsonToDictionary(fileName: String, fileExtension: String) -> [String : String] {
        if let filePath = Bundle.main.url(forResource: fileName, withExtension: fileExtension) {
            do {
                let jsonData = try Data(contentsOf: filePath)
                let result: Any = try JSONSerialization.jsonObject(with: jsonData, options: [])
                return result as? [String: String] ?? [:]
            } catch {
                print("error:\(error)")
            }
        }
        return [:]
    }
}
