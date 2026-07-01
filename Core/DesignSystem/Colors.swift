import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public extension Color {
    static var driftBackgroundPrimary: Color { Color(uiColor: .driftBackgroundPrimary) }
    static var driftBackgroundSecondary: Color { Color(uiColor: .driftBackgroundSecondary) }
    static var driftTextPrimary: Color { Color(uiColor: .driftTextPrimary) }
    static var driftTextSecondary: Color { Color(uiColor: .driftTextSecondary) }
    static var driftAccentPrimary: Color { Color(uiColor: .driftAccentPrimary) }
    static var driftAccentSecondary: Color { Color(uiColor: .driftAccentSecondary) }
    static var driftCardBackground: Color { Color(uiColor: .driftCardBackground) }
    static var driftBorderSubtle: Color { Color(uiColor: .driftBorderSubtle) }
    static var driftSuccess: Color { Color(uiColor: .driftSuccess) }
    static var driftWarning: Color { Color(uiColor: .driftWarning) }
    static var driftDestructive: Color { Color(uiColor: .driftDestructive) }
}

#if canImport(UIKit)
public extension UIColor {
    static let driftBackgroundPrimary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 1)
            : UIColor(red: 0.969, green: 0.953, blue: 0.921, alpha: 1)
    }

    static let driftBackgroundSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
            : UIColor(red: 0.953, green: 0.937, blue: 0.904, alpha: 1)
    }

    static let driftTextPrimary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.965, green: 0.958, blue: 0.948, alpha: 1)
            : UIColor(red: 0.117, green: 0.109, blue: 0.102, alpha: 1)
    }

    static let driftTextSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.74, green: 0.72, blue: 0.69, alpha: 1)
            : UIColor(red: 0.408, green: 0.378, blue: 0.349, alpha: 1)
    }

    static let driftAccentPrimary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.85, green: 0.31, blue: 0.28, alpha: 1)
            : UIColor(red: 0.694, green: 0.161, blue: 0.145, alpha: 1)
    }

    static let driftAccentSecondary = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.38, green: 0.68, blue: 0.62, alpha: 1)
            : UIColor(red: 0.247, green: 0.49, blue: 0.451, alpha: 1)
    }

    static let driftCardBackground = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.13, green: 0.13, blue: 0.14, alpha: 1)
            : UIColor(red: 1, green: 1, blue: 1, alpha: 0.92)
    }

    static let driftBorderSubtle = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1)
            : UIColor(red: 0.83, green: 0.79, blue: 0.74, alpha: 1)
    }

    static let driftSuccess = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.36, green: 0.72, blue: 0.47, alpha: 1)
            : UIColor(red: 0.266, green: 0.553, blue: 0.365, alpha: 1)
    }

    static let driftWarning = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.87, green: 0.67, blue: 0.32, alpha: 1)
            : UIColor(red: 0.773, green: 0.545, blue: 0.203, alpha: 1)
    }

    static let driftDestructive = UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.83, green: 0.36, blue: 0.33, alpha: 1)
            : UIColor(red: 0.71, green: 0.29, blue: 0.26, alpha: 1)
    }
}
#endif
