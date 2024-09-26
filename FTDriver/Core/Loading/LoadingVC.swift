//
//  LoadingView.swift
//  FTDriver
//
//  Created by Tan Dat on 21/9/24.
//

import UIKit
import SwiftGifOrigin

class LoadingVC: UIViewController {

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let gifImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        loadGif(named: "ic_loading_gif")
    }
    
    // Hàm này để load ảnh GIF
    private func loadGif(named: String) {
        gifImageView.image = UIImage.gif(asset: named)
    }
    
    private func setupView() {
        view.backgroundColor = UIColor.clear

        // Setup gifImageView
        gifImageView.contentMode = .scaleAspectFit
        view.addSubview(gifImageView)

        // Set constraints
        gifImageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Căn giữa gifImageView
            gifImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gifImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            gifImageView.widthAnchor.constraint(equalToConstant: 60),
            gifImageView.heightAnchor.constraint(equalToConstant: 60),

        ])
    }
}
