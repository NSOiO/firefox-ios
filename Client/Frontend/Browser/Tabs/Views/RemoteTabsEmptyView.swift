// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import ComponentLibrary
import UIKit
import Shared

class RemoteTabsEmptyView: UIView, ThemeApplicable {
    struct UX {
        static let verticalPadding: CGFloat = 40
        static let horizontalPadding: CGFloat = 24
        static let paddingInBetweenItems: CGFloat = 15
        static let buttonCornerRadius: CGFloat = 13
        static let titleSizeFont: CGFloat = 22
        static let descriptionSizeFont: CGFloat = 17
        static let buttonSizeFont: CGFloat = 16
        static let imageSize = CGSize(width: 90, height: 60)
        static let buttonVerticalInset: CGFloat = 12
    }

    weak var delegate: RemotePanelDelegate?

    // MARK: - UI

    private lazy var stackView: UIStackView = .build { stackView in
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = UX.paddingInBetweenItems
        stackView.alignment = .center
    }

    private let emptyStateImageView: UIImageView = .build { imageView in
        imageView.contentMode = .scaleAspectFit
    }

    private let titleLabel: UILabel = .build { label in
        label.adjustsFontForContentSizeCategory = true
        label.font = DefaultDynamicFontHelper.preferredFont(withTextStyle: .title2,
                                                            size: UX.titleSizeFont)
        label.numberOfLines = 0
        label.textAlignment = .center
    }

    private let instructionsLabel: UILabel = .build { label in
        label.adjustsFontForContentSizeCategory = true
        label.font = DefaultDynamicFontHelper.preferredFont(withTextStyle: .body,
                                                            size: UX.descriptionSizeFont)
        label.numberOfLines = 0
        label.textAlignment = .center
    }

    private let signInButton: LegacyResizableButton = .build { button in
        button.titleLabel?.font = DefaultDynamicFontHelper.preferredFont(withTextStyle: .callout,
                                                                         size: UX.buttonSizeFont)
        button.setTitle(.Settings.Sync.ButtonTitle, for: [])
        button.layer.cornerRadius = UX.buttonCornerRadius
        button.contentEdgeInsets = UIEdgeInsets(top: UX.buttonVerticalInset,
                                                left: UX.buttonVerticalInset,
                                                bottom: UX.buttonVerticalInset,
                                                right: UX.buttonVerticalInset)
        button.accessibilityIdentifier = AccessibilityIdentifiers.TabTray.syncDataButton
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(state: RemoteTabsPanelEmptyStateReason,
                   delegate: RemotePanelDelegate?) {
        self.delegate = delegate

        emptyStateImageView.image = UIImage.templateImageNamed(ImageIdentifiers.emptySyncImageName)
        titleLabel.text =  .EmptySyncedTabsPanelStateTitle
        instructionsLabel.text = state.localizedString()

        // Show signIn button only for notLoggedIn case
        if state == .notLoggedIn || state == .syncDisabledByUser {
            signInButton.isHidden = false
            signInButton.addTarget(self, action: #selector(presentSignIn), for: .touchUpInside)
        }
    }

    private func setupLayout() {
        stackView.addArrangedSubview(emptyStateImageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(instructionsLabel)
        stackView.addArrangedSubview(signInButton)
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                               constant: UX.horizontalPadding),
            stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: self.topAnchor,
                                           constant: UX.verticalPadding),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                constant: -UX.horizontalPadding),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                              constant: -UX.verticalPadding).priority(.defaultLow),
            signInButton.leadingAnchor.constraint(equalTo: instructionsLabel.leadingAnchor),
            signInButton.trailingAnchor.constraint(equalTo: instructionsLabel.trailingAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: UX.imageSize.width),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: UX.imageSize.height),
        ])
    }

    func applyTheme(theme: Theme) {
        emptyStateImageView.tintColor = theme.colors.textPrimary
        titleLabel.textColor = theme.colors.textPrimary
        instructionsLabel.textColor = theme.colors.textPrimary
        signInButton.setTitleColor(theme.colors.textInverted, for: .normal)
        signInButton.backgroundColor = theme.colors.actionPrimary
        backgroundColor = theme.colors.layer3
    }

    @objc
    private func presentSignIn() {
        if let delegate = self.delegate {
            TelemetryWrapper.recordEvent(category: .action, method: .tap, object: .syncSignIn)
            delegate.remotePanelDidRequestToSignIn()
        }
    }
}
