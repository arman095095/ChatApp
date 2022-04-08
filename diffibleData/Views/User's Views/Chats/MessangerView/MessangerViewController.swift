//
//  MessegesChat.swift
//  diffibleData
//
//  Created by Arman Davidoff on 02.03.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import MessageKit
import UIKit
import InputBarAccessoryView
import SDWebImage
import RxSwift
import RxCocoa
import RxRelay
import AVFoundation
import Foundation

class MessangerViewController: MessagesViewController {
    
    private let messangerViewModel: MessangerViewModel
    private let dispose = DisposeBag()
    private let titleView = MessengerTitleView()
    private let timerView = TimerView()
    weak var delegate: CellReloaderProtocol?
    
    init(messangerViewModel: MessangerViewModel) {
        self.messangerViewModel = messangerViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        delegate?.reloadCell(with: messangerViewModel.currentChat)
        setupInputBar()
        addGesture()
        setupBinding()
        setupTopBar()
        messagesCollectionView.scrollToLastItem(animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if messagesCollectionView.indexPathsForVisibleItems.contains(IndexPath(item: 0, section: Int(3))) && messangerViewModel.canLoadMore {
            moreMessages()
        }
    }
}

//MARK: UI Updating
private extension MessangerViewController {
    
    func updateWithNewSendedMessage(message: MessageType) {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    func updateWithNewRecivedMessages(messages: [MessageType]) {
        if messagesCollectionView.indexPathsForVisibleItems.contains(IndexPath(item: 0, section: messagesCollectionView.numberOfSections - 1)) && messages.count < 3 {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        } else {
            self.messagesCollectionView.reloadData()
        }
    }
    
    func moreMessages() {
        if messangerViewModel.loadMoreMessages() {
            self.messagesCollectionView.reloadDataAndKeepOffset()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                self.messangerViewModel.canLoadMore = true
            })
        }
    }
}

//MARK: Setup Binding
private extension MessangerViewController {
    
    private func setupBinding() {
        
        messangerViewModel.chatEdited.asDriver().drive(onNext: { [weak self] changed in
            guard let self = self, changed else { return }
            self.titleView.set(title: self.messangerViewModel.friendUserName, imageURL: self.messangerViewModel.friendImageURL, description: self.messangerViewModel.titleDescription)
            self.messageInputBar.inputTextView.isEditable = self.messangerViewModel.allowedWrite
            self.messageInputBar.sendButton.isHidden = !self.messangerViewModel.allowedWrite
            self.messageInputBar.leftStackView.isHidden = !self.messangerViewModel.allowedWrite
            self.messageInputBar.inputTextView.placeholder = self.messangerViewModel.placeholder
        }).disposed(by: dispose)
        
        messangerViewModel.newSendMessage.asDriver().drive(onNext: { [weak self] message in
            guard let self = self, let message = message else { return }
            self.delegate?.reloadCell(with: self.messangerViewModel.currentChat)
            self.updateWithNewSendedMessage(message: message)
        }).disposed(by: dispose)
        
        messangerViewModel.sendMessageUpdate.asDriver().drive(onNext: { [weak self] update in
            guard let self = self, update else { return }
            self.delegate?.reloadCell(with: self.messangerViewModel.currentChat)
            self.messagesCollectionView.reloadData()
        }).disposed(by: dispose)
        
        messangerViewModel.newRecievedMessages.asDriver().drive(onNext: { [weak self] messages in
            guard let self = self, let messages = messages else { return }
            self.delegate?.reloadCell(with: self.messangerViewModel.currentChat)
            self.updateWithNewRecivedMessages(messages: messages)
        }).disposed(by: dispose)
        
        messangerViewModel.iamBlocked.asDriver().drive(onNext: { [weak self] blocked in
            if blocked { self?.createAlert(title: "Ошибка", message: "Пользователь Вас заблокировал") }
        }).disposed(by: dispose)
        
        messangerViewModel.sendingError.asDriver().drive(onNext: { error in
            if let error = error {
                if let _ = error as? ConnectionError {
                    Alert.present(type: .connection)
                } else {
                    Alert.present(type: .error,title: error.localizedDescription)
                }
            }
        }).disposed(by: dispose)
    }
}

//MARK: UIImagePickerControllerDelegate (Send photo)
extension MessangerViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @objc private func sendPhotoTapped() {
        ImagePicker.present(viewController: self)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let photo = (info[.originalImage] as! UIImage)
        messangerViewModel.sendPhoto(photo: photo, ratio: photo.size.width/photo.size.height)
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: MessagesDataSource
extension MessangerViewController: MessagesDataSource {
    
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messangerViewModel.messagesCount
    }
    
