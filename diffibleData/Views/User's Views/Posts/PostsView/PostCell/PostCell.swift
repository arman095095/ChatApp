//
//  PostCell.swift
//  diffibleData
//
//  Created by Arman Davidoff on 24.11.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    static let cellID = "PostCell"
    weak var delegate: PostCellDelegate?
    
    //Первый слой
    private var cardView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    //TopViews
    private var topView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var personImage: UIImageView = {
        var view = UIImageView()
        view.layer.cornerRadius = PostCellConstants.userImageHeight/2
        view.isUserInteractionEnabled = true
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var nameLabel: UILabel = {
        var view = UILabel()
        view.font = UIFont.systemFont(ofSize: 15)
        view.textColor = .link
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var dateLabel: UILabel = {
        var view = UILabel()
        view.textColor = UIColor.postGrey()
        view.font = UIFont.systemFont(ofSize: 13)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var ownerButton: SmallButton = {
        let button = SmallButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "menu"), for: .normal)
        button.tintColor = .systemGray2
        return button
    }()
    
    private var ownerButtonWidthConstreint: NSLayoutConstraint!
    private var bottonViewTopConstraint: NSLayoutConstraint!
    private var postCellModel: PostCellModelType! {
        didSet {
            setup()
        }
    }
    
    //dynamic Views withoutConstreints
    private var postsImageView: UIImageView = {
        var view = UIImageView()
        view.contentMode = .scaleToFill
        return view
    }()
    private var postTextView: UITextView = {
        var view = UITextView()
        view.font = PostCellConstants.postsTextFont
        view.isScrollEnabled = false
        view.isEditable = false
        view.isSelectable = true
        let padding = view.textContainer.lineFragmentPadding
        view.textContainerInset = UIEdgeInsets(top: 0, left: -padding, bottom: 0, right: -padding)
        view.dataDetectorTypes = UIDataDetectorTypes.all
        return view
    }()
    private var fullTextButton : UIButton = {
        var view = UIButton(type: UIButton.ButtonType.system)
        view.titleLabel?.font = PostCellConstants.buttonFont
        view.setTitle("показать полностью...", for: .normal)
        return view
    }()
    private lazy var onlineImageView: UIImageView = {
        var view = UIImageView()
        view.image = UIImage(named: "online")
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = UIColor.onlineColor()
        view.layer.cornerRadius = 7.5
        view.layer.borderWidth = 3
        view.layer.borderColor = cardView.backgroundColor?.cgColor
        view.layer.masksToBounds = true
        return view
    }()
    private var bottonView: UIView = {
        var view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var likesView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var likeButton: UIButton = {
        var view = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(weight: UIImage.SymbolWeight.medium)
        view.setImage(UIImage(systemName: "heart",withConfiguration: config), for: .normal)
        view.tintColor = UIColor.postGrey()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private var likesCountLabel: UILabel = {
        var view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor.postGrey()
        view.lineBreakMode = .byWordWrapping
        view.font = UIFont.systemFont(ofSize: 13,weight: .medium)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstreintsForCard()
        setupConstreintsForTopView()
        setupConstreintsForIconImage()
        setupConstreintsForOwnerButton()
        setupConstreintsForNameLabel()
        setupConstreintsForDateLabel()
        setupConstreintsForOnlineImageView()
        setupConstreintsForBottonView()
        setupConstreintsForLikesView()
        setupConstreintsForLikes()
        setupActions()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.personImage.image = nil
        self.onlineImageView.isHidden = true
        self.postsImageView.image = nil
        self.ownerButtonWidthConstreint.constant = 0
        self.likeButton.tintColor = UIColor.postGrey()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(model: PostCellModelType) {
        self.postCellModel = model
    }
    
    private func setup() {
        personImage.sd_setImage(with: postCellModel.userImageURL)
        nameLabel.text = postCellModel.userName
        dateLabel.text = postCellModel.postDate
        ownerButtonWidthConstreint.constant = postCellModel.currentUserOwnerButtonWidth
        postTextView.text = postCellModel.textContent
        postsImageView.sd_setImage(with: postCellModel.postImageURL)
        
        postTextView.frame = postCellModel.textContentFrame
        postsImageView.frame = postCellModel.postImageFrame
        fullTextButton.frame = postCellModel.buttonFrame
        onlineImageView.isHidden = !postCellModel.online
        likesCountLabel.text = postCellModel.likesCount
        likeButton.tintColor = postCellModel.liked ? .systemRed : UIColor.postGrey()
        bottonViewTopConstraint.constant = postCellModel.postImageFrame.size == .zero ? -PostCellConstants.imageAndTextInset : 0
        
        layoutIfNeeded()
    }
    
    @objc private func showRealFrame() {
        delegate?.reloadCell(cell: self)
    }
    
    @objc private func likePost() {
        likeButton.tintColor = postCellModel.liked ? UIColor.postGrey() : .systemRed
        likesCountLabel.text = postCellModel.likesCountAfterLike
        delegate?.likePost(cell: self)
    }
    
    @objc private func alertForOwner() {
        delegate?.presentOwnerAlert(cell: self)
    }
    
    @objc private func openProfile() {
        delegate?.openUserProfile(cell: self)
    }
}

//MARK: Setup UI
private extension PostCell {
    
    func setupViews() {
        self.backgroundColor = .clear
        cardView.layer.cornerRadius = 8
        cardView.clipsToBounds = true
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.4
        self.layer.shadowOffset = CGSize(width: 2.5, height: 4)
        self.layer.shadowColor = UIColor.black.cgColor
    }
    
    func setupActions() {
        likeButton.addTarget(self, action: #selector(likePost), for: .touchUpInside)
        fullTextButton.addTarget(self, action: #selector(showRealFrame), for: .touchUpInside)
        ownerButton.addTarget(self, action: #selector(alertForOwner), for: .touchUpInside)
        personImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openProfile)))
        topView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openProfile)))
    }
    
    func setupConstreintsForCard() {
        self.contentView.addSubview(cardView)
        cardView.addSubview(postsImageView)
        cardView.addSubview(postTextView)
        cardView.addSubview(fullTextButton)
        cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: PostCellConstants.cardViewSideInset).isActive = true
        cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -PostCellConstants.cardViewSideInset).isActive = true
        cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -PostCellConstants.cardViewBottonInset).isActive = true
        cardView.topAnchor.constraint(equalTo: topAnchor).isActive = true
    }
    
    //Constreints topView
    func setupConstreintsForTopView() {
        cardView.addSubview(topView)
        topView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: PostCellConstants.heightTopView).isActive = true
        topView.topAnchor.constraint(equalTo: cardView.topAnchor).isActive = true
    }
    
    func setupConstreintsForIconImage() {
        topView.addSubview(personImage)
        personImage.heightAnchor.constraint(equalToConstant: PostCellConstants.userImageHeight).isActive = true
        personImage.widthAnchor.constraint(equalToConstant: PostCellConstants.userImageHeight).isActive = true
        personImage.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: PostCellConstants.contentInset).isActive = true
        personImage.topAnchor.constraint(equalTo: topView.topAnchor, constant: 8).isActive = true
    }
    
    func setupConstreintsForNameLabel() {
        topView.addSubview(nameLabel)
        nameLabel.trailingAnchor.constraint(equalTo: ownerButton.leadingAnchor, constant: -PostCellConstants.contentInset).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: personImage.trailingAnchor, constant: 8).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 14).isActive = true
    }
    
    func setupConstreintsForDateLabel() {
        topView.addSubview(dateLabel)
        dateLabel.trailingAnchor.constraint(equalTo: ownerButton.leadingAnchor, constant: -8).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: personImage.trailingAnchor, constant: 8).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -14).isActive = true
    }
    
    func setupConstreintsForOnlineImageView() {
        topView.addSubview(onlineImageView)
        onlineImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        onlineImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        onlineImageView.bottomAnchor.constraint(equalTo: personImage.bottomAnchor, constant: 0).isActive = true
        onlineImageView.trailingAnchor.constraint(equalTo: personImage.trailingAnchor, constant: 0).isActive = true
    }
    
    func setupConstreintsForOwnerButton() {
        topView.addSubview(ownerButton)
        ownerButton.heightAnchor.constraint(equalToConstant: PostCellConstants.menuButtonHeight).isActive = true
        ownerButtonWidthConstreint = ownerButton.widthAnchor.constraint(equalToConstant: 0)
        ownerButtonWidthConstreint.isActive = true
        ownerButton.centerYAnchor.constraint(equalTo: topView.centerYAnchor).isActive = true
        ownerButton.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -PostCellConstants.contentInset).isActive = true
    }
    
    func setupConstreintsForBottonView() {
        cardView.addSubview(bottonView)
        
        bottonViewTopConstraint = bottonView.topAnchor.constraint(equalTo: postsImageView.bottomAnchor)
        bottonViewTopConstraint.isActive = true
        bottonView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor).isActive = true
        bottonView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor).isActive = true
        bottonView.heightAnchor.constraint(equalToConstant: PostCellConstants.heightButtonView).isActive = true
        bottonView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
    }
    
    func setupConstreintsForLikesView() {
        bottonView.addSubview(likesView)
        likesView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        likesView.leadingAnchor.constraint(equalTo: bottonView.leadingAnchor, constant: PostCellConstants.contentInset - 2).isActive = true
        likesView.topAnchor.constraint(equalTo: bottonView.topAnchor).isActive = true
        likesView.bottomAnchor.constraint(equalTo: bottonView.bottomAnchor).isActive = true
    }
    
    func setupConstreintsForLikes() {
        likesView.addSubview(likeButton)
        likesView.addSubview(likesCountLabel)
            //image.tintColor = .red
        likeButton.widthAnchor.constraint(equalToConstant: 26).isActive = true
        likeButton.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        likeButton.centerYAnchor.constraint(equalTo: likesView.centerYAnchor).isActive = true
        likeButton.leadingAnchor.constraint(equalTo: likesView.leadingAnchor).isActive = true
        likesCountLabel.centerYAnchor.constraint(equalTo: likesView.centerYAnchor).isActive = true
        likesCountLabel.leadingAnchor.constraint(equalTo: likeButton.trailingAnchor,constant: 3).isActive = true
        likesCountLabel.trailingAnchor.constraint(equalTo: likesView.trailingAnchor).isActive = true
    }
}
