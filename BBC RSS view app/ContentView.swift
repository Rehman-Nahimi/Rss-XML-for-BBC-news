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
  let formatter1 = DateFormatter()
    formatter1.dateStyle = .short
  
    
  var body: some View {
      
    VStack {
        
     Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: item?.img ?? "https://img.freepik.com/free-photo/textured-background-white-tone_53876-128610.jpg?size=626&ext=jpg&ga=GA1.1.1369675164.1715212800&semt=sph")!))!)
            .resizable()
            .frame(width: 400, height: 200)
      Text("CATEGORY")
            .frame(width: 335)
            .multilineTextAlignment(.leading)
            .foregroundColor(.gray)
            .opacity(0.5)
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
        Text(formatter1.string(from: item?.description ?? ""))
        
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
