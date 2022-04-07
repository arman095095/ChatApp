//
//  SetupProfile.swift
//  diffibleData
//
//  Created by Arman Davidoff on 23.02.2020.
//  Copyright © 2020 Arman Davidoff. All rights reserved.
//

import UIKit
import SDWebImage
import FirebaseAuth
import RxSwift
import RxCocoa
import RxRelay


class SetupProfileViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let helloLabel = UILabel(text: "", font: UIFont.avenir26())
    private let imageView = UIImageView(image: UIImage(named: "people"))
    private let imageButton = UIButton(image: UIImage(named: "add")!)
    private let nameTextField = UITextField()
    private let nameLabel = UILabel(text: "Имя (видно всем)")
    private let infoTextField = UITextField()
    private let infoLabel = UILabel(text: "Информация о Вас")
    private let birthDayLabel = UILabel(text: "Дата рождения")
    private let birthDayTextfField = UITextField()
    private let countryCityLabel = UILabel(text: "Страна, Город")
    private let countryCityTextfField = UITextField()
    private let sexSegment = UISegmentedControl(items: ["Мужчина","Женщина"])
    private let sexLabel = UILabel(text: "Пол")
    private let birthDatePicker = UIDatePicker()
    private let enterButton = LoadButton(title: "", backgroundColor: .buttonDark(), titleColor: .mainWhite(), font: UIFont.avenir20(), shadow: false, cornerRaduis: 4, google: false, height: 60, activityColor: .white)
    private let setupProfileViewModel: SetupProfileViewModel
    private let dispose = DisposeBag()
    
    init(setupProfileViewModel: SetupProfileViewModel) {
        self.setupProfileViewModel = setupProfileViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupFirstPresentation()
        setupFirstResponders()
        setupScrollView()
        setupViews()
        setupConstreints()
        setupActions()
        addKeyboardObservers()
        addGesture()
        setupBinding()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageView.layer.cornerRadius = imageView.layer.frame.size.height/2
    }
    
    @objc private func setImage() {
        ImagePicker.present(viewController: self)
    }
    
    @objc func birthdayTapped() {
        birthDayTextfField.resignFirstResponder()
    }
    
    @objc private func enterTapped() {
        enterButton.loading()
        setupProfileViewModel.sendProfileInfo(userName: nameTextField.text, info: infoTextField.text, sex: sexSegment.titleForSegment(at: sexSegment.selectedSegmentIndex), userImage: imageView.image!, birthday: birthDayTextfField.text, countryCity: countryCityTextfField.text)
    }
}

//MARK: Setup ViewModel & Binding
private extension SetupProfileViewController {
    
    func setupBinding() {
        birthDatePicker.rx.date.changed.asDriver().drive(onNext: { [weak self] date in
            self?.birthDayTextfField.text = self?.setupProfileViewModel.dateDescription(date: date)
        }).disposed(by: dispose)
        
        setupProfileViewModel.city.asDriver().drive(onNext: { [weak self] city in
            if let _ = city {
                self?.countryCityTextfField.text = self?.setupProfileViewModel.cityDescription
            }
        }).disposed(by: dispose)
    }
    
    func setupViewModel() {
        
        setupProfileViewModel.failureHandler = { [weak self] error in
            guard let self = self else { return }
            if let _ = error as? ConnectionError {
                Alert.present(type: .connection)
            } else {
                Alert.present(type: .error,title: error.localizedDescription)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.enterButton.stop()
            }
        }
        
        if setupProfileViewModel.register {
            setupProfileViewModel.successHandler = { [weak self] muser in
                guard let self = self else { return }
                self.enterButton.stop()
                Alert.present(type: .success, title: "Вы прошли регистрацию до конца")
                let tabVC = Builder.shared.mainTabBarController(currentUser: muser)
                self.present(tabVC, animated: true, completion: nil)
            }
        } else {
            setupProfileViewModel.successHandler = { [weak self] muser in
                guard let self = self else { return }
                self.enterButton.stop()
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                } else {
                    self.dismiss(animated: true, completion: nil)
                }
                Alert.present(type: .success, title: "Данные вашего профиля изменены")
            }
        }
    }
}

