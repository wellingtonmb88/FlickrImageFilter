//
//  ViewController.swift
//  ImageFilter
//
//  Created by WELLINGTON BARBOSA on 11/28/15.
//  Copyright © 2015 WELLINGTON BARBOSA. All rights reserved.
//

import UIKit

let reuseCellIdentifier = "reuseCellIdentifier"

class FilterMainViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIScrollViewDelegate{
    
    //MARK: @IBOutlet Variables
    @IBOutlet var sliderMenu: UIView!
    @IBOutlet var filtersMenu: UIView!
    @IBOutlet var filtersCollectionViewMenu: UIView!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var bottomMenu: UIStackView!
    @IBOutlet weak var imageView: DownloadImageView!
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
    @IBOutlet weak var addTagBarButton: UIBarButtonItem!
    @IBOutlet weak var zoomTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: Variables
    var imagePicker = UIImagePickerController()
    var imageFiltered: UIImage!
    var imageOriginal: UIImage!
    var imageBrightnessButton: UIImage!
    var filterTypeList: [Filter.FilterType]! 
    var filterApplied = false
    var filterType: Filter.FilterType!
    var feedItem: FeedItem!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        if let defaultImage = imageOriginal {
            self.imageView.image = defaultImage
        }else{
            self.imageView.image = UIImage(named: "sample")
            
            imageOriginal = imageView.image!
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(FilterMainViewController.handleImageLongPress(_:)))
        self.imageView.addGestureRecognizer(longPress)
        
        zoomTapGestureRecognizer.numberOfTapsRequired = 2

        filterTypeList = [Filter.FilterType.RedOffset,Filter.FilterType.GreenOffset
            ,Filter.FilterType.BlueOffset,Filter.FilterType.Contrast
            ,Filter.FilterType.Brightness]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: @IBAction Functions
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
    
    @IBAction func choosePhotoButton(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func compareButton(sender: AnyObject) {
        toogleImage()
    }
    
    @IBAction func addTag(sender: AnyObject) {
        let alertController = AlertUtils.createAlertWithTextField("Add Tag", message: "Type your tag") { (textFieldValue) -> Void in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            self.feedItem.isFiltered = 1
            
            self.imageView.cacheFilteredImg(self.feedItem.imageURL.absoluteString)
            
            appDelegate.dataController.tagFeedItem(textFieldValue, feedItem: self.feedItem)
        }
        
        self.presentViewController(alertController, animated: false, completion: nil)
    }
    
    
    @IBAction func onTap(sender: AnyObject) {
        UIView.animateWithDuration(0.4) { () -> Void in
            self.scrollView.zoomScale = 1.5 * self.scrollView.zoomScale
        }
    }
    
    //MARK: UIImagePickerController Functions
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
            self.addTagBarButton.enabled = false;
            self.filterApplied = false
        }
    }
    
    //MARK: GestureRecognizer Functions
    func handleImageLongPress(sender: UILongPressGestureRecognizer) {
       toogleImage()
    }
    
    
    //MARK: Private Functions
    
    private func setupUI(){
        self.compareButton.enabled = false
        self.editFilterButton.enabled = false
        self.addTagBarButton.enabled = false;
        self.imageView.userInteractionEnabled = true
        
        self.overlay.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        self.collectionView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        filtersCollectionViewMenu.translatesAutoresizingMaskIntoConstraints = false
        filtersCollectionViewMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.3)
        filtersCollectionViewMenu.alpha = 0
        
        sliderMenu.translatesAutoresizingMaskIntoConstraints = false
        sliderMenu.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        sliderMenu.alpha = 0
    }
    
    private func showFiltersMenu(){
        self.view.addSubview(filtersCollectionViewMenu)
        
        let topConstrain = filtersCollectionViewMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstrain = filtersCollectionViewMenu.leftAnchor.constraintEqualToAnchor(scrollView.leftAnchor)
        let rightConstrain = filtersCollectionViewMenu.rightAnchor.constraintEqualToAnchor(scrollView.rightAnchor)
        let heightConstraint = filtersCollectionViewMenu.heightAnchor.constraintEqualToConstant(100)
        
        NSLayoutConstraint.activateConstraints([topConstrain, leftConstrain, rightConstrain,heightConstraint])
        
        view.layoutIfNeeded()
        filtersCollectionViewMenu.fadeIn(alpha: 1.0, duration: 1.0)
        
    }
    
    private func hideFiltersMenu(){
        filtersCollectionViewMenu.fadeOut(duration: 1.0) { (finished) -> Void in
            self.filtersCollectionViewMenu.removeFromSuperview()
        }
    }
    
    private func showSliderMenu(){
        
        self.view.addSubview(sliderMenu)
        
        let topConstrain = sliderMenu.bottomAnchor.constraintEqualToAnchor(bottomMenu.topAnchor)
        let leftConstrain = sliderMenu.leftAnchor.constraintEqualToAnchor(scrollView.leftAnchor)
        let rightConstrain = sliderMenu.rightAnchor.constraintEqualToAnchor(scrollView.rightAnchor)
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
    
    private func setDefaultFilter(type: Filter.FilterType, editValue: Int){
        let filter = Filter(img:self.imageOriginal)
        self.filterType = type
        
        self.activityIndicator.startAnimating()
        self.view.userInteractionEnabled = false
        
        Filter.applyFilterInBackground(filter, type: type, editValue: editValue) { () -> Void in
            
            self.overlay.fadeOut(duration: 1.0, completion: { (finished) -> Void in
                self.overlay.hidden = true
            })
            
            self.imageView.image = filter.getRGBImage().toUIImage()
            self.imageFiltered = filter.getRGBImage().toUIImage()!
            
            self.compareButton.enabled = true
            self.editFilterButton.enabled = true
            self.addTagBarButton.enabled = true;
            self.filterApplied = true
            
            self.activityIndicator.stopAnimating()
            self.view.userInteractionEnabled = true
        }
    }
    
    private func toogleImage(){
        if self.compareButton.enabled {
            
            self.addTagBarButton.enabled = false
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
                    self.addTagBarButton.enabled = true
                }
                self.imageView.fadeIn(alpha: 1.0 ,duration: fadeInDuration)
            })
        }
    }
    
    
    //MARK: CollectionView Delegate
    
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
            Filter.generateIconForFilterButton(self, type: filterType, button: cell.button!)
        }
        return cell
    }
    
    //MARK: UIScrollView Delegate
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
} 
