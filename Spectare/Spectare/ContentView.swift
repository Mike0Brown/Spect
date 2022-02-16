//
//  ContentView.swift
//  Spectare
//
//  Created by Michael Brown on 10/29/21.
//

import SwiftUI
import CoreData
import VisionKit
import WebKit

private var Ticker : String = ""
private var Comp : String = ""

struct AnalysisView: UIViewRepresentable {
    var wp: URL
    
    func makeUIView(context: Context) -> WKWebView{
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context){
        let req = URLRequest(url: wp)
        webView.load(req)
    }
}


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Company.ticker, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Company>
    
    @State private var showAnalysisViewG = false
    @State private var showAnalysisViewY = false
    @State private var recognizedText = ""
    @State private var showingScanningView = false
    @State private var curURL: String = "noURL"
    @State private var curTic: String = "No Ticker Searched or Ticker was not found"
    @State private var changeTab : Int = 0
    
    var body: some View {
        
        TabView(selection: $changeTab){
            
            
            VStack{
                NavigationView {
                    VStack {
                        ScrollView {
                            VStack {
                                Text("Tap to edit")
                                    .padding(.top)
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(Color.gray.opacity(0.2))
                                    TextField("Enter Brand Name", text: $recognizedText)
                                        .padding()
                                        .multilineTextAlignment(.center)
                                    }
                                }
                            }
                        
                        Spacer()
                        
                        HStack {
                            Button(action: {
                                let urlFormatted = recognizedText.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
                                getComp(bname: urlFormatted)
                                changeTab = 1
                            })
                            {
                                Text("\tLookup\t")
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(Capsule().fill(Color.blue))
                            Spacer()
                            Button(action: {
                                self.showingScanningView = true
                            }) {
                                Text("Start Scanning")
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(Capsule().fill(Color.blue))
                        }
                        .padding()
                    }
                    .navigationBarTitle("Find a Stock!")
                    .sheet(isPresented: $showingScanningView) {
                       ScanDocumentView(recognizedText: self.$recognizedText)
                    }
                }
                
            }.tabItem {
                Image(systemName: "viewfinder")
                Text("Scan")
                
            }.tag(0)
            
            VStack{
                Text("Your Ticker is:").font(.system(.largeTitle, design: .rounded))
                Text(curTic).font(.title).bold()
                Button(action: addItem){
                    Text("Save Ticker")
                }
                
            }.tabItem {
                Image(systemName: "percent")
                Text("Ticker")
                
            }.tag(2)
            
            VStack{
                //Text("Test")
                //Text("Product Text Identified: Slim Jim")
                //Text(curURL)
                //Text(curTic)
                if(curTic != "No Ticker Searched or Ticker was not found"){
                    
                    AnalysisView(wp: URL(string: ("https://www.tradingview.com/chart/?symbol="+curTic))!)
                    
                    HStack{
                        
                        Spacer()
                        
                        Button {
                            showAnalysisViewY.toggle()
                        } label: {
                            Text("Yahoo Finance")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showAnalysisViewY) {
                            AnalysisView(wp: URL(string: ("https://finance.yahoo.com/quote/"+curTic+"?p="+curTic+"&.tsrc=fin-srch"))!)
                        }
                        
                        Spacer()
                        
                        Button {
                            showAnalysisViewG.toggle()
                        } label: {
                            Text("Google Finance")
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(Color.white)
                                .cornerRadius(10)
                        }
                        .sheet(isPresented: $showAnalysisViewG) {
                            AnalysisView(wp: URL(string: ("https://www.google.com/finance/quote/"+curTic+":NYSE"))!)
                        }
                        
                        Spacer()
                    }
                    
                }
            
            }.tabItem {
                Image(systemName: "chart.xyaxis.line")
                Text("Analysis")
                
            }.tag(1)
            NavigationView {
                List {
                    ForEach(items) { item in
                        NavigationLink {
                            VStack{
                                //Text("Test")
                                //Text("Product Text Identified: Slim Jim")
                                //Text(curURL)
                                //Text(curTic)
                                    AnalysisView(wp: URL(string: ("https://www.tradingview.com/chart/?symbol=\(item.ticker!)"))!)
                                    
                                    HStack{
                                        
                                        Spacer()
                                        
                                        Button {
                                            showAnalysisViewY.toggle()
                                        } label: {
                                            Text("Yahoo Finance")
                                                .padding()
                                                .background(Color.blue)
                                                .foregroundColor(Color.white)
                                                .cornerRadius(10)
                                        }
                                        .sheet(isPresented: $showAnalysisViewY) {
                                            AnalysisView(wp: URL(string: ("https://finance.yahoo.com/quote/\(item.ticker!)?p=\(item.ticker!)&.tsrc=fin-srch"))!)
                                        }
                                        
                                        Spacer()
                                        
                                        Button {
                                            showAnalysisViewG.toggle()
                                        } label: {
                                            Text("Google Finance")
                                                .padding()
                                                .background(Color.blue)
                                                .foregroundColor(Color.white)
                                                .cornerRadius(10)
                                        }
                                        .sheet(isPresented: $showAnalysisViewG) {
                                            AnalysisView(wp: URL(string: ("https://www.google.com/finance/quote/\(item.ticker!):NYSE"))!)
                                        }
                                        
                                        Spacer()
                                    }
                            
                            }
                        } label: {
                            Text("\(item.brand!) has ticker \(item.ticker!)")
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus")
                        }
                    }
                }
                Text("Select an item")
            }.tabItem {
                Image(systemName: "doc")
                Text("Saved")
            }
            
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Company(context: viewContext)
            newItem.ticker = Ticker
            newItem.brand = recognizedText

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // gets company name
    private func getComp(bname: String) {
        var session = URLSession(configuration: .default)
        var parse : String = " "
        var ret : Bool = true
        let task = session.dataTask(with: URL(string:  "https://www.allbrands.markets/s-ajax/search?term="+bname)!) {
            data, response, err in
            if let data = data {
                //print(String(data: data, encoding: .ascii))
                parse = String(data: data, encoding: .ascii)!
                let lst = parse.components(separatedBy: "\"")
                //print(components)
                lst.forEach { i in
                    if (i.contains("/brand/price") ){
                        if(ret){
                            curURL = i
                            getTick(url: i)
                            ret = false
                            //print(i)
                        }
                        
                    }
                }
                
            }
        }
        
        task.resume()
    }
    
    //gets stock ticker
    private func getTick(url: String) {
        var session = URLSession(configuration: .default)
        var parse : String = " "
        var ret : String = " "
        var j : Int = 0
        var loc: Int = 0
        var name: String = " "
        
        let task = session.dataTask(with: URL(string:  "https://www.allbrands.markets"+url)!) {
            data, response, err in
            if let data = data {
                //print(String(data: data, encoding: .ascii))
                parse = String(data: data, encoding: .ascii)!
                let lst = parse.components(separatedBy: "\"")
                //print(components)
                lst.forEach { i in
                    j = j+1
                    if (i.contains("brand-page-title") ){
                       loc = j
                    }
                }
                name = lst[loc]
                //print(name)
                let l2 = name.components(separatedBy: "(")
                print(l2)
                name = ""
                for i in l2[1]{
                    if (i.isUppercase){
                        name = name + String(i)
                    }
                }
                Ticker = name
                curTic = name
                print(name)
            }
        }
        
        
        task.resume()
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
