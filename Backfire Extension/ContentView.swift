//
//  ContentView.swift
//  Backfire Extension
//
//  Created by David Jensenius on 2021-04-06.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var boardManager = BLEManager()

    var body: some View {
        VStack {
            Spacer()
            if (boardManager.isConnected) {
                ZStack {
                    VStack {
                        Text("\(boardManager.speed) km/h")
                            .font(.title2)
                            .padding(.bottom)
                        Text("Trip: \( String(format: "%.1f", Float(boardManager.tripDistance) / 10)) km")
                            .font(.footnote)
                        Text("Battery: \(boardManager.battery)%")
                            .font(.footnote)
                        Text(boardManager.mode)
                            .font(.footnote)
                    }
                    Circle()
                        .stroke(Color.black, lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: (CGFloat(boardManager.battery + 1)) / 100)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color.red, Color.green]),
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(350)
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        ).rotationEffect(.degrees(-90))
                }.frame(idealWidth: 250, idealHeight: 250, alignment: .center)
            } else {
                Button("Get Started") {
                    boardManager.startScanning()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
