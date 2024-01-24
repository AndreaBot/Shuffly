//
//  EndGameView.swift
//  Shuffly
//
//  Created by Andrea Bottino on 24/01/2024.
//

import SwiftUI

struct EndGameView: View {
    
    @Binding var gameIsOver: Bool
    @Binding var allGuesses: [String]
    @Binding var correctGuessesCount: Int
    @Binding var wrongGuessesCount: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("GAME OVER!")
            
            Text("You've guessed \(correctGuessesCount) words correctly and made \(wrongGuessesCount) mistakes.")
            List {
                ForEach(allGuesses, id:\.self) {
                    Text($0)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 25.0))
              
            
            Button("Close") {
                gameIsOver = false
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.secondary)
        .clipShape(RoundedRectangle(cornerRadius: 25.0))
    }
}