    func currentSender() -> SenderType {
        return Sender(senderId: messangerViewModel.user.id!, displayName: messangerViewModel.user.userName)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messangerViewModel.message(at: indexPath)
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard let mock = message as? MockMessage else { return nil }
        if mock.message.firstOfDate {
            return NSAttributedString(string: messangerViewModel.firstMessageTime(at: indexPath), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        else { return nil }
    }
}

//MARK: MessagesLayoutDelegate
extension MessangerViewController: MessagesLayoutDelegate {
    
    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard let message = message as? MMessage else { return 0 }
        if message.firstOfDate { return 30 }
        else { return 0 }
    }
}

//MARK: MessagesDisplayDelegate
extension MessangerViewController: MessagesDisplayDelegate {
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : UIColor.mainApp()
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .black : .white
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if isFromCurrentSender(message: message) {
            return .bubbleTailOutline(.systemGray4, .bottomRight, .pointedEdge)
        } else {
            return .bubbleTailOutline(.systemGray4, .bottomLeft, .curved)
        }
    }
    
    func audioTintColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.mainApp() : .white
    }
   
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let image = imageView.image else { return }
        messangerViewModel.saveImageAfterLoad(message: message, image: image)
    }
    
    func configureAudioCell(_ cell: AudioMessageCell, message: MessageType) {
        if !isFromCurrentSender(message: message) {
            cell.progressView.trackTintColor = .white
            cell.progressView.progressTintColor = .systemGray
        } else {
            cell.progressView.trackTintColor = UIProgressView().trackTintColor
            cell.progressView.progressTintColor = UIColor.mainApp()
        }
        messangerViewModel.configureAudioCell(cell: cell, message: message)
    }
}

//MARK: InputBarAccessoryViewDelegate (Send Button)
extension MessangerViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if text == "" || text.isEmpty {
            UIDevice.current.vibrate()
            return
        }
        messangerViewModel.sendMessage(text: text)
        inputBar.inputTextView.text = ""
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
        messangerViewModel.currentUserBeginTyping(text: text)
        inputBar.sendButton.isEnabled = true
        let empty = text == "" || text.isEmpty
        let image = UIImage(named: empty ? "record2" : "send2" )
        inputBar.sendButton.setImage(image, for: .normal)
        inputBar.sendButton.setupForSystemImageColor(color: UIColor.mainApp())
    }
}

//MARK: Setup UI
private extension MessangerViewController {
    
    func addGesture() {
        let press = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio(gesture:)))
        press.minimumPressDuration = 0.3
        messageInputBar.sendButton.addGestureRecognizer(press)
    }
    
    func setupViews() {
        messagesCollectionView.backgroundColor = UIColor.mainWhite()
        messageInputBar = InputBarAccessoryView()
        messageInputBar.delegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.keyboardDismissMode = .none
        messagesCollectionView.register(TextMessageCellCustom.self)
        messagesCollectionView.register(PhotoMessageCellCustom.self)
        messagesCollectionView.register(AudioMessageCellCustom.self)
        maintainPositionOnKeyboardFrameChanged = true
    }
    
    func setupTopBar() {
        navigationItem.largeTitleDisplayMode = .never
        titleView.delegate = self
        navigationItem.titleView = titleView
        titleView.set(title: messangerViewModel.friendUserName, imageURL: messangerViewModel.friendImageURL, description: messangerViewModel.titleDescription)
    }
    
    func setupInputBar() {
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.backgroundView.backgroundColor = UIColor.mainWhite()
        
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.placeholderTextColor = .gray
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 14, left: 12, bottom: 14, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 14, left: 15, bottom: 14, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor.gray.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 0.2
        messageInputBar.inputTextView.layer.cornerRadius = 18.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 14, left: 0, bottom: 14, right: 0)
        
        messageInputBar.inputTextView.isEditable = messangerViewModel.allowedWrite
        messageInputBar.sendButton.isHidden = !messangerViewModel.allowedWrite
        messageInputBar.leftStackView.isHidden = !messangerViewModel.allowedWrite
        messageInputBar.inputTextView.placeholder = messangerViewModel.placeholder
        
        setupSendButton()
        setupSendPhotoButton()
        setupTimerRecord()
        reloadInputViews()
    }
    
    func setupTimerRecord() {
        messageInputBar.addSubview(timerView)
        timerView.frame = CGRect(x: 20, y: 20, width: 200, height: 10)
        timerView.alpha = 0
    }
    
    func setupSendButton() {
        messageInputBar.sendButton.setImage(UIImage(named: "record2"), for: .normal)
        messageInputBar.setRightStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.sendButton.contentEdgeInsets = .zero
        messageInputBar.sendButton.title = nil
        messageInputBar.sendButton.setupForSystemImageColor(color: UIColor.mainApp())
        messageInputBar.rightStackView.alignment = .center
        messageInputBar.sendButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.middleContentViewPadding.right = 10
        messageInputBar.sendButton.isEnabled = true
    }
    
    func setupSendPhotoButton() {
        let photoButton = InputBarButtonItem(type:.system)
        photoButton.addTarget(self, action: #selector(sendPhotoTapped), for: .touchUpInside)
        photoButton.image = UIImage(named: "clip2")
        photoButton.setupForSystemImageColor(color: UIColor.mainApp())
        photoButton.setSize(CGSize(width: 36, height: 36), animated: false)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([photoButton], forStack: .left, animated: false)
        messageInputBar.middleContentViewPadding.left = 10
    }
}

