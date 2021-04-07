//
//  BackfireAppDebug.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-06.
//

import SwiftUI

struct BackfireAppDebug: View {
    @ObservedObject var bleManager = BLEManager()

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Twenty")
                        .font(.headline)
                }

                VStack(alignment: .leading) {
                    ForEach(bleManager.bytesTwenty.indices, id: \.self) { byte in
                        Text("Value \(byte): \(bleManager.bytesTwenty[byte])")
                    }
                }
                Spacer()
            }
            HStack {
                VStack(alignment: .leading) {
                    Text("Twenty")
                        .font(.headline)
                }

                VStack(alignment: .leading) {
                    ForEach(bleManager.bytesOne.indices, id: \.self) { byte in
                        Text("Value \(byte): \(bleManager.bytesOne[byte])")
                    }
                }
                Spacer()
            }
        }
        Spacer()
    }
}

struct BackfireAppDebug_Previews: PreviewProvider {
    static var previews: some View {
        BackfireAppDebug()
    }
}
