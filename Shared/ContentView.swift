//
//  ContentView.swift
//  Shared
//
//  Created by David Jensenius on 2021-04-05.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var boardManager = BLEManager()

    var body: some View {
        VStack (alignment: .leading, spacing: 10) {
            ZStack {
                VStack {
                    Text("\(boardManager.speed) km/h")
                        .font(.largeTitle)
                        .padding(.bottom)
                    Text("Trip: \( String(format: "%.1f", Float(boardManager.tripDistance) / 10)) km")
                        .font(.title2)
                    Text("Battery: \(boardManager.battery)%")
                        .font(.title2)
                    Text(boardManager.mode)
                        .font(.title2)
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
                            endAngle: .degrees(355)
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    ).rotationEffect(.degrees(-90))
            }.frame(idealWidth: 250, idealHeight: 250, alignment: .center)

            HStack {
                VStack (spacing: 10) {
                    Button(action: {
                        self.boardManager.startScanning()
                    }) {
                        Text("Connect")
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()

    }
}
