//
//  BackfireAppDebug.swift
//  Backfire
//
//  Created by David Jensenius on 2021-04-06.
//

import SwiftUI

struct BackfireAppDebug: View {
    @ObservedObject var boardManager: BLEManager

    var body: some View {
        HStack {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Twenty")
                        .font(.headline)
                }

                VStack(alignment: .leading) {
                    ForEach(boardManager.bytesTwenty.indices, id: \.self) { byte in
                        Text("Value \(byte): \(boardManager.bytesTwenty[byte])")
                    }
                }
                Spacer()
            }
            Spacer()
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text("Five")
                        .font(.headline)
                }

                VStack(alignment: .leading) {
                    ForEach(boardManager.bytesOne.indices, id: \.self) { byte in
                        Text("Value \(byte): \(boardManager.bytesOne[byte])")
                    }
                }
                Spacer()
            }
        }
    }
}

struct BackfireAppDebug_Previews: PreviewProvider {
    static var previews: some View {
        BackfireAppDebug(boardManager: BLEManager())
    }
}
