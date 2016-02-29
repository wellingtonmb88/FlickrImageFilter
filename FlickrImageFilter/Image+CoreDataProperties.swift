//
//  Image+CoreDataProperties.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 2/26/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Image {

    @NSManaged var imageURL: String?
    @NSManaged var title: String?
    @NSManaged var isFiltered: NSNumber?
    @NSManaged var tag: Tag?

}
