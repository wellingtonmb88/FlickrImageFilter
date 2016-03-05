//
//  Filtering.swift
//  FlickrImageFilter
//
//  Created by WELLINGTON BARBOSA on 3/5/16.
//  Copyright © 2016 WELLINGTON BARBOSA. All rights reserved.
//

import Foundation

protocol Filtering {
    
    func setDefaultFilter(filterType: Filter.FilterType)
    func setRedOffset(value: Int)
    func setGreenOffset(value: Int)
    func setBlueOffset(value: Int)
    func setBrightness(modifier: Int)
    func setContrast(modifier: Int)
    func applyFilterPipeline(pipeline:[[Filter.FilterType : Int]])
}