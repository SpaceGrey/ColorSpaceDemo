//
//  ContentView.swift
//  ColorSpaceDemo
//
//  Created by 王培屹 on 21/2/25.
//

import SwiftUI

struct ContentView: View {
    let model = CameraModel()
    var body: some View {
        VStack {
            CameraPreview(source: model.previewSource)
            Button("Start Recording") {
                model.startRecording()
            }
            Button("Stop Recording") {
                model.stopRecording()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
