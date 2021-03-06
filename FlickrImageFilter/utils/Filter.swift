import UIKit

public class Filter: Filtering {
    
    public enum FilterType: String {
        case RedOffset
        case GreenOffset
        case BlueOffset
        case Contrast
        case Brightness
    }

    /*
     Variables
    */
    var rgbImage: RGBAImage!
    var redOffset = 0
    var greenOffset = 0
    var blueOffset = 0
    
    /*
     Constructor 
    */
    public init(img: UIImage!) {
        rgbImage = RGBAImage(image: img)
    }
    
    /*
     Function to get the RGBImage
    */
    public func getRGBImage() -> RGBAImage {
        return rgbImage
    }
    
    /*
     Function to set a default filter by String.
    */
    public func setDefaultFilter(filterType: FilterType) {
        switch filterType {
        case .RedOffset:
            print("FilterType.RedOffset")
            self.setRedOffset(50)
        case .GreenOffset:
            print("FilterType.GreenOffset")
            self.setGreenOffset(50)
        case .BlueOffset:
            print("ilterType.BlueOffset")
            self.setBlueOffset(50)
        case .Contrast:
            print("FilterType.Contrast")
            self.setContrast(50)
        case .Brightness:
            print("FilterType.Brightness")
            self.setBrightness(50) 
        }
    }
    
    /*
      Function to set an offset filter to the color red.
    */
    public func setRedOffset(value: Int) {
        self.redOffset = value
        applyColorBalance()
    }
    
    /*
     Function to set an offset filter to the color green.
    */
    public func setGreenOffset(value: Int) {
        self.greenOffset = value
        applyColorBalance()
    }
    
    /*
     Function to set an offset filter to the color blue.
    */
    public func setBlueOffset(value: Int) {
        self.blueOffset = value
        applyColorBalance()
    }
    
    /*
      Function to set an brightness filter to the image.
    */
    public func setBrightness(modifier: Int) {
        
        //Loop to apply a filter to each pixel of the image.
        for y in 0..<rgbImage.height {
            
            for x in 0..<rgbImage.width {
                
                let index = y * rgbImage.width + x
                
                var pixel = rgbImage.pixels[index]
                
                let redDelta = Int(pixel.red)
                let greenDelta = Int(pixel.green)
                let blueDelta = Int(pixel.blue)
                
                pixel.red = UInt8(max(min(255,  modifier * redDelta), 0))
                pixel.green = UInt8(max(min(255,  modifier * greenDelta), 0))
                pixel.blue = UInt8(max(min(255,  modifier * blueDelta), 0))
                
                rgbImage.pixels[index] = pixel
            }
        }
    }
    
    /*
     Function to set an contrast filter to the image.
    */
    public func setContrast(var modifier: Int) {
        
        let avgReg = 1 * modifier
        let avgGreen = 2 * modifier
        let avgBlue = 3 * modifier
        let avgSum = avgReg + avgGreen + avgBlue
        
        //Loop to apply a filter to each pixel of the image.
        for y in 0..<rgbImage.height {
            
            for x in 0..<rgbImage.width {
                
                let index = y * rgbImage.width + x
                
                var pixel = rgbImage.pixels[index]
                
                let redDelta = Int(pixel.red) - avgReg
                let greenDelta = Int(pixel.green) - avgGreen
                let blueDelta = Int(pixel.blue) - avgBlue
                
                if(Int(pixel.red) + Int(pixel.green) + Int(pixel.blue) < avgSum ){
                    modifier = 2
                }
                
                pixel.red = UInt8(max(min(255, avgReg + modifier * redDelta), 0))
                pixel.green = UInt8(max(min(255, avgGreen + modifier * greenDelta), 0))
                pixel.blue = UInt8(max(min(255, avgBlue + modifier * blueDelta), 0))
                
                rgbImage.pixels[index] = pixel
            }
        }
    }
    
