//
//  LayoutBuilder.swift
//  affina
//
//  Created by Dinh Le Trieu Duong on 03/01/2023.
//

import UIKit

class LayoutBuilder {
    static let shared = LayoutBuilder()
    
    private var setupModel: SetupModel?
    
    private init() {
        
    }
    
    func setSetupModel(_ model: SetupModel) {
        setupModel = model
    }
    
    func getSetupModel() -> SetupModel? {
        return setupModel
    }
    
    func getListSetupCardOrder() -> [ListSetupCardOrder] {
        return setupModel?.listCard?[0].listCardOrder ?? []
    }
    
    func getListSetupCoverImageProgram() -> [ListSetupCoverImageProgram] {
        return setupModel?.listCoverImageProgram ?? []
    }
    
    func getListSetupLogo() -> [ListSetupLogo] {
        return setupModel?.listLogo ?? []
    }
    
    func getlistIconBenefit() -> [ListSetupIconBenefit] {
        return setupModel?.listIconBenefit ?? []
    }
    
    func getListCard() -> [ListSetupCard] {
        return setupModel?.listCard ?? []
    }
    
    func getListImageClaim() -> [ListSetupImageClaim] {
        return setupModel?.listImageClaim ?? []
    }
    
    func getListFormClaim() -> [ListSetupFormClaim] {
        return setupModel?.listFormClaim ?? []
    }
    
    func getListIconFlexi() -> [ListSetupIconFlexi] {
        return setupModel?.listIconFlexi ?? []
    }
    func updateViewPos(view: UIView, field: ListSetupCardOrderField, designSize: CGSize) {
        view.translatesAutoresizingMaskIntoConstraints = true
        let x: CGFloat = field.ox != nil ? (field.ox!) / 100.0 * designSize.width : view.frame.origin.x
        let y: CGFloat = field.oy != nil ? (field.oy!) / 100.0 * designSize.height : view.frame.origin.y
        
        DispatchQueue.main.async {
            //        (view as? BaseLabel)?.customFont = "\(CardFieldFontEnum(rawValue: field.font ?? 1)?.font ?? "Raleway")-Regular-\(field.size ?? 14)"
            if let font = field.font {
                switch font {
                case 1:
                    (view as? UILabel)?.font = UIFont(name: "ArialMT", size: CGFloat(field.size ?? 13))
                case 2:
                    (view as? UILabel)?.font = UIFont(name: "ArialMT", size: CGFloat(field.size! - Int(5.5) ?? 13))
                case 0:
                    (view as? UILabel)?.font = UIFont(name: "TimesNewRomanPSMT", size: CGFloat(field.size ?? 13))
                default:
                    break
                }
            }
            //            view.sizeToFit()
            (view as? UILabel)?.textColor = .init(hex: field.color ?? "000000")
            view.isHidden = false
            view.frame.origin = .init(x: x, y: y)
        }
    }
    
    func createLabel(view: UIView, labelSize: CGSize, text: String?, field: ListSetupCardOrderField, designSize: CGSize) -> UILabel {
        let label = UILabel(frame: .init(x: 0, y: 0, width: labelSize.width, height: labelSize.height))
        view.addSubview(label)
        label.text = text
        updateViewPos(view: label, field: field, designSize: designSize)
        return label
    }
    
    func getListProviderCards(cardData: [CardModel]) -> [ListSetupCard] {
        let list = LayoutBuilder.shared.getListCard()
        var cards: [ListSetupCard] = []
        for item in list {
            if item.type == CardType.Provider.rawValue {
                cards.append(item)
            }
        }
        
        var editedCard: [ListSetupCard] = []
        
        for item in cardData {
            for card in cards {
                if card.majorID == item.majorId
                    && card.programTypeID == item.programTypeId
                    && card.companyID == item.companyProvider
                    && card.programID == item.programId
                    && (card.startTime != nil && card.startTime! <= item.contractObjectStartDate)
                    && (card.endTime == nil ? true : (card.endTime! >= item.contractObjectStartDate))
                {
                    editedCard.append(card)
                }
            }
        }
        return editedCard
    }
    
    func getListAffinaCards(cardData: [CardModel]) -> [ListSetupCard] {
        var affCards: [ListSetupCard] = []
        for item in getListCard() {
            if item.type == CardType.Affina.rawValue {
                affCards.append(item)
            }
        }
        
        var editedCard: [ListSetupCard] = []
        
        for item in cardData {
            for card in affCards {
                if card.majorID == item.majorId
                    && card.programTypeID == item.programTypeId
                    && card.companyID == item.companyProvider
                    && card.programID == item.programId
                    && (card.startTime != nil && card.startTime! <= item.contractObjectStartDate)
                    && (card.endTime == nil ? true : (card.endTime! >= item.contractObjectStartDate))
                {
                    editedCard.append(card)
                }
            }
        }
        return editedCard
    }
    
