import Foundation

let dabSolver = DABSolver2()

var currentState =  DABState.initState
//var currentState_ = DABState(lines: [0,2,12,16].toBitMap(), p0MinusP1: 0, numBoxesRemaining: 9, p1Turn: false)

var computerStreak = 0

func computerShit() {
    print("Game State:")
    currentState.printBoard()
    print()
    print("Computer thinking...")
    guard let computerLine = dabSolver.minimaxGetLine(dABState: currentState) else {
        print("Game over! Quitting")
        exit(0)
    }
    print("Computer Plays Line \(computerLine)")
    if computerStreak > 1 {
        print()
        print("🔥🔥Computer is on \(computerStreak) move streak!🔥🔥")
    }
    print()
    
    currentState = currentState.trySubsequentState(line: computerLine)!
}

func humanShit() {
    print("Game State:")
    currentState.printBoard()
    print()
    print("Human thinking...")
    guard currentState.terminalWinningState() == .undecided else {
        print("Game over! Quitting")
        exit(0)
    }
    print("Input line #: ", terminator: "")
    while true {
        if let line = readLine(),
           let humanLine = Int.init(line),
           (0..<24).contains(humanLine),
           let nextState = currentState.trySubsequentState(line: humanLine)
        {
            print("Human Plays Line \(humanLine)")
            print()
            
            currentState = nextState
            break
        } else {
            print("Error. Input line #: ", terminator: "")
        }
    }
}

var computerIsP0 = false
while true {
    computerStreak = 1
    while currentState.p1Turn != computerIsP0 {
        computerShit()
        computerStreak+=1
    }
    while currentState.p1Turn == computerIsP0 {
        humanShit()
    }
}
