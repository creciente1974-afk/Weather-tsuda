//
//  ContentView.swift
//  Weather
//
//  Created by tsuda kazumi on 2025/11/09.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var weatherVM = WeatherViewModel()
    
    // 八幡平市大更の緯度・経度
    var lat: Double = 39.90246980951984
    var lon: Double = 141.1328515168145
    
    
    var body: some View {
        
        NavigationStack{
            ScrollView {
                
                }
            .navigationBarTitle("ここに現在地を表示")//画面上部のタイトル
            .navigationBarTitleDisplayMode(.inline)//タイトルの表示方法の指定
        }
        .padding()
        .onAppear {
            weatherVM.request3DaysForecast(lat: lat, lon: lon)
        }
    }
}

#Preview {
    ContentView()
}
