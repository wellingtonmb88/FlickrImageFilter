//
//  ViewController.swift
//  ImageFilter
//
//  Created by WELLINGTON BARBOSA on 11/28/15.
//  Copyright © 2015 WELLINGTON BARBOSA. All rights reserved.
//

import UIKit

let reuseCellIdentifier = "reuseCellIdentifier"

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate,
      UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
     
    @IBOutlet var sliderMenu: UIView!
    @IBOutlet var filtersMenu: UIView!
    @IBOutlet var filtersCollectionViewMenu: UIView!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var bottomMenu: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var sliderEditMenu: UISlider!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var applyFilterButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    @IBOutlet weak var editFilterButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var contrastButton: UIButton!
    @IBOutlet weak var brightnessButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    var imageFiltered: UIImage!
    var imageOriginal: UIImage!
    var imageBrightnessButton: UIImage!
    var filterTypeList: [Filter.FilterType]! 
    var filterApplied = false
    var filterType: Filter.FilterType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overlay.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        self.compareButton.enabled = false
        self.editFilterButton.enabled = false
        self.imageView.image = UIImage(named: "sample")
        imageOriginal = imageView.image!
        imageView.userInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: Selector("handleImageLongPress:"))
        imageView.addGestureRecognizer(longPress)

        /*CollectionView Filter Menu*/
        collectionView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        filtersCollectionViewMenu.translatesAutoresizingMaskIntoConstraints = false
        filtersCollectionViewMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        filtersCollectionViewMenu.alpha = 0
        
        sliderMenu.translatesAutoresizingMaskIntoConstraints = false
        sliderMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        sliderMenu.alpha = 0
        
        filterTypeList = [Filter.FilterType.RedOffset,Filter.FilterType.GreenOffset
            ,Filter.FilterType.BlueOffset,Filter.FilterType.Contrast
            ,Filter.FilterType.Brightness]
        
    }
    
    private func generateIconForFilterButton(type: Filter.FilterType, button: UIButton){
        let filter = Filter(img:UIImage(named: "sample"))
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            filter.setDefaultFilter(type)
            
            dispatch_async(dispatch_get_main_queue()) {
                let image = filter.getRGBImage().toUIImage()!
                button.setBackgroundImage(image, forState: .Normal)
                
                button.removeTarget(self, action: "onRed:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(self, action: "onGreen:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(self, action: "onBlue:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(self, action: "onContrast:", forControlEvents: UIControlEvents.TouchUpInside)
                button.removeTarget(self, action: "onBrightness:", forControlEvents: UIControlEvents.TouchUpInside)
                
                switch(type){
                    case Filter.FilterType.RedOffset:
                        self.redButton.setBackgroundImage(image, forState: .Normal)
                        button.addTarget(self, action: "onRed:", forControlEvents: UIControlEvents.TouchUpInside)
                        break
                        
                    case Filter.FilterType.GreenOffset:
                        self.greenButton.setBackgroundImage(image, forState: .Normal)
                        button.addTarget(self, action: "onGreen:", forControlEvents: UIControlEvents.TouchUpInside)
                        break
                        
                    case Filter.FilterType.BlueOffset:
                        self.blueButton.setBackgroundImage(image, forState: .Normal)
                        button.addTarget(self, action: "onBlue:", forControlEvents: UIControlEvents.TouchUpInside)
                        break
                        
                    case Filter.FilterType.Contrast:
                        self.contrastButton.setBackgroundImage(image, forState: .Normal)
                        button.addTarget(self, action: "onContrast:", forControlEvents: UIControlEvents.TouchUpInside)
                        break
                        
                    case Filter.FilterType.Brightness:
                        self.brightnessButton.setBackgroundImage(image, forState: .Normal)
                        button.addTarget(self, action: "onBrightness:", forControlEvents: UIControlEvents.TouchUpInside)
                        break
                }
            }
        }
    }
    
    @IBAction func applyFilterButton(sender: UIButton) {
        if sender.selected {
            hideFiltersMenu()
            sender.selected = false
        }else {
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
            editFilterButton.selected = false
            hideSliderMenu()
            showFiltersMenu()
            sender.selected = true
        }
    }
    
    private func showFiltersMenu(){
        
        /*CollectionView Filter Menu*/
        self.view.addSubview(filtersCollectionViewMenu)
        
        let topConstrain = filtersCollectionViewMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstrain = filtersCollectionViewMenu.leftAnchor.constraintEqualToAnchor(imageView.leftAnchor)
        let rightConstrain = filtersCollectionViewMenu.rightAnchor.constraintEqualToAnchor(imageView.rightAnchor)
        let heightConstraint = filtersCollectionViewMenu.heightAnchor.constraintEqualToConstant(100)
        
        NSLayoutConstraint.activateConstraints([topConstrain, leftConstrain, rightConstrain,heightConstraint])
        
        view.layoutIfNeeded()
        filtersCollectionViewMenu.fadeIn(alpha: 1.0, duration: 1.0)
        
    }
    
    private func hideFiltersMenu(){
        /*CollectionView Filter Menu*/
        filtersCollectionViewMenu.fadeOut(duration: 1.0) { (finished) -> Void in
            self.filtersCollectionViewMenu.removeFromSuperview()
        }
    }
    
    @IBAction func editFilterButton(sender: UIButton) {
        if sender.selected {
            hideSliderMenu()
            sender.selected = false
        }else {
            applyFilterButton.selected = false
            self.sliderEditMenu.value = 50
            hideFiltersMenu()
            showSliderMenu()
            sender.selected = true
        }
    }
    
     private func showSliderMenu(){
        
        self.view.addSubview(sliderMenu)
        
        let topConstrain = sliderMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstrain = sliderMenu.leftAnchor.constraintEqualToAnchor(imageView.leftAnchor)
        let rightConstrain = sliderMenu.rightAnchor.constraintEqualToAnchor(imageView.rightAnchor)
        let heightConstraint = sliderMenu.heightAnchor.constraintEqualToConstant(40)
        
        NSLayoutConstraint.activateConstraints([topConstrain, leftConstrain, rightConstrain, heightConstraint])
        
        view.layoutIfNeeded()
        sliderMenu.fadeIn(alpha: 1.0, duration: 1.0)
        
    }
    
    private func hideSliderMenu(){
        sliderMenu.fadeOut(duration: 1.0) { (finished) -> Void in
            self.sliderMenu.removeFromSuperview()
        }
    }
    
    @IBAction func onRed(sender: AnyObject) {
        self.setDefaultFilter(Filter.FilterType.RedOffset, editValue: -1)
    }
    
    @IBAction func onGreen(sender: AnyObject) {
        self.setDefaultFilter(Filter.FilterType.GreenOffset, editValue: -1)
    }
    
    @IBAction func onBlue(sender: AnyObject) {
        self.setDefaultFilter(Filter.FilterType.BlueOffset, editValue: -1)
    }
    
    @IBAction func onContrast(sender: AnyObject) {
        self.setDefaultFilter(Filter.FilterType.Contrast, editValue: -1)
    }
    
    @IBAction func onBrightness(sender: AnyObject) {
        self.setDefaultFilter(Filter.FilterType.Brightness, editValue: -1)
    }
    
    
    @IBAction func editFilter(sender: UISlider) {
        self.setDefaultFilter(filterType, editValue: Int(sender.value))
    }
    
    private func setDefaultFilter(type: Filter.FilterType, editValue: Int){
        let filter = Filter(img:self.imageOriginal)
        self.filterType = type
        self.applyFilterInBackground(filter, type: type, editValue: editValue)
    }
    
    private func applyFilterInBackground(filter: Filter, type: Filter.FilterType, editValue: Int){
        
        self.activityIndicator.startAnimating()
        self.view.userInteractionEnabled = false
        
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
                
                self.overlay.fadeOut(duration: 1.0, completion: { (finished) -> Void in
                    self.overlay.hidden = true
                })
                
                self.imageView.image = filter.getRGBImage().toUIImage()
                self.imageFiltered = filter.getRGBImage().toUIImage()!
                
                self.compareButton.enabled = true
                self.editFilterButton.enabled = true
                self.filterApplied = true
                
                self.activityIndicator.stopAnimating()
                self.view.userInteractionEnabled = true
            }
        }
    }

    @IBAction func choosePhotoButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        
        self.dismissViewControllerAnimated(true) { () -> Void in
            self.hideFiltersMenu()
            self.hideSliderMenu()
            self.editFilterButton.selected = false
            self.applyFilterButton.selected = false
            self.imageView.image = image
            self.imageOriginal = image
            self.overlay.hidden = false
            self.overlay.fadeIn(alpha: 1.0 ,duration: 2.0)
            self.compareButton.enabled = false
            self.editFilterButton.enabled = false
            self.filterApplied = false
        }
    }
    
    @IBAction func compareButton(sender: AnyObject) {
       toogleImage()
    }
    
    func handleImageLongPress(sender: UILongPressGestureRecognizer) {
       toogleImage()
    }
    
    private func toogleImage(){
        if self.compareButton.enabled {
            
            let fadeInDuration = 2.0
            let fadeOutDuration = 1.5
            
            self.overlay.fadeOut(duration: fadeOutDuration)
            self.imageView.fadeOut(duration: fadeOutDuration, completion: { (finished) -> Void in
                if self.filterApplied {
                    self.imageView.image = self.imageOriginal
                    self.filterApplied = false
                    self.overlay.hidden = false
                    self.overlay.fadeIn(alpha: 1.0 ,duration: fadeInDuration)
                } else {
                    self.overlay.hidden = true
                    self.imageView.image = self.imageFiltered
                    self.filterApplied = true
                }
                self.imageView.fadeIn(alpha: 1.0 ,duration: fadeInDuration)
            })
        }
    }
    
    //#CollectionView Delegate#
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterTypeList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseCellIdentifier, forIndexPath: indexPath) as! CollectionViewCell
        cell.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        let index = indexPath.row
        if index < filterTypeList.count {
            let filterType = filterTypeList[index]
            generateIconForFilterButton(filterType, button: cell.button!)
        }
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
} 
