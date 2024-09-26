//
//  PopupSettingHomeVC.swift
//  FTDriver
//
//  Created by Tan Dat on 21/9/24.
//

import UIKit

class CustomPopup: UIViewController {
    var onClose: (() -> Void)?

    private let popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Đang làm việc"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Tự động nhận chuyến"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        return button
    }()
    
    
    private let toggleButton: UIImageView = {
        let img = UIImageView()
        img.translatesAutoresizingMaskIntoConstraints = false
        img.image = UIImage(named: "ic_toggle_a") // Set the image directly
        img.layer.cornerRadius = 20
        img.isUserInteractionEnabled = true // Enable user interaction
        return img
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        setupPopup()
    }

    private func setupPopup() {
        view.addSubview(popupView)
        popupView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(toggleButton)
        popupView.addSubview(titleLabel)
        popupView.addSubview(messageLabel)
        view.addSubview(closeButton)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -16),

            // Place messageLabel and toggleButton on the same row
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: toggleButton.leadingAnchor, constant: -10), // Space between messageLabel and toggleButton
            messageLabel.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -16),

            toggleButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -16),
            toggleButton.widthAnchor.constraint(equalToConstant: 51),
            toggleButton.heightAnchor.constraint(equalToConstant: 31),
            toggleButton.centerYAnchor.constraint(equalTo: messageLabel.centerYAnchor), // Center vertically with messageLabel

            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            popupView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.size.width - 32),

            closeButton.topAnchor.constraint(equalTo: popupView.bottomAnchor, constant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            closeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])


    }

    @objc private func closePopup() {
        dismiss(animated: true, completion: onClose)
    }
}
