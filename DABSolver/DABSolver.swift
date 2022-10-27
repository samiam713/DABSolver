//
//  DABSolver.swift
//  DABSolver
//
//  Created by Samuel Donovan on 10/13/22.
//

import Foundation

// tries to explore the whole state space LOL
class DABSolver {

    private var whoWins: [DABState: (winningMove: Int?, p1Wins: Bool)] = [:]

    func whoWins(from: DABState) -> (winningMove: Int?, p1Wins: Bool) {
        if let cached = whoWins[from] {
            return cached
        }
        let calculated = calculateWhoWins(from: from)
        whoWins[from] = calculated
        return calculated
    }

    func calculateWhoWins(from: DABState) -> (winningMove: Int?, p1Wins: Bool) {

        switch from.terminalWinningState() {
        case .p0:
            return (nil, false)
        case .p1:
            return (nil, true)
        default: break
        }
        // if there exists a move such that current player wins, we make that move and win
        for (line, childState) in from.subsequentStates() {
            if whoWins(from: childState).p1Wins == from.p1Turn {
                return (line, from.p1Turn)
            }
        }
        // otherwise there's no move you can make to win and the other player wins
        return (nil, !from.p1Turn)
    }
}