    func isAbleToApplyCardLayout(card: CardModel, layout: ListSetupCard) -> Bool {
        if layout.majorID == card.majorId
            && layout.programTypeID == card.programTypeId
            && layout.companyID == card.companyProvider
            && layout.programID == card.programId
            && (layout.startTime != nil && layout.startTime! <= card.contractObjectStartDate)
            && (layout.endTime == nil ? true : (layout.endTime! >= card.contractObjectStartDate))
        {
            return true
        }
        
        return false
    }
    
    func canUseFormClaim(formClaim: ListSetupFormClaim, model: CardModel) -> Bool {
        if formClaim.majorId == model.majorId,
           formClaim.companyId == model.companyProvider,
           formClaim.programTypeId == model.programTypeId,
           formClaim.programId == model.programId,
           let file = formClaim.file, !file.isEmpty {
            return true
        }
        return false
    }
    
    func canUseFormClaim(formClaim: ListSetupFormClaim, model: ClaimDetailModel) -> Bool {
        if formClaim.majorId == model.majorId,
           formClaim.companyId == model.companyId,
           formClaim.programTypeId == model.programTypeId,
           formClaim.programId == model.programId,
           let file = formClaim.file, !file.isEmpty {
            return true
        }
        return false
    }
    
    func canUseImageClaim(imageClaim: ListSetupImageClaim, cardModel: CardModel, claimType: ClaimType) -> Bool {
        if imageClaim.majorID == cardModel.majorId, imageClaim.programTypeID == cardModel.programTypeId, imageClaim.claimType == claimType.rawValue {
            return true
        }
        return false
    }
    
    func getCreatedLabel(_ fieldVariable: Int, view: UIView, labelSize: CGSize, item: CardModel?, field: ListSetupCardOrderField, designSize: CGSize) -> UILabel {
        switch fieldVariable {
        case CardFieldVariableEnum.PeopleName.rawValue:
//                            let label = UILabel(frame: .init(x: 0, y: 0, width: HomeInsuranceCardCell.size.width, height: 30))
//                            card.addSubview(label)
//                            label.text = item?.peopleName
//                            updateViewPos(view: label, field: field)
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: item?.peopleName, field: field, designSize: designSize)
            return label
        case CardFieldVariableEnum.PeopleDob.rawValue:
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: "\((item?.peopleDob ?? 0)/1000)".timestampToFormatedDate(format: "dd/MM/yyyy"), field: field, designSize: designSize)
            return label
        case CardFieldVariableEnum.ContractObjectIdProvider.rawValue:
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: item?.contractObjectIdProvider, field: field, designSize: designSize)
            return label
        case CardFieldVariableEnum.CompanyProviderName.rawValue:
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: item?.companyProviderName, field: field, designSize: designSize)
            return label
        case CardFieldVariableEnum.CardNumber.rawValue:
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: item?.cardNumber, field: field, designSize: designSize)
            return label
        case CardFieldVariableEnum.ContractObjectStartDate.rawValue:
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: "\((item?.contractObjectStartDate ?? 0)/1000)".timestampToFormatedDate(format: "dd/MM/yyyy"), field: field, designSize: designSize)
            return label
        case CardFieldVariableEnum.ContractObjectEndDate.rawValue:
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: "\((item?.contractObjectEndDate ?? 0)/1000)".timestampToFormatedDate(format: "dd/MM/yyyy"), field: field, designSize: designSize)
            return label
        case CardFieldVariableEnum.BuyerName.rawValue:
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: item?.name, field: field, designSize: designSize)
            return label
        case CardFieldVariableEnum.ProgramName.rawValue:
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: item?.programName, field: field, designSize: designSize)
            return label
        case CardFieldVariableEnum.MaximumAmount.rawValue:
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: "\((item?.maximumAmount ?? 0).addComma()) vnđ", field: field, designSize: designSize)
            return label
        case CardFieldVariableEnum.MaximumAmount.rawValue:
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: "\((item?.maximumAmount ?? 0).addComma()) vnđ", field: field, designSize: designSize)
            return label
        case CardFieldVariableEnum.PeopleLicense.rawValue:
            let label = LayoutBuilder.shared.createLabel(view: view, labelSize: labelSize, text: "\(item?.peopleLicense ?? "")", field: field, designSize: designSize)
            return label
        default: return UILabel()
        }
        return UILabel()
    }
}
