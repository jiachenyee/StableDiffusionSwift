//
//  ContentView.swift
//  StableDiffusionSwift
//
//  Created by Jia Chen Yee on 17/12/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var manager = StableDiffusionManager()
    
    @State var text = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Prompt", text: $text)
                
                Button("Generate") {
                    manager.generateImage(prompt: text)
                }
                .disabled(!manager.isReady)
                
                Section("Images") {
                    ProgressView(value: manager.progress)
                    
                    ForEach(manager.images) { image in
                        Image(image.cgImage, scale: 1, label: Text(""))
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
            .navigationTitle("Generate Images")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
