import UIKit
import MapboxMaps
import MapboxNavigation
import MapboxDirections
import MapboxCoreNavigation

class ViewController: UIViewController,NavigationViewControllerDelegate {
        private var mapView: MapView!
       private var navigationMapView: NavigationMapView!
       private lazy var trackingButton = UIButton(frame: .zero)
       private lazy var navigateButton = UIButton(frame: .zero)
       private let simulationIsEnabled = true // Set this based on your app's state


    override func viewDidLoad() {
        super.viewDidLoad()

        navigationMapView = NavigationMapView(frame: view.bounds)
        navigationMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(navigationMapView)
        // Zoom đến vị trí hiện tại của người dùng khi map load xong
               
        // Setup tracking button
        setupTrackingButton()
        
        
        setupNavigateButton()
        // Ví dụ về cách vẽ tuyến đường trên bản đồ
        let coordinates: [CLLocationCoordinate2D] = [
                   CLLocationCoordinate2D(latitude: 10.816462, longitude: 106.713163),
                   CLLocationCoordinate2D(latitude: 10.816508, longitude: 106.713034),
                   CLLocationCoordinate2D(latitude: 10.824618, longitude: 106.714029),
                   CLLocationCoordinate2D(latitude: 10.825541, longitude: 106.714301),
                   CLLocationCoordinate2D(latitude: 10.825769, longitude: 106.714516),
                   CLLocationCoordinate2D(latitude: 10.826001, longitude: 106.714509),
                   CLLocationCoordinate2D(latitude: 10.826231, longitude: 106.714114),
                   CLLocationCoordinate2D(latitude: 10.826001, longitude: 106.713823),
                   CLLocationCoordinate2D(latitude: 10.825409, longitude: 106.711509),
                   CLLocationCoordinate2D(latitude: 10.825163, longitude: 106.71102),
                   CLLocationCoordinate2D(latitude: 10.820677, longitude: 106.694329),
                   CLLocationCoordinate2D(latitude: 10.819677, longitude: 106.690043),
                   CLLocationCoordinate2D(latitude: 10.82024, longitude: 106.689761),
                   CLLocationCoordinate2D(latitude: 10.820769, longitude: 106.689185),
                   CLLocationCoordinate2D(latitude: 10.821866, longitude: 106.68858),
                   CLLocationCoordinate2D(latitude: 10.820809, longitude: 106.687396),
                   CLLocationCoordinate2D(latitude: 10.821862, longitude: 106.686883)
               ]
        
        // Chuyển đổi tọa độ thành LineString
                let lineString = LineString(coordinates)

                // Tạo nguồn dữ liệu từ LineString
                var source = GeoJSONSource()
                source.data = .geometry(.lineString(lineString))

                // Tạo LineLayer để hiển thị đường trên bản đồ
                var lineLayer = LineLayer(id: "route-line-layer")
                lineLayer.source = "route-source"
                lineLayer.lineColor = .constant(StyleColor(.blue))
                lineLayer.lineWidth = .constant(3)

        // Sử dụng sự kiện delegate để thêm layer khi bản đồ đã tải xong
        navigationMapView.mapView.mapboxMap.onEvery(event: .styleLoaded) { [weak self] _ in
                   guard let self = self else { return }
                   do {
                       try self.navigationMapView.mapView.mapboxMap.style.addSource(source, id: "route-source")
                       try self.navigationMapView.mapView.mapboxMap.style.addLayer(lineLayer)
                   } catch {
                       print("Error adding source or layer: \(error)")
                   }
               }
    
    
    }
    private func setupNavigateButton() {
            navigateButton.setTitle("Bắt đầu", for: .normal)
            navigateButton.backgroundColor = UIColor.systemBlue
            navigateButton.setTitleColor(.white, for: .normal)
            navigateButton.addTarget(self, action: #selector(startNavigation), for: .touchUpInside)
            navigateButton.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(navigateButton)
            
            NSLayoutConstraint.activate([
                navigateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                navigateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
                navigateButton.widthAnchor.constraint(equalToConstant: 200),
                navigateButton.heightAnchor.constraint(equalToConstant: 44)
            ])
        }

    @objc private func startNavigation() {
        let origin = CLLocationCoordinate2D(latitude: 10.816462, longitude: 106.713163)
        let destination = CLLocationCoordinate2D(latitude: 10.821862, longitude: 106.686883)
        
        // Thiết lập tùy chọn chỉ đường với ngôn ngữ tiếng Việt
        let options = NavigationRouteOptions(coordinates: [origin, destination])
        options.locale = Locale(identifier: "vi")

        Directions.shared.calculate(options) { [weak self] (session, result) in
            switch result {
            case .failure(let error):
                print("Lỗi tính toán tuyến đường: \(error.localizedDescription)")
            case .success(let response):
                guard let route = response.routes?.first, let strongSelf = self else {
                    return
                }

                // Thiết lập lại ngôn ngữ cho chỉ đường (trong trường hợp cần thiết)
                let options = NavigationRouteOptions(coordinates: [origin, destination])
                options.locale = Locale(identifier: "vi")

                let indexedRouteResponse = IndexedRouteResponse(routeResponse: response, routeIndex: 0)
                
                let navigationService = MapboxNavigationService(indexedRouteResponse: indexedRouteResponse, customRoutingProvider: NavigationSettings.shared.directions, credentials: NavigationSettings.shared.directions.credentials, simulating: self!.simulationIsEnabled ? .always : .onPoorGPS)

                let navigationOptions = NavigationOptions(navigationService: navigationService)
                let navigationViewController = NavigationViewController(for: indexedRouteResponse.routeResponse, routeIndex: 0, routeOptions: options, navigationOptions: navigationOptions)
              
                navigationViewController.modalPresentationStyle = .fullScreen

                // Hiển thị phần đã đi qua của tuyến đường với độ trong suốt
                navigationViewController.routeLineTracksTraversal = true

                strongSelf.present(navigationViewController, animated: true, completion: nil)
            }
        }
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
            trackingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            trackingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            trackingButton.widthAnchor.constraint(equalToConstant: 44),
            trackingButton.heightAnchor.constraint(equalTo: trackingButton.widthAnchor)
        ])
    }

    @objc private func switchTracking() {
        if let userLocation = navigationMapView.mapView.location.latestLocation {
            let userCoordinate = userLocation.coordinate
            navigationMapView.mapView.camera.ease(
                to: CameraOptions(center: userCoordinate, zoom: 15),
                duration: 1.3)
        }
    }
    // MARK: - NavigationViewControllerDelegate
       func navigationViewControllerDidDismiss(_ navigationViewController: NavigationViewController, byCanceling canceled: Bool) {
           navigationViewController.dismiss(animated: true, completion: nil)
       }

       // Tắt đánh giá chuyến đi sau khi hoàn thành
       func navigationViewController(_ navigationViewController: NavigationViewController, didArriveAt destination: Waypoint) -> Bool {
           // Return true để thông báo đã đến nơi và tắt đánh giá
           return true
       }
}
