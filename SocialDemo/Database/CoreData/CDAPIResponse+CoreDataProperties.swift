//
//  CDAPIResponse+CoreDataProperties.swift
//  
//
//  Created by STL on 29/12/23.
//
//

import Foundation
import CoreData


extension CDAPIResponse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDAPIResponse> {
        return NSFetchRequest<CDAPIResponse>(entityName: "CDAPIResponse")
    }

    @NSManaged public var name: String?
    @NSManaged public var image: String?
    @NSManaged public var id: UUID?
    @NSManaged public var artistName: String?
    @NSManaged public var url: String?

}