//MARK: SetupUI
private extension SetupProfileViewController {
    
    func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
    }
    
    func setupActions() {
        enterButton.addTarget(self, action: #selector(enterTapped), for: .touchUpInside)
        imageButton.addTarget(self, action: #selector(setImage), for: .touchUpInside)
    }
    
    func setupFirstPresentation() {
        nameTextField.text = setupProfileViewModel.displayName
        infoTextField.text = setupProfileViewModel.info
        countryCityTextfField.text = setupProfileViewModel.countryCity
        birthDayTextfField.text = setupProfileViewModel.birthday
        birthDatePicker.date = setupProfileViewModel.birthdayDate
        sexSegment.selectedSegmentIndex = setupProfileViewModel.sexIndex
        if let photoURL = setupProfileViewModel.photoURL {
            imageView.sd_setImage(with: photoURL)
        }
    }
    
    func setupViews() {
        tabBarController?.tabBar.isHidden = true
        navigationItem.title = setupProfileViewModel.title
        helloLabel.text = setupProfileViewModel.titleLabel
        view.backgroundColor = .white
        contentView.backgroundColor = .white
        scrollView.backgroundColor = .white
        enterButton.label.text = setupProfileViewModel.buttonTitle
        helloLabel.textAlignment = .center
        helloLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.borderWidth = 1.3
        imageView.layer.borderColor = UIColor.buttonDark().cgColor
    }
    
    func setupConstreints() {
        let nameView = UIView(textField: nameTextField, label: nameLabel, spacing: 15)
        let infoView = UIView(textField: infoTextField, label: infoLabel, spacing: 15)
        let birthView = UIView(textField: birthDayTextfField, label: birthDayLabel, spacing: 15)
        let countryCityView = UIView(textField: countryCityTextfField, label: countryCityLabel, spacing: 15)
        let sexView = UIView(segment: sexSegment, label: sexLabel, spacing: 15)
        let imageButtonView = UIView(imageView: imageView, button: imageButton)
        let enterStack = UIStackView(arrangedSubviews: [nameView,infoView,birthView,countryCityView,sexView,enterButton], spacing: 15, axis: .vertical)
        
        contentView.addSubview(helloLabel)
        contentView.addSubview(imageButtonView)
        contentView.addSubview(enterStack)
        
        helloLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        helloLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 40).isActive = true
        
        imageButtonView.topAnchor.constraint(equalTo: helloLabel.bottomAnchor,constant: 15).isActive = true
        imageButtonView.leadingAnchor.constraint(equalTo: enterStack.leadingAnchor,constant: 70).isActive = true
        imageButtonView.trailingAnchor.constraint(equalTo: enterStack.trailingAnchor,constant: -30).isActive = true
        imageButtonView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        enterStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40).isActive = true
        enterStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40).isActive = true
        enterStack.topAnchor.constraint(equalTo: imageButtonView.bottomAnchor, constant: 15).isActive = true
        enterStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15).isActive = true
        enterStack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
}

//MARK: ImagePickerDelegate
extension SetupProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = (info[.editedImage] as! UIImage)
        setupProfileViewModel.photoChanged = true
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: Keyboard
private extension SetupProfileViewController {
    
    func setupFirstResponders() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(birthdayTapped))
        toolBar.setItems([doneButton], animated: true)
        birthDatePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            birthDatePicker.preferredDatePickerStyle = .wheels
        }
        birthDayTextfField.inputView = birthDatePicker
        birthDayTextfField.inputAccessoryView = toolBar
    }
    
    func addGesture() {
        scrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        countryCityTextfField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(countryCityTapped)))
    }
    
    @objc func countryCityTapped() {
        let vc = Builder.shared.countryListVC()
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboard(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        scrollView.contentSize.height = contentView.frame.height
        if notification.name == UIResponder.keyboardWillShowNotification {
            scrollView.contentOffset.y = keyboardHeight - 40
            scrollView.contentSize.height += keyboardHeight
        }
    }
}
