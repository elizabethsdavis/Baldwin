//
//  ChatViewController.swift
//  SwiftExample
//
//  Created by Dan Leonard on 5/11/16.
//  Copyright © 2016 MacMeDan. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Alamofire

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

class BaldwinChatViewController: JSQMessagesViewController {
    var messages = [JSQMessage]()
    let defaults = UserDefaults.standard
    var conversation: Conversation?
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    fileprivate var displayName: String!
    
    // User Enum to make it easyier to work with.
    enum User: String {
        case You        = "001"
        case Baldwin    = "002"
    }
    
    // Helper Function to get usernames for a secific User.
    func getName(_ user: User) -> String{
        switch user {
        case .You:
            return "You"
        case .Baldwin:
            return "Baldwin"
        }
    }
    
    // Create an avatar with Image
    
    let AvatarUser = JSQMessagesAvatarImageFactory().avatarImage(withUserInitials: "ME", backgroundColor: UIColor(hex: "EFD469"), textColor: .white, font: UIFont.systemFont(ofSize: 12))
    
    let AvatarBaldwin = JSQMessagesAvatarImageFactory().avatarImage(with: #imageLiteral(resourceName: "brain girl"))
    
    
    // Helper Method for getting an avatar for a specific User.
    func getAvatar(_ id: String) -> JSQMessagesAvatarImage{
        
        let user = User(rawValue: id)!
        
        switch user {
        case .You:
            return AvatarUser
        case .Baldwin:
            return AvatarBaldwin
        }
    }
    
    func makeFakeBaldwinCoversation() -> [JSQMessage] {
        
        var conversation = [JSQMessage]()
        
        let message1 = JSQMessage(senderId: User.You.rawValue, displayName: getName(User.You), text: "Hey, can I touch your hair?")
        let message2 = JSQMessage(senderId: User.Baldwin.rawValue, displayName: getName(User.Baldwin), text: "You can't, because I'm a chat bot. But if I weren't, I would prefer you not to.")
        let message3 = JSQMessage(senderId: User.You.rawValue, displayName: getName(User.You), text: "Why? 🙁")
        let message4 = JSQMessage(senderId: User.Baldwin.rawValue, displayName: getName(User.Baldwin), text: "While the act of touching a person's hair may be a minimal annoyance to them at best, black people have experienced a history of mistreatment relating to their hair.")
        let message5 = JSQMessage(senderId: User.You.rawValue, displayName: getName(User.You), text: "What, how?")
        let message6 = JSQMessage(senderId: User.You.rawValue, displayName: getName(User.You), text: "Isn't that an exaggeration?")
        let message7 = JSQMessage(senderId: User.Baldwin.rawValue, displayName: getName(User.Baldwin), text: "Well, for one, black hair is not considered acceptable to mainstream beauty culture, adopting nicknames such as 'nappy', 'unkempt', or 'uncivilized'. Black people often even experience workplace discrimination for the way they wear their hair.")
        let message8 = JSQMessage(senderId: User.You.rawValue, displayName: getName(User.You), text: "Oh word?")
        let message9 = JSQMessage(senderId: User.Baldwin.rawValue, displayName: getName(User.Baldwin), text: "Yea. And that is to say, there is a history of undervaluing, mistreating, and even fetishising black hair for its unique qualities. I feel this every time someone asks to touch my hair, and it's insulting.")
        let message10 = JSQMessage(senderId: User.Baldwin.rawValue, displayName: getName(User.Baldwin), text: "People ask to touch my hair a LOT.")
        let message11 = JSQMessage(senderId: User.You.rawValue, displayName: getName(User.You), text: "Dang.")
        let message12 = JSQMessage(senderId: User.You.rawValue, displayName: getName(User.You), text: "Thanks Baldwin")
        let message13 = JSQMessage(senderId: User.You.rawValue, displayName: getName(User.You), text: "Never thought about it like that")
        let message14 = JSQMessage(senderId: User.Baldwin.rawValue, displayName: getName(User.Baldwin), text: "👍🏾")
        
        conversation = [message1, message2, message3, message4, message5, message6, message7, message8, message9, message10, message11, message12, message13, message14]
        return conversation
        
    }
    
    func makeBaldwinIntroMessage() -> [JSQMessage] {
        
        
        return [JSQMessage(senderId: User.Baldwin.rawValue, displayName: getName(User.Baldwin), text: "Hey! Mention something to me and I'll say what I know about it 😉")]
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.title = "Baldwin"
        
        // Display a sample conversation (use this for reference with Baldwin)
        messages = makeBaldwinIntroMessage()
        
        // Setup navigation
        // setupBackButton() // remove demo back button
        
        /**
         *  Override point:
         *
         *  Example of how to cusomize the bubble appearence for incoming and outgoing messages.
         *  Based on the Settings of the user display two differnent type of bubbles.
         *
         */
        
        if defaults.bool(forKey: Setting.removeBubbleTails.rawValue) {
            // Make taillessBubbles
            incomingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero, layoutDirection: UIApplication.shared.userInterfaceLayoutDirection).incomingMessagesBubbleImage(with: UIColor(hex: "FEEC66"))
            outgoingBubble = JSQMessagesBubbleImageFactory(bubble: UIImage.jsq_bubbleCompactTailless(), capInsets: UIEdgeInsets.zero, layoutDirection: UIApplication.shared.userInterfaceLayoutDirection).outgoingMessagesBubbleImage(with: UIColor.lightGray)
        }
        else {
            // Bubbles with tails
            incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: UIColor(hex: "b7b6ba"))
            outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor(hex: "EFD469"))
        }
        
        /**
         *  Example on showing or removing Avatars based on user settings.
         */
        
        if defaults.bool(forKey: Setting.removeAvatar.rawValue) {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
        } else {
            collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
            collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height:kJSQMessagesCollectionViewAvatarSizeDefault )
        }
        
        // Show Button to simulate incoming messages
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage.jsq_defaultTypingIndicator(), style: .plain, target: self, action: #selector(receiveMessagePressed))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(hex: "b7b6ba")
        
        // This is a beta feature that mostly works but to make things more stable it is diabled.
        collectionView?.collectionViewLayout.springinessEnabled = true
        
        automaticallyScrollsToMostRecentMessage = true
        
        self.collectionView?.reloadData()
        self.collectionView?.layoutIfNeeded()
    }
    
    func setupBackButton() {
        let backButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem = backButton
    }
    func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func makeBaldwinMessage(messageText message: String) -> JSQMessage {
        return JSQMessage(senderId: User.Baldwin.rawValue, displayName: getName(User.Baldwin), text: message)
    }
    
    /* Send a message to Baldwin and receive a response
     * TODO: incorporate message text into request end-to-end
     */
    func sendToBaldwinServer(messageText text: String) {
        
        // show typing indicator
        showTypingIndicator = true
        
        let manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = TimeInterval(500000);
        manager.session.configuration.timeoutIntervalForResource = TimeInterval(500000);
        let url = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        
        manager.request("http://10.31.55.120:8888?query="+(url ?? ""), method: .get).responseString(completionHandler: { [weak weakSelf = self] response in
            
            weakSelf?.showTypingIndicator = false
            
            print(response);
            print("RESPONSE: ", response);
            
            print("Request: \(response.request as Any)")  // original URL request
            print("Response: \(response.response as Any)") // HTTP URL response
            print("Data: \(response.data as Any)")     // server data
            print("Actual Data: \(String(describing: response.data))")
            print("Result: \(response.result)")   // result of response serialization
            
            
            let baldwinsResponse = response.result.value?.replacingOccurrences(of: "\\s+$",
                                                                               with: "",
                                                                               options: .regularExpression)
                
                weakSelf?.messages.append((weakSelf?.makeBaldwinMessage(messageText: baldwinsResponse ?? "Sorry, didn't understand that!"))!)
                weakSelf?.finishSendingMessage(animated: true)
        })
        
    }
    
    func receiveMessagePressed(_ sender: UIBarButtonItem) {
        print("TODO: Implement settings VC")
    }
    
    // MARK: JSQMessagesViewController method overrides
    override func didPressSend(_ button: UIButton, withMessageText text: String, senderId: String, senderDisplayName: String, date: Date) {
        
        /**
         *  Sending a message. Your implementation of this method should do *at least* the following:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishSendingMessage`
         */
        
        let message = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: date, text: text)
        self.messages.append(message)
        sendToBaldwinServer(messageText: text)
        self.finishSendingMessage(animated: true)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        
        /*
        self.inputToolbar.contentView!.textView!.resignFirstResponder()
        
        let sheet = UIAlertController(title: "Media messages", message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "Send photo", style: .default) { (action) in
            /**
             *  Create fake photo
             */
            let photoItem = JSQPhotoMediaItem(image: UIImage(named: "goldengate"))
            self.addMedia(photoItem)
        }
        
        let locationAction = UIAlertAction(title: "Send location", style: .default) { (action) in
            /**
             *  Add fake location
             */
            let locationItem = self.buildLocationItem()
            
            self.addMedia(locationItem)
        }
        
        let videoAction = UIAlertAction(title: "Send video", style: .default) { (action) in
            /**
             *  Add fake video
             */
            let videoItem = self.buildVideoItem()
            
            self.addMedia(videoItem)
        }
        
        let audioAction = UIAlertAction(title: "Send audio", style: .default) { (action) in
            /**
             *  Add fake audio
             */
            let audioItem = self.buildAudioItem()
            
            self.addMedia(audioItem)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        sheet.addAction(photoAction)
        sheet.addAction(locationAction)
        sheet.addAction(videoAction)
        sheet.addAction(audioAction)
        sheet.addAction(cancelAction)
        
        self.present(sheet, animated: true, completion: nil)
        */
    }
    
    func buildVideoItem() -> JSQVideoMediaItem {
        let videoURL = URL(fileURLWithPath: "file://")
        
        let videoItem = JSQVideoMediaItem(fileURL: videoURL, isReadyToPlay: true)
        
        return videoItem
    }
    
    func buildAudioItem() -> JSQAudioMediaItem {
        let sample = Bundle.main.path(forResource: "jsq_messages_sample", ofType: "m4a")
        let audioData = try? Data(contentsOf: URL(fileURLWithPath: sample!))
        
        let audioItem = JSQAudioMediaItem(data: audioData)
        
        return audioItem
    }
    
    func buildLocationItem() -> JSQLocationMediaItem {
        let ferryBuildingInSF = CLLocation(latitude: 37.795313, longitude: -122.393757)
        
        let locationItem = JSQLocationMediaItem()
        locationItem.setLocation(ferryBuildingInSF) {
            self.collectionView!.reloadData()
        }
        
        return locationItem
    }
    
    func addMedia(_ media:JSQMediaItem) {
        let message = JSQMessage(senderId: self.senderId(), displayName: self.senderDisplayName(), media: media)
        self.messages.append(message)
        
        //Optional: play sent sound
        
        self.finishSendingMessage(animated: true)
    }
    
    
    //MARK: JSQMessages CollectionView DataSource
    
    override func senderId() -> String {
        return User.You.rawValue
    }
    
    override func senderDisplayName() -> String {
        return getName(.You)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource {
        
        return messages[indexPath.item].senderId == self.senderId() ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource? {
        let message = messages[indexPath.item]
        return getAvatar(message.senderId)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        /**
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         *  The other label text delegate methods should follow a similar pattern.
         *
         *  Show a timestamp for every 3rd message
         */
        if (indexPath.item % 3 == 0) {
            let message = self.messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.date)
        }
        
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        let message = messages[indexPath.item]
        
        // Displaying names above messages
        //Mark: Removing Sender Display Name
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
         */
        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
            return nil
        }
        
        if message.senderId == self.senderId() {
            return nil
        }
        
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForCellTopLabelAt indexPath: IndexPath) -> CGFloat {
        /**
         *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
         */
        
        /**
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         *  The other label height delegate methods should follow similarly
         *
         *  Show a timestamp for every 3rd message
         */
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        
        return 0.0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        
        /**
         *  Example on showing or removing senderDisplayName based on user settings.
         *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
         */
        if defaults.bool(forKey: Setting.removeSenderDisplayName.rawValue) {
            return 0.0
        }
        
        /**
         *  iOS7-style sender name labels
         */
        let currentMessage = self.messages[indexPath.item]
        
        if currentMessage.senderId == self.senderId() {
            return 0.0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == currentMessage.senderId {
                return 0.0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
}
