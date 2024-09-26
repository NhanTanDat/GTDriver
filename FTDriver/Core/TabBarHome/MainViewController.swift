import UIKit
import SwiftGifOrigin

class MainViewController: UIViewController {
    private var tabBarView: UIStackView!
    private var containerView: UIView!
    private var tabButtons: [UIView] = []
    private var viewControllers: [Int: UIViewController] = [:]
    private var currentViewController: UIViewController?
    var imageDefaul: [String] = []
    var imageGif: [String] = []
    var imageSelected: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupContainerView()
        setupTabBarView()
        
        
        // Thêm các view controllers vào dictionary
        viewControllers[0] = MapVC()
        viewControllers[1] = HistoryVC()
        viewControllers[2] = NotificationsVC()
        viewControllers[3] = StatisticalVC()
        viewControllers[4] = MoreVC()
        
        // Mở tab đầu tiên
        switchToTab(0)
        updateTabButtonImage(for: tabButtons[0], isSelected: true)
        updateLabelColor(for: tabButtons[0], isSelected: true)
    }

    private func setupTabBarView() {
        
        imageDefaul = ["ic_home","ic_history","ic_bell","ic_wallet"]
        imageSelected = ["ic_home_blu","ic_history_blu","ic_bell_blu","ic_wallet_blu"]
        imageGif = ["ic_home_gif","ic_history_gif","ic_bell_gif","ic_wallet_gif"]
        
        // Tạo các nút tab
        let homeButton = createTabButton(title: "Trang Chủ", imageDefaul: imageDefaul[0], imageGif: imageGif[0], imageSelected: imageSelected[0], tag: 0)
        let homeHeightConstraint = homeButton.heightAnchor.constraint(equalToConstant: 60)
        homeHeightConstraint.priority = UILayoutPriority(250) // Giảm độ ưu tiên
        homeHeightConstraint.isActive = true

        
        let searchButton = createTabButton(title: "Lịch sử", imageDefaul: imageDefaul[1], imageGif: imageGif[1], imageSelected: imageSelected[1], tag: 1)
        let searchHeightConstraint = searchButton.heightAnchor.constraint(equalToConstant: 60)
        searchHeightConstraint.priority = UILayoutPriority(250) // Giảm độ ưu tiên
        searchHeightConstraint.isActive = true
        
        let profileButton = createTabButton(title: "Thông báo", imageDefaul: imageDefaul[2], imageGif: imageGif[2], imageSelected: imageSelected[2], tag: 2)
        let profileHeightConstraint = profileButton.heightAnchor.constraint(equalToConstant: 60)
        profileHeightConstraint.priority = UILayoutPriority(250) // Giảm độ ưu tiên
        profileHeightConstraint.isActive = true
        
        let statisticsButton = createTabButton(title: "Doanh thu", imageDefaul: imageDefaul[3], imageGif: imageGif[3], imageSelected: imageSelected[3], tag: 3)
        let statisticsHeightConstraint = statisticsButton.heightAnchor.constraint(equalToConstant: 60)
        statisticsHeightConstraint.priority = UILayoutPriority(250) // Giảm độ ưu tiên
        statisticsHeightConstraint.isActive = true
        
        tabButtons = [homeButton, statisticsButton, searchButton, profileButton]
        
        tabBarView = UIStackView(arrangedSubviews: tabButtons)
        tabBarView.backgroundColor = .white
        tabBarView.axis = .horizontal
        tabBarView.distribution = .fillEqually
        tabBarView.alignment = .top
        tabBarView.spacing = 0
        view.addSubview(tabBarView)
        
        // Layout TabBar
        tabBarView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = tabBarView.heightAnchor.constraint(equalToConstant: 60)
        heightConstraint.priority = UILayoutPriority(250) // Giảm độ ưu tiên
        
        NSLayoutConstraint.activate([
            tabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            heightConstraint
            
        ])
    }

    private func setupContainerView() {
        containerView = UIView()
        view.addSubview(containerView)
       
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    private func switchToTab(_ index: Int) {
        // Loại bỏ UIViewController hiện tại nếu có
        if let currentVC = currentViewController {
            currentVC.view.removeFromSuperview()
            currentVC.removeFromParent()
        }
        
        // Lấy hoặc tạo UIViewController từ dictionary
        guard let newViewController = viewControllers[index] else { return }
        
        // Thêm UIViewController mới vào containerView
        addChild(newViewController)
        containerView.addSubview(newViewController.view)
        newViewController.view.frame = containerView.bounds
        newViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newViewController.didMove(toParent: self)
        
        // Cập nhật currentViewController
        currentViewController = newViewController
    }

    private func createTabButton(title: String, imageDefaul: String, imageGif: String = "", imageSelected: String = "", tag: Int) -> UIView {
        let containerView = UIView()
        
        // Create and configure the UIImageView for the GIF
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageDefaul)
        
//        // Sử dụng GIF nếu có, nếu không thì dùng ảnh mặc định
//        if let gifImage = UIImage.gif(asset: imageGif) {
//            imageView.image = gifImage
//        } else {
//            
//        }
        
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        containerView.addSubview(imageView)
        
        // Create the title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 14) // Đặt kích thước chữ
        titleLabel.translatesAutoresizingMaskIntoConstraints = false // Enable Auto Layout
        containerView.addSubview(titleLabel)
        
        // Set up Auto Layout constraints for imageView
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8), // Adjusted for spacing
                imageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 32),
                imageView.heightAnchor.constraint(equalToConstant: 32)
            ])
            
            // Set up Auto Layout constraints for titleLabel
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6), // Spacing between image and title
                titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4), // Padding from left
                titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4), // Padding from right
                titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0),
                // Padding from bottom
                titleLabel.heightAnchor.constraint(equalToConstant: 20)
            ])

        // Set up Auto Layout constraints for containerView
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set tag for the container view
        containerView.tag = tag

        // Add a tap gesture recognizer to the container view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabButtonTapped(_:)))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true // Ensure the container view can receive touches
        
        return containerView
    }

    @objc private func tabButtonTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        
        for view in tabButtons {
            let isSelected = view == tappedView
            
            // Update label and image color
            updateTabButtonImage(for: view, isSelected: isSelected)
            updateLabelColor(for: view, isSelected: isSelected)
        }

        // Switch to the selected tab
        switchToTab(tappedView.tag)
    }

    private func updateLabelColor(for view: UIView, isSelected: Bool) {
        view.subviews.compactMap { $0 as? UILabel }.forEach { label in
            label.textColor = isSelected ? UIColor(hex: "0765FF") : .gray
        }
    }

    private func updateTabButtonImage(for view: UIView, isSelected: Bool) {
        view.subviews.compactMap { $0 as? UIImageView }.forEach { imageView in
            let tag = view.tag
            if isSelected {
                imageView.image = UIImage(named: imageSelected[tag])
            } else {
                imageView.image = UIImage(named: imageDefaul[tag])
            }
        }
    }
}
