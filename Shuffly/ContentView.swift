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
    
    let totalTime = 20.0
    @State private var countdown = 0.0
    @State private var timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State private var timerIsRunning = false
    
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(timerIsRunning ? "Stop Game" : "Start Game") {
                    if timerIsRunning {
                        timer.upstream.connect().cancel()
                        countdown = 0
                        txtFieldFocused = false
                    } else {
                        generateWord()
                        countdown = totalTime
                        timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
                    }
                    timerIsRunning.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
            
            ProgressView(countdown > 0 ? "Time Left: \(String(format: "%.1f", countdown))" : "",
                         value: countdown, total: totalTime)
            .tint(colorBasedOn(countdown))
            .onReceive(timer) { _ in
                if countdown > 0 {
                    countdown = max(0, countdown - 0.05)
                } else if countdown == 0 {
                    timer.upstream.connect().cancel()
                    timerIsRunning = false
                    txtFieldFocused = false
                }
            }
            
            Spacer()
            
            VStack {
                Text(wordToGuess)
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
            }
            .opacity(countdown > 0 ? 1 : 0)
            
            Spacer()
        }
        .padding()
        .onSubmit { checkGuess() }
        .alert(alertTitle, isPresented: $alertIsPresented) {
            Button("OK") {
                guess = ""
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    func generateWord() {
        wordToGuess = AllWords.words.randomElement() ?? "APPLE"
        shuffledWord = shuffleLetters(using: wordToGuess)
        txtFieldFocused = true
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
            alertTitle = "Careful!"
            alertMessage = "Your guess needs to be exactly 5 characters long"
            alertIsPresented = true
            return
        }
        
        if guess == wordToGuess {
            feedback = .correct
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                guess = ""
                feedback = .neutral
                generateWord()
            }
        } else {
            feedback = .wrong
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                guess = ""
                feedback = .neutral
                txtFieldFocused = true
            }
        }
    }
    
    func showColor(using feedback: Feedback) -> Color {
        if feedback == .neutral {
            return .secondary.opacity(0.2)
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
        if (10.0..<totalTime).contains(countdown) {
            return .green
        } else if (4.0..<10.0).contains(countdown) {
            return .yellow
        } else if (0.0..<4.0).contains(countdown) {
            return .red
        } else {
            return .green
        }
    }
}

#Preview {
    ContentView()
}