//MARK: MessengerTitleViewDelegate
extension MessangerViewController: MessengerTitleViewDelegate {
    
    func presentProfile() {
        let vc = Builder.shared.profileVC(friend: messangerViewModel.friendUser, managers: messangerViewModel.managers)
        present(vc, animated: true, completion: nil)
    }
}

//MARK: AudioRecordUI
private extension MessangerViewController {
    
    @objc func recordAudio(gesture: UILongPressGestureRecognizer) {
        if let text = messageInputBar.inputTextView.text, text != "", !text.isEmpty { return }
        switch gesture.state {
        case .began:
            recordAudio()
        case .changed:
            leadingPan(gesture: gesture)
        case .ended:
            finishRecord(gesture: gesture)
        default:
            break
        }
    }
    
    func leadingPan(gesture: UILongPressGestureRecognizer) {
        let x = gesture.location(in: self.messageInputBar.rightStackView).x - self.messageInputBar.rightStackView.frame.width/2
        if x < -4 {
            messageInputBar.sendButton.transform = CGAffineTransform.init(translationX: x, y: 0)
            timerView.setAlpha(alpha: -x/(messageInputBar.frame.width/2))
        }
        if -x > (messageInputBar.frame.width/2 - messageInputBar.rightStackView.frame.width) {
            messageInputBar.sendButton.tintColor = .red
        } else {
            messageInputBar.sendButton.tintColor = UIColor.mainApp()
        }
    }
    
    func recordAudio() {
        messageInputBar.sendButton.setImage(UIImage(named: "record3"), for: .normal)
        UIDevice.current.vibrate()
        UIView.animate(withDuration: 0.5) { self.timerView.alpha = 1 }
        self.messageInputBar.inputTextView.isHidden = true
        self.messageInputBar.leftStackView.isHidden = true
        timerView.begin()
        messageInputBar.sendButton.pulse()
        messangerViewModel.beginRecord()
    }
    
    func finishRecord(gesture: UILongPressGestureRecognizer) {
        messageInputBar.sendButton.setImage(UIImage(named: "record2"), for: .normal)
        messageInputBar.sendButton.tintColor = UIColor.mainApp()
        messageInputBar.sendButton.transform = .identity
        timerView.alpha = 0
        timerView.stop()
        messageInputBar.sendButton.stopPulse()
        messageInputBar.leftStackView.isHidden = false
        messageInputBar.inputTextView.isHidden = false
        UIDevice.current.vibrate()
        let x = gesture.location(in: self.messageInputBar.rightStackView).x - self.messageInputBar.rightStackView.frame.width/2
        if -x > (messageInputBar.frame.width/2 - messageInputBar.rightStackView.frame.width) {
            messangerViewModel.cancelRecord()
        } else {
            messangerViewModel.finishRecord()
        }
    }
}

//MARK: MessageCellDelegate AudioPlay
extension MessangerViewController: MessageCellDelegate {
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
              let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else { return }
        messangerViewModel.playAudioMessage(message: message, cell: cell)
    }
}

//MARK: MessageCellDelegate Other Tap
extension MessangerViewController {
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let image = (messagesCollectionView.cellForItem(at: indexPath) as? PhotoMessageCellCustom)?.imageView.image else { return }
        self.imageTapped(image: image)
    }
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    private func imageTapped(image: UIImage) {
        let vc = Builder.shared.imageVC(image: image)
        self.navigationController?.pushViewController(vc, animated: true)
        self.tabBarController?.tabBar.isHidden = true
    }
}

//MARK: Custom Cells setup
extension MessangerViewController {
    
    func customCellSizeCalculator(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator {
        
        switch message.kind {
        case .custom(let kind):
            switch kind as! MessageKind {
            case .text(_):
                let textSizeCalculator = TextMessageSizeCalculatorCustom(layout: messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout)
                textSizeCalculator.setup()
                return textSizeCalculator
            case .photo(_):
                let photoSizeCalculator = PhotoMessageSizeCalculatorCustom(layout: messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout)
                photoSizeCalculator.setup()
                return photoSizeCalculator
            case .audio(_):
                let audioSizeCalculator = AudioMessageSizeCalculatorCustom(layout: messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout)
                audioSizeCalculator.setup()
                return audioSizeCalculator
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
    func customCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell {
        
        switch message.kind {
        case .custom(let kind):
            switch kind as! MessageKind {
            case .text(_):
                let cell = messagesCollectionView.dequeueReusableCell(TextMessageCellCustom.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .photo(_):
                let cell = messagesCollectionView.dequeueReusableCell(PhotoMessageCellCustom.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            case .audio(_):
                let cell = messagesCollectionView.dequeueReusableCell(AudioMessageCellCustom.self, for: indexPath)
                cell.configure(with: message, at: indexPath, and: messagesCollectionView)
                return cell
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
}
