//
//  spynDemoTestApp.swift
//  spynDemoTest
//
//  Created by ParveenKhan on 12/11/24.
//

import SwiftUI

@main
struct spynDemoTestApp: App {
    @StateObject private var viewModel = ImageViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
