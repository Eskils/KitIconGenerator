//
//  Vector3.swift
//  KitIconGenerator
//
//  Created by Eskil Gjerde Sviggum on 28/11/2023.
//

import Foundation
import Combine

class Vector3<T: SIMDScalar & StringParseable>: ObservableObject, Equatable {
    
    @Published
    var xText: String
    
    @Published
    var yText: String
    
    @Published
    var zText: String
    
    @Published
    var x: T
    
    @Published
    var y: T
    
    @Published
    var z: T
    
    private var cancellables = Set<AnyCancellable>()
    
    init(x: T, y: T, z: T) {
        self.x = x
        self.y = y
        self.z = z
        self.xText = "\(x)"
        self.yText = "\(y)"
        self.zText = "\(z)"
        
        setupPublishers()
    }
    
    private func setupPublishers() {
        $x.removeDuplicates().sink { x in
            self.xText = "\(x)"
        }.store(in: &cancellables)
        
        $xText.removeDuplicates().sink { xText in
            self.x = T(string: xText) ?? .zero
        }.store(in: &cancellables)
        
        $y.removeDuplicates().sink { y in
            self.yText = "\(y)"
        }.store(in: &cancellables)
        
        $yText.removeDuplicates().sink { yText in
            self.y = T(string: yText) ?? .zero
        }.store(in: &cancellables)
        
        $z.removeDuplicates().sink { z in
            self.zText = "\(z)"
        }.store(in: &cancellables)
        
        $zText.removeDuplicates().sink { zText in
            self.z = T(string: zText) ?? .zero
        }.store(in: &cancellables)
    }
    
    convenience init(simd: SIMD3<T>) {
        self.init(x: simd.x, y: simd.y, z: simd.z)
    }
    
    func toSIMD(conversionBlock: ((T) -> T)? = nil) -> SIMD3<T> {
        if let conversionBlock {
            return SIMD3(conversionBlock(x), conversionBlock(y), conversionBlock(z))
        } else {
            return SIMD3(x, y, z)
        }
    }
    
    func assign(_ value: Vector3<T>) {
        self.x = value.x
        self.y = value.y
        self.z = value.z
    }
    
    static func == (lhs: Vector3<T>, rhs: Vector3<T>) -> Bool {
            lhs.x == rhs.x
        &&  lhs.y == rhs.y
        &&  lhs.z == rhs.z
    }
    
}

extension Vector3 where T == Float {
    static var zero: Vector3<T> {
        Vector3(simd: .zero)
    }
}
