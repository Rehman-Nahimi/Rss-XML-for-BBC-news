//
//  ContentView.swift
//  BBC RSS view app
//
//  Created by Ray Nahimi on 9/05/2024.
//

import SwiftUI
import WebKit



struct NewsItem: View {
  var item: Item?
  
    
  var body: some View {
      
    VStack {
        
     Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: item?.img ?? "")!))!)
            .resizable()
            .frame(width: 400, height: 200)
        
      Text(item?.title ?? "")
            .frame(width: 335)
            .fontDesign(.rounded)
            .bold()
            .font(.system(size: 30))
        Spacer()
        Text(item?.description ?? "")
            .frame(width: 335)
            .fontDesign(.serif)
            .multilineTextAlignment(.leading)
    }
  }
}

struct WebView: UIViewRepresentable {
  @Binding var urlString: String

  func makeUIView(context: Context) -> WKWebView {
    let webView = WKWebView()
    guard let url = URL(string: urlString) else { return webView }
    webView.load(URLRequest(url: url))
    return webView
  }

  func updateUIView(_ uiView: WKWebView, context: Context) {
 
  }
}



struct ContentView: View {
  @State private var items = [Item]()
  @State private var showWebView = false
  @State var webURL = ""
  var body: some View {
    List(items) { item in
      NewsItem(item: item)
        .onTapGesture {
            
        webURL = item.link ?? ""
        showWebView = true
            
        }
    }.onAppear(perform: {
      loadFeed()
    })
    .refreshable {
        loadFeed()
    }
    .sheet(isPresented: $showWebView) {
        NavigationStack{
            
            WebView(urlString: $webURL)
                .ignoresSafeArea()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
  }

   
  

  func loadFeed() {
    Task {
      do {
        try ApiService().getItems { result in
          print(result)
          switch result {
          case .success(let items):
            self.items = items
          case .failure(let error):
            print(error)
          }
        }
      } catch {
        // Handle errors
        print(error)
      }
    }
  }
}
