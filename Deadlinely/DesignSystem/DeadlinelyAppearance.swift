import SwiftUI
import UIKit

/// Global UIKit styling so controls stay readable on white surfaces when the device uses Dark Mode.
enum DeadlinelyAppearance {
    static func configure() {
        let textPrimary = UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1)
        let background = UIColor.white
        let tint = UIColor(red: 0.22, green: 0.52, blue: 0.98, alpha: 1)
        let green = UIColor(red: 0.34, green: 0.78, blue: 0.42, alpha: 1)
        let border = UIColor(red: 0.90, green: 0.91, blue: 0.92, alpha: 1)

        UITextField.appearance().defaultTextAttributes = [
            .foregroundColor: textPrimary,
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
        ]
        UITextField.appearance().tintColor = tint
        UITextField.appearance().backgroundColor = background

        UITextView.appearance().backgroundColor = background
        UITextView.appearance().textColor = textPrimary
        UITextView.appearance().tintColor = tint

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = background
        nav.shadowColor = border
        nav.titleTextAttributes = [.foregroundColor: textPrimary]
        nav.largeTitleTextAttributes = [.foregroundColor: textPrimary]

        let barButton = UIBarButtonItemAppearance()
        barButton.normal.titleTextAttributes = [.foregroundColor: tint]
        nav.buttonAppearance = barButton
        nav.doneButtonAppearance = barButton
        nav.backButtonAppearance = barButton

        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = tint

        UIBarButtonItem.appearance().tintColor = tint

        UITableView.appearance().backgroundColor = background
        UITableViewCell.appearance().backgroundColor = background
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self]).textColor = textPrimary

        UICollectionView.appearance().backgroundColor = background

        UISwitch.appearance().onTintColor = green

        UIDatePicker.appearance().tintColor = tint

        UISegmentedControl.appearance().selectedSegmentTintColor = tint
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: textPrimary],
            for: .normal
        )
        UISegmentedControl.appearance().setTitleTextAttributes(
            [.foregroundColor: UIColor.white],
            for: .selected
        )

    }
}
