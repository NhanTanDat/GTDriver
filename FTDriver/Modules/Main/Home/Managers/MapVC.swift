import UIKit
import SocketIO
import CoreLocation
import SwiftyJSON
import MapboxNavigation
import MapboxMaps
import SwiftGifOrigin
protocol EndPoint {
    var url: String { get }
    var errorCode: String { get }
}

class MapVC: UIViewController ,CLLocationManagerDelegate{
     var manager: SocketManager!
     var socket: SocketIOClient!
    private var navigationMapView: NavigationMapView!
    private var cornerView: UIView!
    private var textStatus: UILabel!
    private var redDot: UIView!
    
    private let locationManager = CLLocationManager()
    private var lastLocation: CLLocation?
    private let updateDistance: CLLocationDistance = 200 // 200 mét
    private lazy var trackingButton = UIButton(frame: .zero)
    private lazy var avatar = UIButton(frame: .zero)
    private lazy var statusFrame = UIView(frame: .zero)
    private lazy var showdowButton = UIButton(frame: .zero)
    private var status: UILabel!
    private var isStatusWork : Bool = false
    
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        navigationMapView = NavigationMapView(frame: view.bounds)
        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        view.addSubview(navigationMapView)
        // Ẩn la bàn bằng cách sử dụng các tùy chọn của ViewportDataSource
               if let mapView = navigationMapView.mapView {
                   mapView.ornaments.options.compass.visibility = .hidden
               }
        // Khởi tạo cornerView với kích thước 40x40
        cornerView = UIView()
        cornerView.backgroundColor = .white  // Màu nền chỉ để dễ nhìn thấy
        cornerView.layer.cornerRadius = 19
        cornerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cornerView)
        
        
        setupAvatarButton()
        setupStatusButton()
        setupTrackingButton()
        setupShutdowButton()
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Hoặc requestAlwaysAuthorization nếu cần theo dõi khi ứng dụng không hoạt động
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        
       
        manager = SocketManager(socketURL: URL(string: "http://192.168.1.44:5001")!, config: [.log(false), .compress,.forcePolling(true)])
            socket = manager.defaultSocket

           // Xử lý khi kết nối thành công
           socket.on(clientEvent: .connect) { data, ack in
               print("------------ Socket connected -------------")
           }

           // Nhận dữ liệu vị trí từ server
           socket.on("locationUpdate") { data, ack in
               if let locationData = data[0] as? [String: Any] {
                   if let latitude = locationData["latitude"] as? Double,
                      let longitude = locationData["longitude"] as? Double {
                       print("Driver is at latitude: \(latitude), longitude: \(longitude)")

                       // Cập nhật vị trí trên bản đồ nếu cần
                   }
               }
           }

           // Kết nối socket
        socket.connect()
        
        navigationMapView.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
               navigationMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
               navigationMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
               navigationMapView.topAnchor.constraint(equalTo: view.topAnchor),
               navigationMapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
           ])
    }
    
    private func setupTrackingButton() {
        trackingButton.addTarget(self, action: #selector(switchTracking), for: .touchUpInside)
        trackingButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        trackingButton.backgroundColor = UIColor(white: 0.97, alpha: 1)
        trackingButton.layer.cornerRadius = 22
        trackingButton.layer.shadowOffset = CGSize(width: -1, height: 1)
        trackingButton.layer.shadowColor = UIColor.black.cgColor
        trackingButton.layer.shadowOpacity = 0.5
        view.addSubview(trackingButton)
        
        NSLayoutConstraint.activate([
            trackingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100),
            trackingButton.widthAnchor.constraint(equalToConstant: 44),
            trackingButton.heightAnchor.constraint(equalTo: trackingButton.widthAnchor)
        ])
    }

    @objc private func switchTracking() {
        if let userLocation = navigationMapView.mapView.location.latestLocation {
            let userCoordinate = userLocation.coordinate
            navigationMapView.mapView.camera.ease(
                to: CameraOptions(center: userCoordinate, zoom: 17),
                duration: 1.3)
        }
    }
    
    private func setupAvatarButton(){
//        avatar.addTarget(self, action: #selector(), for: .touchUpInside)
        avatar.setImage(UIImage(named: "ic_avatar_defaul"), for: .normal)
        avatar.translatesAutoresizingMaskIntoConstraints = false
        avatar.backgroundColor = UIColor(white: 0.97, alpha: 1)
        avatar.layer.cornerRadius = 22
        avatar.layer.shadowOffset = CGSize(width: -1, height: 1)
        avatar.layer.shadowColor = UIColor.black.cgColor
        avatar.layer.shadowOpacity = 0.5
        view.addSubview(avatar)
        
        NSLayoutConstraint.activate([
            avatar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            avatar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            avatar.widthAnchor.constraint(equalToConstant: 45),
            avatar.heightAnchor.constraint(equalTo: avatar.widthAnchor)
        ])
        
        
    }
    
    private func setupShutdowButton(){
        showdowButton.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        showdowButton.setImage(UIImage(named: "ic_shutdown"), for: .normal)
        showdowButton.translatesAutoresizingMaskIntoConstraints = false
        showdowButton.backgroundColor = .clear
        showdowButton.layer.cornerRadius = 22.5
        view.addSubview(showdowButton)
        
        NSLayoutConstraint.activate([
            showdowButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            showdowButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            showdowButton.widthAnchor.constraint(equalToConstant: 50),
            showdowButton.heightAnchor.constraint(equalTo: showdowButton.widthAnchor)
        ])
        
    }
    // Hành động khi nhấn vào nút
    @objc private func handleButtonTap() {
        let currentImage = showdowButton.image(for: .normal)
        if currentImage == UIImage(named: "ic_shutdown") {
           
            // Hiển thị loading khi bắt đầu tải
                showLoadingViewController()

                // Giả lập tải dữ liệu (delay 3 giây)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    // Ẩn loading view khi tải xong
                    self?.hideLoadingViewController()
                    self?.showdowButton.setImage(UIImage(named: "ic_shutdown_blu"), for: .normal)
                    self?.isStatusWork = true
                    self?.status.text = "Đang làm việc"
                    self?.status.textColor = UIColor(hex: "#0765FF")
                }
            
        } else {
           
            // Hiển thị loading khi bắt đầu tải
                showLoadingViewController()

                // Giả lập tải dữ liệu (delay 3 giây)
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    // Ẩn loading view khi tải xong
                    self?.hideLoadingViewController()
                    self?.showdowButton.setImage(UIImage(named: "ic_shutdown"), for: .normal)
                    self?.isStatusWork = false
                    self?.status.text = "Nghỉ ngơi"
                    self?.status.textColor = UIColor(hex: "#888888")
                }
        }
    }
    func showLoadingViewController() {
        let loadingVC = LoadingVC()
        loadingVC.modalPresentationStyle = .overFullScreen
        loadingVC.modalTransitionStyle = .crossDissolve
        present(loadingVC, animated: true, completion: nil)
    }

    func hideLoadingViewController() {
        dismiss(animated: true, completion: nil)
    }
  
    private func setupStatusButton() {
        // Cấu hình statusFrame
        statusFrame.backgroundColor = .white
        statusFrame.layer.cornerRadius = 8
        statusFrame.translatesAutoresizingMaskIntoConstraints = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showPopup))
        statusFrame.addGestureRecognizer(tapGesture)
        statusFrame.isUserInteractionEnabled = true
        view.addSubview(statusFrame)

        let name = UILabel()
        name.text = "Nguyễn Ngọc Đại Lợi"
        name.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        name.translatesAutoresizingMaskIntoConstraints = false
        statusFrame.addSubview(name)

        status = UILabel()
        status.text = self.isStatusWork ? "Đang làm việc" : "Nghỉ ngơi"
        status.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        status.textColor = self.isStatusWork ? UIColor(hex: "#0765FF") : UIColor(hex: "#888888")
        status.translatesAutoresizingMaskIntoConstraints = false
        statusFrame.addSubview(status)

        NSLayoutConstraint.activate([
            name.leadingAnchor.constraint(equalTo: statusFrame.leadingAnchor, constant: 16),
            name.topAnchor.constraint(equalTo: statusFrame.topAnchor, constant: 8),
            name.trailingAnchor.constraint(equalTo: statusFrame.trailingAnchor, constant: -16),
            
            status.leadingAnchor.constraint(equalTo: name.leadingAnchor),
            status.trailingAnchor.constraint(equalTo: name.trailingAnchor),
            status.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 4),
            status.bottomAnchor.constraint(equalTo: statusFrame.bottomAnchor, constant: -8),
            
            statusFrame.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: 9),
            statusFrame.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            statusFrame.widthAnchor.constraint(equalTo: name.widthAnchor, constant: 32),
            statusFrame.bottomAnchor.constraint(equalTo: status.bottomAnchor, constant: 8) // Add this line
        ])
    }

    @objc private func showPopup() {
        let popup = CustomPopup()
        popup.modalPresentationStyle = .overFullScreen
        popup.modalTransitionStyle = .crossDissolve
        popup.onClose = {
            print("Popup closed")
        }
        present(popup, animated: true, completion: nil)
    }

    // Delegate method to receive location updates
      func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
          guard let currentLocation = locations.last else { return }

          if let lastLocation = lastLocation {
              let distance = currentLocation.distance(from: lastLocation)
              if distance >= updateDistance {
                  // Cập nhật vị trí khi di chuyển 200 mét
                  updateDriverLocation(currentLocation: currentLocation)
                  // Cập nhật lastLocation
                  self.lastLocation = currentLocation
              }
          } else {
              // Lần đầu cập nhật lastLocation
              self.lastLocation = currentLocation
          }
      }
    // Hàm gửi tọa độ tài xế đến server
       func sendDriverLocation(latitude: Double, longitude: Double) {
           let locationData: [String: Any] = [
               "driverId": "driver123",
               "latitude": latitude,
               "longitude": longitude
           ]
           print("Vị trí đã được cập nhật: driverLocationUpdate", locationData)
           socket.emit("driverLocationUpdate", locationData)
       }
    private func updateDriverLocation(currentLocation: CLLocation) {
           let latitude = currentLocation.coordinate.latitude
           let longitude = currentLocation.coordinate.longitude
           
            let params: [String: Any] = [
                "id": "66dd7b30d3b55fee8ade8410",
                "latitude": latitude,
                "longitude": longitude
            ]
            let newEndpoint = URL(string: "http://192.168.1.44:5001/api/drivers/updatelocation")
            APIManager.requestAPI(endPoint: newEndpoint!,params: params, signatureHeader: true,vc: self, rawResult: false, customOtpHandler: nil) { dataJS, statusResult in
                DispatchQueue.main.async {
//                    print("Vị trí đã được cập nhật:", dataJS as Any)
                }
            }
        sendDriverLocation(latitude: latitude, longitude: longitude)

       }
}

