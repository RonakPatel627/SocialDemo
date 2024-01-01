//
//  SQLiteHelper.swift
//  SocialDemo
//
//  Created by STL on 01/01/24.
//

import SQLite
import Foundation

struct Item {
    var name: String
    var imageUrl: String
}


class SQLiteHelper {
    private var db: Connection?
    
    init() {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("SocialAppDatabase.sqlite3")
            
            db = try Connection(fileURL.path)
            createTable()
        } catch {
            print("Error opening database: \(error)")
        }
    }
    
    
    private let items = Table("items")
    private let id = Expression<Int>("id")
    private let name = Expression<String>("name")
    private let imageUrl = Expression<String>("imageUrl")
    
    func createTable() {
        do {
            try db?.run(items.create { table in
                table.column(id, primaryKey: true)
                table.column(name)
                table.column(imageUrl)
            })
        } catch {
            print("Error creating table: \(error)")
        }
    }
    
    func insertItem(name: String, imageUrl: String) {
        let insert = items.insert(self.name <- name, self.imageUrl <- imageUrl)
        do {
            try db?.run(insert)
        } catch {
            print("Error inserting item: \(error)")
        }
    }
    
    func getAllItems() -> [Item] {
        var itemsArray = [Item]()
        do {
            for item in try db!.prepare(items) {
                let itemName = item[name]
                let itemImageUrl = item[imageUrl]
                let newItem = Item(name: itemName, imageUrl: itemImageUrl)
                itemsArray.append(newItem)
            }
        } catch {
            print("Error fetching items: \(error)")
        }
        return itemsArray
    }
}

