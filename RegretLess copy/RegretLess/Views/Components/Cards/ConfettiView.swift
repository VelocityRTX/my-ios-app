//
//  ConfettiView.swift
//  RegretLess
//
//  Created by Conrad Anton on 4/27/25.
//

import SwiftUI
import Foundation

// Confetti view
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    let shapes: [String] = ["circle.fill", "square.fill", "triangle.fill", "star.fill", "diamond.fill"]
    
    var body: some View {
        ZStack {
            ForEach(confettiPieces.indices, id: \.self) { index in
                ConfettiPieceView(piece: $confettiPieces[index])
            }
        }
        .onAppear {
            // Create confetti pieces
            for _ in 0..<100 {
                confettiPieces.append(
                    ConfettiPiece(
                        position: CGPoint(x: CGFloat.random(in: -20...UIScreen.main.bounds.width + 20),
                                       y: -20),
                        color: colors.randomElement()!,
                        shape: shapes.randomElement()!,
                        size: CGFloat.random(in: 5...15),
                        rotation: Double.random(in: 0...360),
                        speed: Double.random(in: 500...1200)
                    )
                )
            }
        }
    }
}

// Individual confetti piece
struct ConfettiPiece {
    var position: CGPoint
    var color: Color
    var shape: String
    var size: CGFloat
    var rotation: Double
    var speed: Double
}

// View for a single confetti piece
struct ConfettiPieceView: View {
    @Binding var piece: ConfettiPiece
    @State private var timer: Timer?
    
    var body: some View {
        Image(systemName: piece.shape)
            .foregroundColor(piece.color)
            .font(.system(size: piece.size))
            .rotationEffect(.degrees(piece.rotation))
            .position(piece.position)
            .onAppear {
                // Start animation
                timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                    updatePosition()
                }
            }
            .onDisappear {
                timer?.invalidate()
            }
    }
    
    // Update the position of the confetti piece
    private func updatePosition() {
        // Fall down
        piece.position.y += CGFloat(piece.speed) * 0.01
        
        // Horizontal movement (swaying)
        piece.position.x += CGFloat(cos(Double(piece.position.y) * 0.01) * 2)
        
        // Spin
        piece.rotation += Double.random(in: -1...1)
        
        // If it's out of screen, remove it
        if piece.position.y > UIScreen.main.bounds.height + 100 {
            timer?.invalidate()
        }
    }
}
