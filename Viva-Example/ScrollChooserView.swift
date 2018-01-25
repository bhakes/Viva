//
//  ScrollChooserView.swift
//  Viva-Example
//
//  Created by Txai Wieser on 28/10/17.
//

import Foundation
import UIKit

protocol ScrollChooserViewDelegate: class {
    func scrollChooser(_ scrollChoser: ScrollChooserView, didSelectButtonWithID id: Int)
}

final class ScrollChooserView: UIScrollView {
    weak var choserDelegate: ScrollChooserViewDelegate?
    let spacingWidth: CGFloat = 8
    let spacingHeight: CGFloat = 8
    var isToogleEnabled: Bool = false
    
    private let stack: UIStackView = {
        let v = UIStackView()
        v.alignment = .fill
        v.axis = .horizontal
        v.distribution = .fill
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        alwaysBounceHorizontal = true
        
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: leftAnchor, constant: spacingWidth).isActive = true
        stack.rightAnchor.constraint(equalTo: rightAnchor, constant: -spacingWidth).isActive = true
        stack.heightAnchor.constraint(equalTo: heightAnchor, constant: -2*spacingHeight).isActive = true
        
        stack.spacing = spacingWidth
        contentInset.top = spacingHeight
        contentInset.bottom = spacingHeight
    }
    
    func addButton(_ button: UIButton) {
        button.addTarget(self, action: #selector(buttonsInternalSelector), for: .touchUpInside)
        stack.addArrangedSubview(button)
    }
    
    func removeAllButons() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        contentOffset = .zero
    }
    
    func selectButton(id: Int) {
        guard let button = stack.arrangedSubviews[id] as? UIButton else { return }
        buttonsInternalSelector(sender: button)
    }
    
    var selectedButton: UIButton?
    @objc private func buttonsInternalSelector(sender: UIButton) {
        guard let id = stack.arrangedSubviews.index(of: sender) else { return }
        if isToogleEnabled {
            guard sender != selectedButton else { return }
            for v in stack.arrangedSubviews {
                if let b = (v as? UIButton) { b.isSelected = b == sender }
            }
            selectedButton = sender
        }
        
        choserDelegate?.scrollChooser(self, didSelectButtonWithID: id)
    }
}
