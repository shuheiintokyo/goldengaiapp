//
//  DataSeeder.swift
//  GoldenGaiApp
//
//  Created by Shuhei Kinugasa on 2025/11/08.
//

import Foundation
import CoreData

struct DataSeeder {
    
    // MARK: - Seed Initial Bars
    
    static func seedInitialBars(into context: NSManagedObjectContext) {
        // Load bar data from map.json
        guard let mapData = loadMapData() else {
            print("❌ Failed to load map data")
            return
        }
        
        // Load bar info from barinfo.json
        let barInfoDict = loadBarInfoData()
        
        // Parse and create bars
        let bars = parseMapData(mapData, barInfo: barInfoDict)
        
        // Insert into Core Data
        for barData in bars {
            let bar = Bar(context: context)
            bar.uuid = barData.id
            bar.name = barData.name
            bar.nameJapanese = barData.nameJapanese
            bar.latitude = barData.latitude
            bar.longitude = barData.longitude
            bar.visited = false
            bar.photoURLs = []
            bar.tags = barData.tags
            bar.lastSyncedDate = Date()
        }
        
        print("✅ Seeded \(bars.count) bars into Core Data")
    }
    
    // MARK: - Load JSON Data
    
    private static func loadMapData() -> [String: Any]? {
        guard let url = Bundle.main.url(forResource: "map", withExtension: "json") else {
            print("❌ map.json not found")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            print("✅ Loaded map.json")
            return json
        } catch {
            print("❌ Failed to load map.json: \(error.localizedDescription)")
            return nil
        }
    }
    
    private static func loadBarInfoData() -> [String: [String: Any]] {
        guard let url = Bundle.main.url(forResource: "barinfo", withExtension: "json") else {
            print("⚠️ barinfo.json not found")
            return [:]
        }
        
        do {
            let data = try Data(contentsOf: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let barsDict = json["bars"] as? [String: [String: Any]] {
                print("✅ Loaded barinfo.json with \(barsDict.count) entries")
                return barsDict
            }
        } catch {
            print("❌ Failed to load barinfo.json: \(error.localizedDescription)")
        }
        
        return [:]
    }
    
    // MARK: - Parse Map Data
    
    private static func parseMapData(
        _ mapData: [String: Any],
        barInfo: [String: [String: Any]]
    ) -> [BarData] {
        guard let mapArray = mapData["map"] as? [[String]] else {
            print("❌ Invalid map structure")
            return []
        }
        
        var bars: [BarData] = []
        let goldenGaiLat = 35.6656
        let goldenGaiLon = 139.7360
        
        // Iterate through map grid
        for (rowIndex, row) in mapArray.enumerated() {
            for (colIndex, barName) in row.enumerated() {
                guard !barName.isEmpty && barName != "*" else { continue }
                
                // Generate unique ID
                let barID = UUID().uuidString
                
                // Calculate approximate coordinates within Golden Gai
                let latOffset = Double(rowIndex) * 0.0002
                let lonOffset = Double(colIndex) * 0.0001
                let latitude = goldenGaiLat + latOffset
                let longitude = goldenGaiLon + lonOffset
                
                // Get Japanese name from barinfo if available
                var barNameJapanese = barName
                if let info = barInfo.values.first(where: {
                    ($0["barName"] as? String) == barName
                }) {
                    barNameJapanese = info["barName"] as? String ?? barName
                }
                
                // Create bar data
                let bar = BarData(
                    id: barID,
                    name: barName,
                    nameJapanese: barNameJapanese,
                    latitude: latitude,
                    longitude: longitude,
                    tags: extractTags(from: barName)
                )
                
                bars.append(bar)
            }
        }
        
        print("✅ Parsed \(bars.count) bars from map data")
        return bars
    }
    
    // MARK: - Helper Methods
    
    private static func extractTags(from barName: String) -> [String] {
        var tags: [String] = []
        
        let name = barName.lowercased()
        
        // Auto-tag based on name patterns
        if name.contains("bar") {
            tags.append("bar")
        }
        if name.contains("whisky") || name.contains("ウイスキー") {
            tags.append("whisky")
        }
        if name.contains("sake") || name.contains("酒") {
            tags.append("sake")
        }
        if name.contains("beer") || name.contains("ビール") {
            tags.append("beer")
        }
        
        return tags
    }
}

// MARK: - Bar Data Structure

struct BarData {
    let id: String
    let name: String
    let nameJapanese: String
    let latitude: Double
    let longitude: Double
    let tags: [String]
}
