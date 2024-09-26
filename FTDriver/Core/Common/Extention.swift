import UIKit

// Extension cho CGColor để khởi tạo từ mã hex
extension CGColor {
    static func fromHex(_ hex: String) -> CGColor {
        return UIColor(hex: hex).cgColor
    }
}

// Extension cho UIColor để khởi tạo từ mã hex
extension UIColor {
    convenience init(hex: String) {
        var hexFormatted: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexFormatted.hasPrefix("#") {
            hexFormatted.remove(at: hexFormatted.startIndex)
        }
        
        assert(hexFormatted.count == 6, "Mã màu hex không hợp lệ, cần phải có 6 ký tự.")
        
        var rgbValue: UInt64 = 0
        Scanner(string: hexFormatted).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
