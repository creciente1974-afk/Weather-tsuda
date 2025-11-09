//
//  DailyWeatherView.swift
//  Weather
//
//  Created by tsuda kazumi on 2025/11/09.
//

import SwiftUI

struct DailyWeatherView: View {
    
    @ObservedObject var weatherVM: WeatherViewModel // APIレスポンスの値を保持するオブジェクト
    
    var body: some View {
        ScrollView(.horizontal){
            // レスポンスに天気予報の情報があったとき
            if let forecastsDay = weatherVM.forecast?.forecastsDay {
                
                
                
                HStack{
                    ForEach(forecastsDay, id: \.self){ forecastDay in
                        //１日分の天気予報のUI
                        VStack(spacing:5) { //各部品の感覚を５に指定
                            //日付(年月日)
                            Text(forecastDay.toDisplayDate(forecastDay.date))
                                .font(.callout)
                            //天気アイコン画像
                          AsyncImageView(urlStr: "https:\( forecastDay.day.condition.icon)")
                                .padding()
                                .scaledToFit()
                                
                            
                            //天気の説明(晴れ、曇りなど）
                            Text(forecastDay.day.condition.text)
                                .font(.headline)
                            
                            //最高気温　°C/最低気温°C
                            HStack{
                                Text(forecastDay.day.maxTemp, format: .number)//数字が入る
                                    .foregroundStyle(.red)
                                Text("°C")
                                    .foregroundStyle(.red)
                                Text("/")
                                
                                Text(forecastDay.day.minTemp, format: .number)//数字が入る
                                    .foregroundStyle(.blue)
                                Text("°C")
                                    .foregroundStyle(.blue)
                            }
                            
                            //降水確率:〇〇％
                            HStack{
                                Text("降水確率：")
                                Text(forecastDay.day.dailyChanceOfRain, format: .number)//数字が入る
                                Text("％")
                            }
                            .font(.subheadline)
                            
                        }
                        .padding()
                        .frame(width: ScreenInfo.width / 2, height: ScreenInfo.height / 3)
                        .background(.yellow.opacity(0.3))
                        .clipShape(.rect(cornerRadius: 30))
                    }
                }
            }else{
                //データがないときの表示にする
                HStack{
                    ForEach(0...2, id: \.self){ _ in
                        //１日分の天気予報のUI
                        VStack(spacing:5) { //各部品の感覚を５に指定
                            //日付(年月日)
                            Text("--年--月--日")
                            
                            //天気アイコン画像
                            Image(systemName: "cloud.sun")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 64, height: 64)
                            //天気の説明(晴れ、曇りなど）
                            Text("晴れのち曇り")
                            
                            //最高気温　°C/最低気温°C
                            HStack{
                                Text("最高")//数字が入る
                                Text("°C/")
                                Text("最低")//数字が入る
                                Text("°C")
                            }
                            
                            //降水確率:〇〇％
                            HStack{
                                Text("降水確率：")
                                Text("oo")//数字が入る
                                Text("％")
                            }
                            
                        }
                        .padding()
                        .frame(width: ScreenInfo.width / 2, height: ScreenInfo.height / 3)
                        .background(.yellow.opacity(0.3))
                        .clipShape(.rect(cornerRadius: 30))
                    }
                }
            }
            
        }
    }
}

#Preview {
    @Previewable @StateObject var weatherVM = WeatherViewModel()
    // 八幡平市大更の緯度・経度
    let lat: Double = 39.91167
    let lon: Double = 141.093459
    
    DailyWeatherView(weatherVM: weatherVM)
        .onAppear {
            weatherVM.request3DaysForecast(lat: lat, lon: lon)
        }
}
