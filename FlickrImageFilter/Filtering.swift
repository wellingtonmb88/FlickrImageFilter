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