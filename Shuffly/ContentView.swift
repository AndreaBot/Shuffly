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
    
    
    var body: some View {
        VStack {
            
            Text(wordToGuess)
            Text(shuffledWord)
                .font(.largeTitle)
                .fontWeight(.heavy)
            TextField("Type your guess", text: $guess)
                .frame(height: 50)
                .background(RoundedRectangle(cornerRadius: 5).fill(showColor(using: feedback)))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.characters)
                .multilineTextAlignment(.center)
                .submitLabel(.done)
                .focused($txtFieldFocused)
        }
        .padding()
        .onAppear(perform: generateWord)
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
}

#Preview {
    ContentView()
}
