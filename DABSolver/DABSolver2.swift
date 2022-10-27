//
//  DABSolver.swift
//  DABSolver
//
//  Created by Samuel Donovan on 10/12/22.
//

import Foundation

extension Int {
    static func onesTo(_ n: Int64) -> Int64 {
        return (1 << n) - 1
    }
    
    func zeroPadded() -> String {
        var str = ""
        if self < 10 {
            str.append("0" as Character)
        }
        str.append(String(self))
        return str
    }
}

typealias Box = [Int]
extension Box {
    func toBitMap() -> Int {
        var baby = 0
        for value in self {
            baby |= (1 << value)
        }
        return baby
    }
}

enum Winner {
    case p0
    case p1
    case undecided
}

struct DABState: Hashable {
    
    // line -> boxes
    // box -> bitMap
    
    static var boxes: [Box] = {
        var baby = [Box]()
        for i in 0..<3 {
            var top = i
            var left = 12 + 4*i
            for j in 0..<3 {
                let bottom = top + 1
                let right = left + 1
                baby.append([top,bottom,left,right])
                top += 4
                left += 1
            }
        }
        return baby
    }()
    
    static var linesToBoxes: [(Box,Box?)] = {
        var linesToBoxes: [(Box,Box?)] = []
        
        for i in 0..<3 {
            linesToBoxes.append((boxes[i], nil))
            linesToBoxes.append((boxes[i], boxes[3+i]))
            linesToBoxes.append((boxes[3+i],boxes[6+i]))
            linesToBoxes.append((boxes[6+i], nil))
        }
        
        for i in 0..<3 {
            linesToBoxes.append((boxes[3*i], nil))
            linesToBoxes.append((boxes[3*i], boxes[1+3*i]))
            linesToBoxes.append((boxes[1+3*i],boxes[2+3*i]))
            linesToBoxes.append((boxes[2+3*i], nil))
        }
        return linesToBoxes
    }()
    
    static var lineToBitMaps: [(Int,Int?)] = {
        return linesToBoxes.map({($0.0.toBitMap(), $0.1?.toBitMap())})
    }()
    
    static func calculateNumBoxesFilled(flipped: Int, lines: Int) -> Int {
        var numBoxes = 0
        let (bitMap0, bitMap1) = lineToBitMaps[flipped]
        if bitMap0 & lines == bitMap0 {
            numBoxes += 1
        }
        if let bitMap1 = bitMap1, bitMap1 & lines == bitMap1 {
            numBoxes += 1
        }
        return numBoxes
    }
    
    static let initState = DABState(lines: 0, p0MinusP1: 0, numBoxesRemaining: 9, p1Turn: false)
    
    var lines: Int
    var p0MinusP1: Int
    var numBoxesRemaining: Int
    var p1Turn: Bool
    
    // ** 00 ** 04 ** 08 **
    // 12    13    14    15"
    // ** 01 ** 05 ** 09 **"
    // 16    17    18    19"
    // ** 02 ** 06 ** 10 **"
    // 20    21    22    23"
    // ** 03 ** 07 ** 11 **"
    
    func printBoard() {
        for i in 0..<3 {
            printEvenRow(int: i)
            printOddRow(int: i)
        }
        printEvenRow(int: 3)
    }
    
    func printEvenRow(int: Int) {
        print("**", terminator: "")
        for i in 0..<3 {
            let line = int + 4*i
            let hasLine = hasLine(line)
            print(hasLine ? "----" : " \(line.zeroPadded()) ", terminator: "")
            print("**", terminator: "")
        }
        print()
    }
    
    func printOddRow(int: Int) {
        let start = 12 + 4*int
        for i in 0..<3 {
            let line = start + i
            let hasLine = hasLine(line)
            print("\(!hasLine ? line.zeroPadded() : "||")    ", terminator: "")
        }
        let line = start + 3
        let hasLine = hasLine(line)
        print(!hasLine ? line.zeroPadded() : "||", terminator: "")
        print()
    }
    
    func terminalWinningState() -> Winner {
        if p0MinusP1 > numBoxesRemaining {
            return .p0
        } else if p0MinusP1  < -numBoxesRemaining {
            return .p1
        }
        return .undecided
    }

    func trySubsequentState(line: Int) -> DABState? {
        if !hasLine(line) {
            let nextLines = lines | (1 << line)
            // check if we filled in any boxes
            let numBoxesFilled = Self.calculateNumBoxesFilled(flipped: line, lines: nextLines)
            let nextState = DABState(lines: nextLines, p0MinusP1: p0MinusP1 + (p1Turn ? -numBoxesFilled : numBoxesFilled), numBoxesRemaining: numBoxesRemaining - numBoxesFilled, p1Turn: numBoxesFilled > 0 ? p1Turn : !p1Turn)
            return nextState
        }
        return nil
    }
    
    func hasLine(_ line: Int) -> Bool {
        let flipBit = 1 << line
        return (flipBit & lines) != 0
    }

    func subsequentStates() -> [(line: Int, state: DABState)] {
        
        var baby = [(line: Int, state: DABState)]()
        
        for line in 0..<24 {
            if let subState = trySubsequentState(line: line) {
                baby.append((line,subState))
            }
        }
        
        return baby
    }

}

class DABSolver2 {
    let MAX_DEPTH = 8
    
    var stateToScore = [DABState:Int]()
    
    func minimaxGetLine(dABState: DABState) -> Int? {
        stateToScore.removeAll(keepingCapacity: true)
        let isMaximizer = !dABState.p1Turn
        switch dABState.terminalWinningState() {
        case .p0:
            return nil
        case .p1:
            return nil
        default:
            break
        }
        
        if isMaximizer {
            var bestVal = Int.min
            var line1: Int? = nil
            for (line, state) in dABState.subsequentStates() {
                let newVal = calculateMinimaxBestScore(dABState: state, depth: 0)
                if newVal > bestVal {
                    bestVal = newVal
                    line1 = line
                }
            }
            assert(line1 != nil)
            return line1
        } else {
            var bestVal = Int.max
            var line1: Int? = nil
            for (line, state) in dABState.subsequentStates() {
                let newVal = calculateMinimaxBestScore(dABState: state, depth: 0)
                if newVal < bestVal {
                    bestVal = newVal
                    line1 = line
                }
            }
            assert(line1 != nil)
            return line1
        }
    }
    
    func minimaxBestScore(dABState: DABState, depth: Int) -> Int {
        if let cached = stateToScore[dABState] {
            return cached
        }
        let bestScore = calculateMinimaxBestScore(dABState: dABState, depth: depth)
        stateToScore[dABState] = bestScore
        return bestScore
    }
    // p0 is maximizer
    func calculateMinimaxBestScore(dABState: DABState, depth: Int) -> Int {
        let isMaximizer = !dABState.p1Turn
        switch dABState.terminalWinningState() {
        case .p0:
            return Int.max - 1
        case .p1:
            return Int.min + 1
        default:
            break
        }
        
        if depth == MAX_DEPTH {
            return dABState.p0MinusP1
        }
        
        if isMaximizer {
            var bestVal = Int.min
            for (_, state) in dABState.subsequentStates() {
                let newVal = minimaxBestScore(dABState: state, depth: depth + 1)
                if newVal > bestVal {
                    bestVal = newVal
                }
            }
            return bestVal
        } else {
            var bestVal = Int.max
            for (_, state) in dABState.subsequentStates() {
                let newVal = minimaxBestScore(dABState: state, depth: depth + 1)
                if newVal < bestVal {
                    bestVal = newVal
                }
            }
            return bestVal
        }
    }
}
