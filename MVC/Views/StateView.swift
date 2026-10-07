import UIKit

/// Full-screen overlay for loading / empty / error states, shared by every screen.
final class StateView: UIView {
    enum State {
        case hidden
        case loading
        case message(symbol: String, text: String, actionTitle: String?)
    }

    var onAction: (() -> Void)?

    private let spinner = UIActivityIndicatorView(style: .large)
    private let imageView = UIImageView()
    private let label = UILabel()
    private let button = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.tintColor = .tertiaryLabel
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 44)
        label.font = .preferredFont(forTextStyle: .body)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        button.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [spinner, imageView, label, button])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32)
        ])
        render(.hidden)
        
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    func render(_ state: State) {
        switch state {
        case .hidden:
            isHidden = true
            spinner.stopAnimating()
        case .loading:
            isHidden = false
            spinner.startAnimating()
            imageView.isHidden = true
            label.isHidden = true
            button.isHidden = true
        case let .message(symbol, text, actionTitle):
            isHidden = false
            spinner.stopAnimating()
            imageView.image = UIImage(systemName: symbol)
            imageView.isHidden = false
            label.text = text
            label.isHidden = false
            button.setTitle(actionTitle, for: .normal)
            button.isHidden = actionTitle == nil
        }
    }

    @objc private func actionTapped() { onAction?() }
}
