//
//  HaveColor.swift
//  MyFlow
//
//  Created by Yujin Cha on 2023/04/19.
//

import UIKit


protocol HaveColor: ToolSettings, AnyObject {
    var colorRadioButtons: RadioButtons? { get set }
    
    func getColorSetting() -> UIView
}


extension HaveColor {
    func getColorSetting() -> UIView {
        let views = getCells()
        let radioButtonComponents = getRadioButtonComponents(with: views)
        
        colorRadioButtons = RadioButtons(with: radioButtonComponents, defaultID: DynamicUserDefaults.toolColorSelectedIndexSetting.get(id)) { [unowned self] index in
            DynamicUserDefaults.toolColorSelectedIndexSetting.set(id, index)
        }
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8.0
        
        colorRadioButtons?.buttons.forEach { subview in
            stackView.addArrangedSubview(subview)
        }
        
        stackView.arrangedSubviews.forEach { subview in
            subview.snp.makeConstraints { make in
                make.width.height.equalTo(30.0)
            }
        }
        
        return stackView
    }
    
    private func getCells() -> [UIView] {
        var views = [UIView]()
        for i in MyDrawingTool.defaultColors.indices {
            views.append(makeDefaultCell(i))
        }
        views.append(makeColorWell())
        return views
    }
    
    private func getRadioButtonComponents(with views: [UIView]) -> [RadioComponetWrapperView] {
        return views.enumerated().map { (index, subview) in
            let radioComponent = RadioComponetWrapperView(id: index, subview: subview) { [unowned self] in
                if 0..<4 ~= index {
                    DynamicUserDefaults.toolColorSetting.set(id, MyDrawingTool.defaultColors[index])
                } else {
                    DynamicUserDefaults.toolColorSetting.set(id, DynamicUserDefaults.toolColorwellSetting.get(id))
                }
                DynamicUserDefaults.toolColorSelectedIndexSetting.set(id, index)
                subview.layer.offsetBorder(frame: CGRect(origin: .zero, size: CGSize(width: 30.0, height: 30.0)), borderOffset: 3.0, cornerRadius: 5.0)
            } deselectClosure: {
                for sublayer in subview.layer.sublayers ?? [] {
                    if sublayer.name == "offsetBorder" {
                        sublayer.removeFromSuperlayer()
                    }
                }
            }
            return radioComponent
        }
    }
    
    private func makeColorWell() -> UIColorWell {
        let colorWell = UIColorWell(frame: .zero)
        colorWell.title = "Stroke Color"
        colorWell.selectedColor = UIColor(rgb: DynamicUserDefaults.toolColorwellSetting.get(id))
        colorWell.supportsAlpha = false
        colorWell.addAction(for: .valueChanged) { [unowned self] in
            DynamicUserDefaults.toolColorwellSetting.set(id, colorWell.selectedColor?.toInt() ?? 0)
            DynamicUserDefaults.toolColorSetting.set(id, colorWell.selectedColor?.toInt() ?? 0)
        }
        return colorWell
    }
    
    private func makeDefaultCell(_ index: Int) -> UIView {
        let cell = UIView()
        cell.backgroundColor = UIColor(rgb: MyDrawingTool.defaultColors[index])
        cell.layer.cornerRadius = 5.0
        cell.layer.borderColor = MyColor.icon.cgColor
        cell.layer.borderWidth = 1.0
        return cell
    }
    
}
