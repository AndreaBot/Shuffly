//
//  ContentView.swift
//  Shuffly
//
//  Created by Andrea Bottino on 19/01/2024.
//

import SwiftUI

struct ContentView: View {
    
    enum Feedback {
        case correct; case wrong; case neutral
    }
    
    @State private var wordToGuess = ""
    @State private var shuffledWord = ""
    @State private var guess = ""
    
    @State private var feedback: Feedback = .neutral
    @FocusState private var txtFieldFocused: Bool
    
    @State private var alertIsPresented = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    @State private var totalTime = 20.0
    @State private var countdown = 0.0
    @State private var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State private var timerIsRunning = false
    
    @State private var correctGuessesCount = 0
    @State private var wrongGuessesCount = 0
    
    @State private var gameIsOver = false
    @State private var allGuesses = [String]()
    
    @State private var attemptsPerWord = 2
    @State private var attempts = [(id: 1, value: 1), (id: 2, value: 1)]
    
    
    var body: some View {
        ZStack {
            EndGameView(gameIsOver: $gameIsOver, allGuesses: $allGuesses, correctGuessesCount: $correctGuessesCount, wrongGuessesCount: $wrongGuessesCount)
                .opacity(gameIsOver ? 1 : 0)
            
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    
                    Button(timerIsRunning ? "Stop Game" : "Start Game") {
                        if timerIsRunning {
                            timer.upstream.connect().cancel()
                            countdown = 0
                            correctGuessesCount = 0
                            wrongGuessesCount = 0
                            txtFieldFocused = false
                        } else {
                            generateWord()
                            correctGuessesCount = 0
                            wrongGuessesCount = 0
                            countdown = totalTime
                            timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
                            txtFieldFocused = true
                        }
                        timerIsRunning.toggle()
                        allGuesses.removeAll()
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                VStack {
                    VStack(spacing: 10) {
                        ProgressView(countdown > 0 ? "Time Left: \(String(format: "%.1f", countdown))" : "",
                                     value: countdown, total: totalTime)
                        .tint(colorBasedOn(countdown))
                        .onReceive(timer) { _ in
                            if timerIsRunning {
                                if countdown > 0 {
                                    countdown = max(0, countdown - 0.05)
                                } else if countdown == 0 {
                                    timer.upstream.connect().cancel()
                                    timerIsRunning = false
                                    txtFieldFocused = false
                                    gameIsOver = true
                                }
                            }
                        }
                        HStack {
                            Spacer()
                            ForEach(attempts, id: \.self.id) {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle($0.value == 1 ? .red : .gray)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text(shuffledWord)
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                        TextField("Type your guess", text: $guess)
                            .frame(height: UIScreen.main.bounds.height/14)
                            .background(RoundedRectangle(cornerRadius: UIScreen.main.bounds.width).fill(showColor(using: feedback)))
                            .autocorrectionDisabled()
                            .keyboardType(.alphabet)
                            .textInputAutocapitalization(.characters)
                            .multilineTextAlignment(.center)
                            .submitLabel(.done)
                            .focused($txtFieldFocused)
                            .onSubmit {
                                txtFieldFocused = true
                            }
                        
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard){
                                    Spacer()
                                    Button("Check") {
                                        checkGuess()
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                    }
                    .padding()
                    .background(LinearGradient(colors: [.green, .mint], startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Spacer()
                }
                .padding()
                .alert(alertTitle, isPresented: $alertIsPresented) {
                    Button("OK") {
                        guess = ""
                        txtFieldFocused = true
                        timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
                    }
                } message: {
                    Text(alertMessage)
                }
                .opacity(countdown > 0 ? 1 : 0)
                
            }
            .opacity(gameIsOver ? 0 : 1)
        }
    }
    
    func generateWord() {
        resetTextField()
        wordToGuess = AllWords.words.randomElement() ?? "APPLE"
        shuffledWord = shuffleLetters(using: wordToGuess)
        allGuesses.append(wordToGuess)
        attemptsPerWord = 2
        for index in attempts.indices {
            attempts[index].value = 1
        }
        print(wordToGuess)
    }
    
    func shuffleLetters(using word: String) -> String {
        var lettersArray = [String]()
        for letter in word {
            lettersArray.append(String(letter))
        }
        return lettersArray.shuffled().joined()
    }
    
    func checkGuess() {
        guard wordIsFiveLettersLong(word: guess) else {
            timer.upstream.connect().cancel()
            alertTitle = "Careful!"
            alertMessage = "Your guess needs to be exactly 5 characters long"
            alertIsPresented = true
            return
        }
        
        if guess == wordToGuess {
            feedback = .correct
            correctGuessesCount += 1
            if countdown + 6 < totalTime {
                countdown += 6
            } else {
                countdown = totalTime
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                generateWord()
            }
        } else {
            feedback = .wrong
            wrongGuessesCount += 1
            if attemptsPerWord > 0 {
                attemptsPerWord -= 1
                attempts[attemptsPerWord].value = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    resetTextField()
                }
            } else {
                generateWord()
            }
        }
    }
    
    func showColor(using feedback: Feedback) -> Color {
        if feedback == .neutral {
            return .indigo.opacity(0.2)
        } else if feedback == .correct {
            return .green
        } else {
            return .red
        }
    }
    
    func wordIsFiveLettersLong(word: String) -> Bool {
        return word.count == 5
    }
    
    func colorBasedOn(_ countdown: Double) -> Color {
        let range1 = totalTime/2.5...totalTime
        let range2 = totalTime/6...totalTime/2.5
        let range3 = 0...totalTime/6
        
        if range1.contains(countdown) {
            return .green
        } else if range2.contains(countdown) {
            return .yellow
        } else if range3.contains(countdown) {
            return .red
        } else {
            return .green
        }
    }
    
    func resetTextField() {
        guess = ""
        feedback = .neutral
    }
}

#Preview {
    ContentView()
}
