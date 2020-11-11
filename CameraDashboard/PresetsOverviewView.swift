//
//  PresetsView.swift
//  CameraDashboard
//
//  Created by David Beck on 11/10/20.
//  Copyright © 2020 David Beck. All rights reserved.
//

import SwiftUI

struct PresetsOverviewView: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                CameraHeadingView()
                
                PresetsView()
            }
            Spacer(minLength: 0)
//            HStack {
//                Button(action: {
//                    isAddingCamera.toggle()
//                }, label: {
//                    Text("Add Camera")
//                })
//                    .sheet(isPresented: $isAddingCamera) {
//                        CameraSettingsView(camera: Camera(address: ""), isOpen: $isAddingCamera)
//                            .environmentObject(cameraManager)
//                    }
//
//                Spacer()
//
//                if let error = errorReporter.lastError {
//                    Text(error.localizedDescription)
//                        .lineLimit(1)
//                        .truncationMode(.middle)
//                        .foregroundColor(Color.red)
//                        .transition(.opacity)
//                }
//            }
//            .padding()
        }
//            .frame(minWidth: 600, minHeight: 300)
//            .fixedSize(horizontal: false, vertical: true)
    }
}

struct PresetsOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        PresetsOverviewView()
    }
}
