import UIKit

/// A "title over value" row used on the detail screen. Optionally tappable with a chevron.
final class DetailRowView: UIView {
    private let titleLabel = UILabel()
    private let valueLabel = UILabel()
    private var onTap: (() -> Void)?

    init(title: String, value: String, onTap: (() -> Void)? = nil) {
        self.onTap = onTap
        super.init(frame: .zero)

        titleLabel.text = title.uppercased()
        titleLabel.font = .preferredFont(forTextStyle: .caption1)
        titleLabel.textColor = .secondaryLabel

        valueLabel.text = value
        valueLabel.font = .preferredFont(forTextStyle: .body)
        valueLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [textStack])
        row.alignment = .center
        row.spacing = 8
        row.isLayoutMarginsRelativeArrangement = true
        row.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor),
            row.bottomAnchor.constraint(equalTo: bottomAnchor),
            row.leadingAnchor.constraint(equalTo: leadingAnchor),
            row.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        backgroundColor = .secondarySystemGroupedBackground
        layer.cornerRadius = 12

        if onTap != nil {
            let hint = UILabel()
            hint.text = "Weather"
            hint.font = .preferredFont(forTextStyle: .footnote)
            hint.textColor = .tintColor
            let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
            chevron.tintColor = .tintColor
            row.addArrangedSubview(UIView())
            row.addArrangedSubview(hint)
            row.addArrangedSubview(chevron)
            addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
            isAccessibilityElement = true
            accessibilityTraits = .button
            accessibilityLabel = "\(title), \(value)"
            accessibilityHint = "Shows the weather at this address"
        }
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    @objc private func tapped() { onTap?() }
}
