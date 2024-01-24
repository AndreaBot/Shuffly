//
//  EndGameView.swift
//  Shuffly
//
//  Created by Andrea Bottino on 24/01/2024.
//

import SwiftUI

struct EndGameView: View {
    
    @Binding var gameIsOver: Bool
    @Binding var allGuesses: [WordModel]
    @Binding var correctGuessesCount: Int
    @Binding var wrongGuessesCount: Int
    
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Text("GAME OVER!")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
                
                Section {
                    HStack {
                        Text("Correct Guesses:")
                        Spacer()
                        Text("\(correctGuessesCount)")
                    }
                    HStack {
                        Text("Mistakes:")
                        Spacer()
                        Text("\(wrongGuessesCount)")
                    }
                }
            }
            .scrollDisabled(true)
            .frame(height: 220)
            
            Section() {
                Text("Word List")
            }
            List(allGuesses, id:\.self.word) {
                Text($0.word)
                    .foregroundStyle($0.color)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button("Close") {
                gameIsOver = false
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
    }
}
