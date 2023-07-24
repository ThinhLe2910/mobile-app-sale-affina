//
//  OutstandingNewsModel.swift
//  affina
//
//  Created by Intelin MacHD on 28/07/2022.
//

import Foundation

class OutstandingNewsModel: NewsModel {
        private var newsObject: [Int]?
    
        func getNewsObject()-> [Int] {
            guard let newsObject = newsObject else {
                return [Int]()
            }
            return newsObject
        }
    
        func setNewsObject(_ newsObject: [Int])-> Self {
            self.newsObject = newsObject
            return self
        }
}
