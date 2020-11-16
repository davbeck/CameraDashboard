//
//  ContentView.swift
//  VISCASimulator
//
//  Created by David Beck on 11/15/20.
//

import SwiftUI

extension Binding where Value: FixedWidthInteger {
    var asDouble: Binding<Double> {
        return Binding<Double> {
            Double(self.wrappedValue)
        } set: { newValue in
            self.wrappedValue = Value(newValue)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var camera: Camera

    var body: some View {
        VStack(alignment: .leading) {
            Text("Zoom: \(camera.zoom)")
            Slider(value: $camera.zoom.asDouble, in: 0 ... Double(UInt16.max))
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
