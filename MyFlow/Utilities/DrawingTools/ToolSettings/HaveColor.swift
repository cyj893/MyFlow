//
//  HaveColor.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/04/19.
//

import UIKit


struct HaveColorConstants {
    static let spacing: CGFloat = 16.0
    static let cellWidth: CGFloat = 30.0
    static let cellRadius: CGFloat = 5.0
    static let selectedBorderOffset: CGFloat = 3.0
    static let borderWidth: CGFloat = 1.0
}


protocol HaveColor: ToolSettings, AnyObject {
    var colorRadioButtons: RadioButtons? { get set }
    
    func getColorSetting() -> UIView
}


extension HaveColor {
    func getColorSetting() -> UIView {
        colorRadioButtons = RadioButtons(with: getRadioButtonComponents(with: getCells()), defaultID: DynamicUserDefaults.toolColorSelectedIndexSetting.get(id)) { [unowned self] index in
            DynamicUserDefaults.toolColorSelectedIndexSetting.set(id, index)
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = HaveColorConstants.spacing
        
        colorRadioButtons?.buttons.forEach { subview in
            subview.snp.makeConstraints { make in
                make.width.height.equalTo(HaveColorConstants.cellWidth)
            }
            stackView.addArrangedSubview(subview)
        }
        
        return stackView
    }
    
    private func getCells() -> [UIView] {
        return MyDrawingTool.defaultColors.indices.map { makeDefaultCell($0) } + [makeColorWell()]
    }
    
    private func getRadioButtonComponents(with views: [UIView]) -> [RadioComponetWrapperView] {
        return views.enumerated().map { (index, subview) in
            return RadioComponetWrapperView(id: index, subview: subview) { [unowned self] in
                DynamicUserDefaults.toolColorSetting.set(id,
                                                         0..<4 ~= index
                                                         ? MyDrawingTool.defaultColors[index]
                                                         : DynamicUserDefaults.toolColorwellSetting.get(id))
                DynamicUserDefaults.toolColorSelectedIndexSetting.set(id, index)
                subview.layer.offsetBorder(frame: CGRect(origin: .zero,
                                                         size: CGSize(width: HaveColorConstants.cellWidth,
                                                                      height: HaveColorConstants.cellWidth)),
                                           borderOffset: HaveColorConstants.selectedBorderOffset,
                                           borderWidth: HaveColorConstants.borderWidth,
                                           cornerRadius: HaveColorConstants.cellRadius)
            } deselectClosure: {
                subview.layer.sublayers?.forEach { sublayer in
                    if sublayer.name == "offsetBorder" {
                        sublayer.removeFromSuperlayer()
                    }
                }
            }
        }
    }
    
    private func makeColorWell() -> UIColorWell {
        let colorWell = UIColorWell(frame: .zero)
        colorWell.title = "Stroke Color"
        colorWell.selectedColor = UIColor(rgb: DynamicUserDefaults.toolColorwellSetting.get(id))
        colorWell.supportsAlpha = false
        colorWell.addAction(for: .valueChanged) { [unowned self] in
            DynamicUserDefaults.toolColorwellSetting.set(self.id, colorWell.selectedColor?.toInt() ?? 0)
            DynamicUserDefaults.toolColorSetting.set(self.id, colorWell.selectedColor?.toInt() ?? 0)
        }
        return colorWell
    }
    
    private func makeDefaultCell(_ index: Int) -> UIView {
        let cell = UIView()
        cell.backgroundColor = UIColor(rgb: MyDrawingTool.defaultColors[index])
        cell.layer.cornerRadius = HaveColorConstants.cellRadius
        cell.layer.borderColor = MyColor.icon.cgColor
        cell.layer.borderWidth = HaveColorConstants.borderWidth
        return cell
    }
    
}