    /*
     Function to set a pipeline of filters to be applied to the image.
    */
    public func applyFilterPipeline(pipeline:[[FilterType : Int]]){
        for line in pipeline {
            if let value = line[Filter.FilterType.RedOffset] {
                setRedOffset(value)
            } else if let value = line[Filter.FilterType.GreenOffset] {
                setGreenOffset(value)
            } else if let value = line[Filter.FilterType.BlueOffset] {
                setBlueOffset(value)
            } else if let value = line[Filter.FilterType.Contrast] {
               setContrast(value)
            } else if let value = line[Filter.FilterType.Brightness] {
                setBrightness(value)
            }
        }
    }
    
    /*
     Function to apply a filter color Offset to each pixel of the image.
    */
    func applyColorBalance(){
        for y in 0..<rgbImage.height {
            
            for x in 0..<rgbImage.width {
                
                let index = y * rgbImage.width + x
                
                var pixel = rgbImage.pixels[index]
                
                let red = Int(pixel.red)
                let green = Int(pixel.green)
                let blue = Int(pixel.blue)
                
                pixel.red = UInt8(max(min(255, self.redOffset + red), 0))
                pixel.green = UInt8(max(min(255, self.greenOffset + green), 0))
                pixel.blue = UInt8(max(min(255, self.blueOffset + blue), 0))
                
                self.rgbImage.pixels[index] = pixel
            }
        }
    }
    
    static func applyFilterInBackground(filter: Filter, type: Filter.FilterType, editValue: Int, completionHandler:() ->Void){
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            if(editValue > -1){
                switch(type){
                case Filter.FilterType.RedOffset:
                    filter.setRedOffset(editValue)
                    break
                    
                case Filter.FilterType.GreenOffset:
                    filter.setGreenOffset(editValue)
                    break
                    
                case Filter.FilterType.BlueOffset:
                    filter.setBlueOffset(editValue)
                    break
                    
                case Filter.FilterType.Contrast:
                    filter.setContrast(editValue)
                    break
                    
                case Filter.FilterType.Brightness:
                    filter.setBrightness(editValue)
                    break
                }
            } else {
                filter.setDefaultFilter(type)
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                completionHandler()
            }
        }
    }
    
    static func generateIconForFilterButton(view: FilterMainViewController, type: Filter.FilterType, button: UIButton){
        let filter = Filter(img:UIImage(named: "sample"))
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            filter.setDefaultFilter(type)
            
            dispatch_async(dispatch_get_main_queue()) {
                let image = filter.getRGBImage().toUIImage()!
                button.setBackgroundImage(image, forState: .Normal)
                
                button.removeTarget(view, action: "onRed:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(view, action: "onGreen:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(view, action: "onBlue:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(view, action: "onContrast:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(view, action: "onBrightness:", forControlEvents: UIControlEvents.TouchUpInside)
                
                switch(type){
                case Filter.FilterType.RedOffset:
                    view.redButton.setBackgroundImage(image, forState: .Normal)
                    button.addTarget(view, action: "onRed:", forControlEvents: UIControlEvents.TouchUpInside)
                    break
                    
                case Filter.FilterType.GreenOffset:
                    view.greenButton.setBackgroundImage(image, forState: .Normal)
                    button.addTarget(view, action: "onGreen:", forControlEvents: UIControlEvents.TouchUpInside)
                    break
                    
                case Filter.FilterType.BlueOffset:
                    view.blueButton.setBackgroundImage(image, forState: .Normal)
                    button.addTarget(view, action: "onBlue:", forControlEvents: UIControlEvents.TouchUpInside)
                    break
                    
                case Filter.FilterType.Contrast:
                    view.contrastButton.setBackgroundImage(image, forState: .Normal)
                    button.addTarget(view, action: "onContrast:", forControlEvents: UIControlEvents.TouchUpInside)
                    break
                    
                case Filter.FilterType.Brightness:
                    view.brightnessButton.setBackgroundImage(image, forState: .Normal)
                    button.addTarget(view, action: "onBrightness:", forControlEvents: UIControlEvents.TouchUpInside)
                    break
                }
            }
        }
    } 
}
