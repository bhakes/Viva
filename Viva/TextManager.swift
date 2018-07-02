import Foundation
import ARKit

enum MessageType {
	case trackingStateEscalation
	case planeEstimation
	case contentPlacement
	case focusSquare
}

class TextManager {
    
    let messagePanel = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let messageLabel = UILabel()
    private let debugMessageLabel = UILabel()
    private let featurePointCountLabel = UILabel()

    init(viewController: ARViewController) {
		self.viewController = viewController
        
        messagePanel.layer.cornerRadius = 8.0
        messagePanel.clipsToBounds = true
        messageLabel.font = .preferredFont(forTextStyle: .footnote)
        debugMessageLabel.font = .preferredFont(forTextStyle: .footnote)
        featurePointCountLabel.font = .preferredFont(forTextStyle: .footnote)
        
        viewController.view.addSubview(messagePanel)
        messagePanel.translatesAutoresizingMaskIntoConstraints = false
        messagePanel.topAnchor.constraint(equalTo: viewController.view.layoutMarginsGuide.topAnchor, constant: 8).isActive = true
        messagePanel.leftAnchor.constraint(equalTo: viewController.view.layoutMarginsGuide.leftAnchor).isActive = true
        messagePanel.rightAnchor.constraint(equalTo: viewController.view.layoutMarginsGuide.rightAnchor).isActive = true
        
        let v1 = UIView()
        messagePanel.contentView.addSubview(v1)
        v1.translatesAutoresizingMaskIntoConstraints = false
        v1.topAnchor.constraint(equalTo: messagePanel.contentView.topAnchor).isActive = true
        v1.bottomAnchor.constraint(equalTo: messagePanel.contentView.bottomAnchor).isActive = true
        v1.leftAnchor.constraint(equalTo: messagePanel.contentView.leftAnchor).isActive = true
        v1.rightAnchor.constraint(equalTo: messagePanel.contentView.rightAnchor).isActive = true
        
        let ev = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .extraLight)))
        v1.addSubview(ev)
        ev.translatesAutoresizingMaskIntoConstraints = false
        ev.topAnchor.constraint(equalTo: v1.topAnchor).isActive = true
        ev.bottomAnchor.constraint(equalTo: v1.bottomAnchor).isActive = true
        ev.leftAnchor.constraint(equalTo: v1.leftAnchor).isActive = true
        ev.rightAnchor.constraint(equalTo: v1.rightAnchor).isActive = true
        
        let v2 = UIView()
        ev.contentView.addSubview(v2)
        v2.translatesAutoresizingMaskIntoConstraints = false
        v2.topAnchor.constraint(equalTo: ev.contentView.topAnchor).isActive = true
        v2.bottomAnchor.constraint(equalTo: ev.contentView.bottomAnchor).isActive = true
        v2.leftAnchor.constraint(equalTo: ev.contentView.leftAnchor).isActive = true
        v2.rightAnchor.constraint(equalTo: ev.contentView.rightAnchor).isActive = true
        
        let stack: UIStackView = {
            let v = UIStackView()
            v.axis = .vertical
            v.distribution = .fill
            v.alignment = .fill
            v.spacing = 4
            return v
        }()
        
        v2.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: v2.layoutMarginsGuide.topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: v2.layoutMarginsGuide.bottomAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: v2.layoutMarginsGuide.leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: v2.layoutMarginsGuide.rightAnchor).isActive = true
        
        stack.addArrangedSubview(messageLabel)
        stack.addArrangedSubview(debugMessageLabel)
        stack.addArrangedSubview(featurePointCountLabel)
        
        messageLabel.isHidden = true
        debugMessageLabel.isHidden = true
        featurePointCountLabel.isHidden = true
        updateMessagePanelVisibility()
	}

	func showFeaturePointsText(_ text: String) {
        guard viewController.showDebugVisuals else {
            return
        }
        
		featurePointCountLabel.text = text
        
        showHideFeaturePoints(hide: false, animated: true)
	}
    
    func showMessage(_ text: String, autoHide: Bool = true) {
        messageHideTimer?.invalidate()
        
        messageLabel.text = text
        
        showHideMessage(hide: false, animated: true)
        
        if autoHide {
            let charCount = text.count
            let displayDuration: TimeInterval = min(10, Double(charCount) / 15.0 + 1.0)
            messageHideTimer = Timer.scheduledTimer(withTimeInterval: displayDuration,
                                                    repeats: false,
                                                    block: { [weak self] ( _ ) in
                                                        self?.showHideMessage(hide: true, animated: true)
            })
        }
    }

	func showDebugMessage(_ message: String) {
		guard viewController.showDebugVisuals else {
			return
		}

		debugMessageHideTimer?.invalidate()

		debugMessageLabel.text = message

		showHideDebugMessage(hide: false, animated: true)

		let charCount = message.count
		let displayDuration: TimeInterval = min(10, Double(charCount) / 15.0 + 1.0)
		debugMessageHideTimer = Timer.scheduledTimer(withTimeInterval: displayDuration,
		                                             repeats: false,
		                                             block: { [weak self] ( _ ) in
														self?.showHideDebugMessage(hide: true, animated: true)
		})
	}

	var schedulingMessagesBlocked = false

	func scheduleMessage(_ text: String, inSeconds seconds: TimeInterval, messageType: MessageType) {
		// Do not schedule a new message if a feedback escalation alert is still on screen.
		guard !schedulingMessagesBlocked else {
			return
		}

		var timer: Timer?
		switch messageType {
		case .contentPlacement: timer = contentPlacementMessageTimer
		case .focusSquare: timer = focusSquareMessageTimer
		case .planeEstimation: timer = planeEstimationMessageTimer
		case .trackingStateEscalation: timer = trackingStateFeedbackEscalationTimer
		}

		if timer != nil {
			timer!.invalidate()
			timer = nil
		}
		timer = Timer.scheduledTimer(withTimeInterval: seconds,
		                             repeats: false,
		                             block: { [weak self] ( _ ) in
										self?.showMessage(text)
										timer?.invalidate()
										timer = nil
		})
		switch messageType {
		case .contentPlacement: contentPlacementMessageTimer = timer
		case .focusSquare: focusSquareMessageTimer = timer
		case .planeEstimation: planeEstimationMessageTimer = timer
		case .trackingStateEscalation: trackingStateFeedbackEscalationTimer = timer
		}
	}

	func showTrackingQualityInfo(for trackingState: ARCamera.TrackingState, autoHide: Bool) {
		showMessage(trackingState.presentationString, autoHide: autoHide)
	}

	func escalateFeedback(for trackingState: ARCamera.TrackingState, inSeconds seconds: TimeInterval) {
		if self.trackingStateFeedbackEscalationTimer != nil {
			self.trackingStateFeedbackEscalationTimer!.invalidate()
			self.trackingStateFeedbackEscalationTimer = nil
		}

		self.trackingStateFeedbackEscalationTimer = Timer.scheduledTimer(withTimeInterval: seconds,
		                                                                 repeats: false, block: { _ in
			self.trackingStateFeedbackEscalationTimer?.invalidate()
			self.trackingStateFeedbackEscalationTimer = nil
			self.schedulingMessagesBlocked = true
			var title = ""
			var message = ""
			switch trackingState {
			case .notAvailable:
				title = "Tracking status: Not available."
				message = "Tracking status has been unavailable for an extended time. Try resetting the session."
			case .limited(let reason):
				title = "Tracking status: Limited."
				message = "Tracking status has been limited for an extended time. "
				switch reason {
				case .excessiveMotion: message += "Try slowing down your movement, or reset the session."
				case .insufficientFeatures: message += "Try pointing at a flat surface, or reset the session."
                case .initializing: message += "Initializing."
                case .relocalizing: message += "Relocalizing."
                }
			case .normal: break
			}

			let restartAction = UIAlertAction(title: "Reset", style: .destructive, handler: { _ in
                self.viewController.restartExperience(sender: nil)
				self.schedulingMessagesBlocked = false
			})
			let okAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
				self.schedulingMessagesBlocked = false
			})
			self.showAlert(title: title, message: message, actions: [restartAction, okAction])
		})
	}

	func cancelScheduledMessage(forType messageType: MessageType) {
		var timer: Timer?
		switch messageType {
		case .contentPlacement: timer = contentPlacementMessageTimer
		case .focusSquare: timer = focusSquareMessageTimer
		case .planeEstimation: timer = planeEstimationMessageTimer
		case .trackingStateEscalation: timer = trackingStateFeedbackEscalationTimer
		}

		if timer != nil {
			timer!.invalidate()
			timer = nil
		}
	}

	func cancelAllScheduledMessages() {
		cancelScheduledMessage(forType: .contentPlacement)
		cancelScheduledMessage(forType: .planeEstimation)
		cancelScheduledMessage(forType: .trackingStateEscalation)
		cancelScheduledMessage(forType: .focusSquare)
	}

	var alertController: UIAlertController?

	func showAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
		alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		if let actions = actions {
			for action in actions {
				alertController!.addAction(action)
			}
		} else {
			alertController!.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		}
		self.viewController.present(alertController!, animated: true, completion: nil)
	}

	func dismissPresentedAlert() {
		alertController?.dismiss(animated: true, completion: nil)
	}

	let blurEffectViewTag = 100

	func blurBackground() {
		let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		blurEffectView.frame = viewController.view.bounds
		blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		blurEffectView.tag = blurEffectViewTag
		viewController.view.addSubview(blurEffectView)
	}

	func unblurBackground() {
		for view in viewController.view.subviews {
			if let blurView = view as? UIVisualEffectView, blurView.tag == blurEffectViewTag {
				blurView.removeFromSuperview()
			}
		}
	}

	// MARK: - Private
	private var viewController: ARViewController!

	// Timers for hiding regular and debug messages
	private var messageHideTimer: Timer?
	private var debugMessageHideTimer: Timer?

	// Timers for showing scheduled messages
	private var focusSquareMessageTimer: Timer?
	private var planeEstimationMessageTimer: Timer?
	private var contentPlacementMessageTimer: Timer?

	// Timer for tracking state escalation
	private var trackingStateFeedbackEscalationTimer: Timer?

    private func showHideFeaturePoints(hide: Bool, animated: Bool) {
        if !animated {
            featurePointCountLabel.isHidden = hide
            return
        }
        
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       options: [.allowUserInteraction, .beginFromCurrentState],
                       animations: {
                        self.featurePointCountLabel.isHidden = hide
                        self.updateMessagePanelVisibility()
        }, completion: nil)
    }
    
    private func showHideMessage(hide: Bool, animated: Bool) {
		if !animated {
			messageLabel.isHidden = hide
			return
		}

		UIView.animate(withDuration: 0.2,
		               delay: 0,
		               options: [.allowUserInteraction, .beginFromCurrentState],
		               animations: {
						self.messageLabel.isHidden = hide
						self.updateMessagePanelVisibility()
		}, completion: nil)
	}

	private func showHideDebugMessage(hide: Bool, animated: Bool) {
		if !animated {
			debugMessageLabel.isHidden = hide
			return
		}

		UIView.animate(withDuration: 0.2,
		               delay: 0,
		               options: [.allowUserInteraction, .beginFromCurrentState],
		               animations: {
						self.debugMessageLabel.isHidden = hide
						self.updateMessagePanelVisibility()
		}, completion: nil)
	}

	private func updateMessagePanelVisibility() {
		// Show and hide the panel depending whether there is something to show.
		messagePanel.isHidden = messageLabel.isHidden &&
			debugMessageLabel.isHidden &&
			featurePointCountLabel.isHidden
	}
}
