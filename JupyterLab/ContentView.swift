//
//  ContentView.swift
//  JupyterLab
//
//  Created by Valentin on 01.04.2020.
//  Copyright © 2020 Valentin Shinkarev. All rights reserved.
//

import SwiftUI
import WebKit

var JupyterURL: URL!

struct ContentView: View {
    var body: some View {
        WebView(request: URLRequest(url: JupyterURL))
    }
}

struct WebView: NSViewRepresentable {
    
    let request: URLRequest
    
    func makeNSView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.customUserAgent = "JupyterLabApp"
        view.load(request)
        
        return view
    }
    
    func updateNSView(_ view: WKWebView, context: Context) {}
}
