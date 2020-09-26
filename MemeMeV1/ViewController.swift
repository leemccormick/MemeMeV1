//
//  ViewController.swift
//  MemeMeV1
//
//  Created by Lee McCormick on 9/21/20.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,
                      UINavigationControllerDelegate, UITextFieldDelegate, UIPageViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navBar: UINavigationBar!
    

    
    func settingUpTextField(textField: UITextField, text: String) {
        //textField.delegate = self
        //textField.textAlignment = .center
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black /* TODO: fill in appropriate UIColor */,
            NSAttributedString.Key.foregroundColor: UIColor.white /* TODO: fill in appropriate UIColor */,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth: -2.0/* TODO: fill in appropriate Float */
        ]
        textField.attributedText = NSAttributedString(string: text, attributes: memeTextAttributes)
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        settingUpTextField(textField: topTextField, text: "TOP")
        settingUpTextField(textField: bottomTextField, text: "BOTTOM")
        self.topTextField.delegate = self
        self.bottomTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingUpTextField(textField: topTextField, text: "TOP")
        settingUpTextField(textField: bottomTextField, text: "BOTTOM")
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        if (imageView.image == nil) {
            shareButton.isEnabled = false
        }
        
        subscribeToKeyboardNotifications()
        subscribeToKeyboardNotificationsWillHide()
    }
    
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
    
         unsubscribeFromKeyboardNotifications()
         unsubscribeFromKeyboardNotificationsWillHide()
     }
    
    //MARK: - KeyBoard Appear Code
    //When the keyboardWillShow notification is received, shift the view's frame up
    @objc func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -= getKeyboardHeight(notification)
    }
    
    //keyboard will hide.
    @objc func keyboardWillHide(_ notification:Notification) {
        if bottomTextField.isFirstResponder{
            view.frame.origin.y = 0.0
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //Sign up to be notified when the keyboard appears
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardNotificationsWillHide() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotificationsWillHide() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - to save and generateMemeImage
    //Initializing a Meme object
    func save() {
        // Create the meme
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage {
        
        // TODO: Hide toolbar and navbar
        navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.isNavigationBarHidden = true
        hideToolbars(true)

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        navigationController?.setToolbarHidden(false, animated: false)
        self.navigationController?.isNavigationBarHidden = false
        hideToolbars(false)
        
        return memedImage
    }
    
    //MARK: - to hide navBar and toolBar
    func hideToolbars(_ hide: Bool) {
        navBar.isHidden = hide
        toolBar.isHidden = hide
    }
    
    //MARK: - to shareImage
    //shareImageButton.isEnabled = true
    @IBAction func shareImage(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = {activity, success, items, error in
            if(success){
                self.save()
            }
            self.dismiss(animated: true, completion: nil)
        }
        present(activityController, animated: true, completion: nil)
    }
    
 
    
    //MARK: - textField Method
    //When a user press return, the keyboard should be dismissed.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    // When a user taps inside a textfield, the default text should clear
       func textFieldDidBeginEditing(_ textField: UITextField) {
        if topTextField.isFirstResponder{
            topTextField.text?.removeAll()
        }
        if  bottomTextField.isFirstResponder{
           bottomTextField.text?.removeAll()
        }
       }
       

    //MARK: - Updated pickAnImage()
    
    func pickAnImage(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImage(sourceType: .photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImage(sourceType: .camera)
    }
    
    //MARK: - Delegate imagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage/* TODO: Dictionary Key Goes Here */] as? UIImage {
            imageView.image = image
            shareButton.isEnabled = true
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: - to cancel
    @IBAction func cancel(_ sender: Any) {
        imageView.image = nil
        settingUpTextField(textField: topTextField, text: "TOP")
        settingUpTextField(textField: bottomTextField, text: "BOTTOM")
    }
}

//MARK: - Initializing a Meme object with Struct
//Initializing a Meme object
struct Meme {
    var topText: String
    var bottomText: String
    var originalImage: UIImage
    var memedImage: UIImage
    
    init(topText: String, bottomText: String, originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
}





