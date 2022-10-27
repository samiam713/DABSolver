//
//  BinaryIntToString.swift
//  DABSolver
//
//  Created by Samuel Donovan on 10/12/22.
//

import Foundation

func binaryIntToBinaryString<T:BinaryInteger>(binaryInteger: T) -> String {
    let bitCount = MemoryLayout<T>.size*8
    let chars: [Character] = (0..<(bitCount)).map({
        ((1<<$0)&binaryInteger == 0) ? "0" : "1"
    })
//    chars.insert(" ", at: bitCount - 9)
//    chars.insert(" ", at: bitCount)
    return String(chars.reversed())
}

//var string = ""
//for i in 0..<64 {
//    string.append(String(i%10))
//}
//string = String(string.reversed())
