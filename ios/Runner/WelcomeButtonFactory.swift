import Flutter
import UIKit

final class WelcomeButtonFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }

  func create(
    withFrame frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: Any?
  ) -> FlutterPlatformView {
    WelcomeButtonView(
      frame: frame, viewId: viewId,
      parameters: args as? [String: Any] ?? [:], messenger: messenger
    )
  }
}

private final class WelcomeButtonView: NSObject, FlutterPlatformView {
  private let button = WelcomeUIKitButton(type: .system)
  private let channel: FlutterMethodChannel
  private let blue = UIColor(red: 45 / 255, green: 82 / 255, blue: 124 / 255, alpha: 1)

  init(frame: CGRect, viewId: Int64, parameters: [String: Any], messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "habitacheck/welcome_button/\(viewId)", binaryMessenger: messenger
    )
    super.init()
    button.frame = frame
    button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
    if #available(iOS 13.4, *) {
      button.isPointerInteractionEnabled = true
    }
    configure(parameters)
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "configure", let parameters = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.configure(parameters)
      result(nil)
    }
  }

  func view() -> UIView { button }

  private func configure(_ parameters: [String: Any]) {
    let title = parameters["label"] as? String ?? ""
    let primary = parameters["primary"] as? Bool ?? false
    let fontSize = (parameters["fontSize"] as? NSNumber)?.doubleValue ?? 22
    let textScale = (parameters["textScale"] as? NSNumber)?.doubleValue ?? 1
    let font = UIFont.systemFont(
      ofSize: CGFloat(fontSize * textScale), weight: primary ? .medium : .regular
    )
    button.reduceMotion = parameters["reduceMotion"] as? Bool ?? false
    button.accessibilityLabel = title
    button.tintColor = blue
    // Flutter supplies the user's text scaling, avoiding double Dynamic Type scaling.
    button.titleLabel?.adjustsFontForContentSizeCategory = false
    button.titleLabel?.numberOfLines = 2
    button.titleLabel?.textAlignment = .center

    if #available(iOS 15.0, *) {
      var configuration: UIButton.Configuration = primary ? .filled() : .tinted()
      button.usesNativeGlass = false
      // Older Xcode versions retain UIKit fallback controls and can still build.
      #if compiler(>=6.2)
      if #available(iOS 26.0, *) {
        configuration = primary ? .prominentGlass() : .glass()
        button.usesNativeGlass = true
      }
      #endif
      configuration.title = title
      configuration.cornerStyle = .capsule
      configuration.buttonSize = .large
      configuration.baseForegroundColor = primary ? .white : blue
      if primary { configuration.baseBackgroundColor = blue }
      configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
      configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
        var outgoing = incoming
        outgoing.font = font
        return outgoing
      }
      if primary {
        configuration.image = UIImage(systemName: "arrow.right")
        configuration.imagePlacement = .trailing
        configuration.imagePadding = 16
        configuration.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(
          pointSize: CGFloat(fontSize), weight: .medium
        )
      }
      button.configuration = configuration
    } else {
      button.setTitle(title, for: .normal)
      button.titleLabel?.font = font
      button.setTitleColor(primary ? .white : blue, for: .normal)
      button.backgroundColor = primary ? blue : UIColor.white.withAlphaComponent(0.7)
      button.layer.borderColor = blue.cgColor
      button.layer.borderWidth = primary ? 0 : 1.2
      button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
    }
  }

  @objc private func tapped() {
    UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: 0.45)
    channel.invokeMethod("tap", arguments: nil)
  }

  deinit { channel.setMethodCallHandler(nil) }
}

private final class WelcomeUIKitButton: UIButton {
  var usesNativeGlass = false
  var reduceMotion = false

  override func layoutSubviews() {
    super.layoutSubviews()
    if #available(iOS 15.0, *) { return }
    layer.cornerRadius = bounds.height / 2
  }

  override var isHighlighted: Bool {
    didSet {
      // iOS 26 owns the Liquid Glass touch animation; don't stack another on it.
      guard !usesNativeGlass else { return }
      guard !reduceMotion, !UIAccessibility.isReduceMotionEnabled else {
        layer.removeAllAnimations()
        transform = .identity
        return
      }
      let target = isHighlighted ? CGAffineTransform(scaleX: 0.975, y: 0.975) : .identity
      UIView.animate(
        withDuration: isHighlighted ? 0.10 : 0.28,
        delay: 0,
        usingSpringWithDamping: 0.72,
        initialSpringVelocity: 0,
        options: [.beginFromCurrentState, .allowUserInteraction],
        animations: { self.transform = target }
      )
    }
  }
}
