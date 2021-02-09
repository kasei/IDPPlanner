//
//  SetExtensions.swift
//  IDPPlanner
//
//  Created by Gregory Todd Williams on 2/7/21.
//

import Foundation

extension Set {
    var allProperSubsets: Set<Set<Element>> {
        var subsets = Set<Set<Element>>()
        for i in 1..<self.count {
            subsets.formUnion(self.subsets(size: i))
        }
        return subsets
    }
    
    func subsets(size: Int) -> Set<Set<Element>> {
        var subsets = Set<Set<Element>>()
        if size < 1 {
            return []
        } else if size == 1 {
            for e in self {
                subsets.insert(Set([e]))
            }
        } else {
            for e in self {
                let rest = self.subtracting([e])
                let ss = rest.subsets(size: size-1)
                for s in ss {
                    subsets.insert(s.union([e]))
                }
            }
        }
        return subsets
    }
}

