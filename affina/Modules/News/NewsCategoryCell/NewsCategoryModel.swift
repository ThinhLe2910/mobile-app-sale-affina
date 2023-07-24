//
//  NewsCategoryModel.swift
//  affina
//
//  Created by Intelin MacHD on 28/07/2022.
//

import Foundation


class NewsCategoryModel: Codable {
    private var id: String?
    private var name: String?
    private var createdBy: String?
    private var createdAt: Int64?
    private var modifiedBy: String?
    private var modifiedAt: Int64?
    
    func getId()-> String {
        guard let id = id else {
            return ""
        }
        return id
    }
    
    func setId(_ id: String)->Self {
        self.id = id
        return self
    }
    
    func getName()-> String {
        guard let name = name else {
            return ""
        }
        return name
    }
    
    func setName(_ name: String)->Self {
        self.name = name
        return self
    }
    
    func getCreatedBy()-> String {
        guard let createdBy = createdBy else {
            return ""
        }
        return createdBy
    }
    
    func setCreatedBy(_ createdBy: String)->Self {
        self.createdBy = createdBy
        return self
    }
    
    func getCreatedAt()-> Int64 {
        guard let createdAt = createdAt else {
            return 0
        }
        return createdAt
    }
    
    func setCreatedAt(_ createdAt: Int64)->Self {
        self.createdAt = createdAt
        return self
    }
    
    func getModifiedBy()-> String {
        guard let modifiedBy = modifiedBy else {
            return ""
        }
        return modifiedBy
    }
    
    func setModifiedBy(_ modifiedBy: String)->Self {
        self.modifiedBy = modifiedBy
        return self
    }
    
    func getModifiedAt()-> Int64 {
        guard let modifiedAt = modifiedAt else {
            return 0
        }
        return modifiedAt
    }
    
    func setModifiedAt(_ modifiedAt: Int64)->Self {
        self.modifiedAt = modifiedAt
        return self
    }
}
