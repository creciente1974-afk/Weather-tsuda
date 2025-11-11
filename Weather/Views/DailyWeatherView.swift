//
//  DailyWeatherView.swift
//  Weather
//
//  Created by tsuda kazumi on 2025/11/09.
//

import SwiftUI

struct DailyWeatherView: View {

    @ObservedObject var weatherVM: WeatherViewModel  // APIレスポンスの値を保持するオブジェクト

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            // レスポンスに天気予報の情報があったとき
            if let forecastsDay = weatherVM.forecast?.forecastsDay {

                HStack {
                    ForEach(forecastsDay, id: \.self) { forecastDay in
                        //１日分の天気予報のUI
                        VStack(spacing: 5) {  //各部品の感覚を５に指定
                            
                            //日付(年月日)
                            Text(forecastDay.toDisplayDate(forecastDay.date))
                                .font(.callout)
                                .fontWeight(.medium)
                            
                            //天気アイコン画像
                            AsyncImageView(
                                urlStr:
                                    "https:\( forecastDay.day.condition.icon)"
                            )
                            .frame(width: 50, height: 50)
                            .padding(.vertical, 4)

                            //天気の説明(晴れ、曇りなど）
                            Text(forecastDay.day.condition.text)
                                .font(.headline)
                                .multilineTextAlignment(.center)

                            //最高気温　°C/最低気温°C
                            HStack(spacing: 4) {
                                // 最高気温 (赤)
                                Text(forecastDay.day.maxTemp, format: .number)  //数字が入る
                                    .foregroundStyle(.red)
                                Text("°C")
                                    .foregroundStyle(.red)
                                Text("/")

                                // 最低気温 (青)
                                Text(forecastDay.day.minTemp, format: .number)  //数字が入る
                                    .foregroundStyle(.blue)
                                Text("°C")
                                    .foregroundStyle(.blue)
                            }

                            //降水確率:〇〇％
                            HStack(spacing: 2) {
                                Text("降水確率：")
                                Image(systemName: "drop.fill").foregroundColor(.blue)
                                Text(
                                    forecastDay.day.dailyChanceOfRain,
                                    format: .number
                                )  //数字が入る
                                Text("％")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue.opacity(0.8))
                            .padding(.top, 2)
                            
                            // 月の満ち欠けのカスタム画像表示 (修正箇所)
                            // moonPhaseImageName関数を使ってAssets内のファイル名を取得し、Imageに表示
                            if let moonPhase = forecastDay.astro?.moonPhase,
                               !moonPhase.isEmpty
                            {
                                Image(moonPhaseImageName(for: moonPhase))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30) // 画像サイズ
                                    .padding(.top, 4)
                            } else {
                                // 月情報がない場合のプレースホルダー（高さを確保）
                                Spacer()
                                    .frame(height: 30)
                                    .padding(.top, 4)
                            }

                        }
                        .padding()
                        .frame(
                            width: ScreenInfo.width / 2.5, // 画面幅の約40%を使用
                            height: ScreenInfo.height / 3.5
                        )
                        .background(Color(white: 0.95)) // 背景を薄いグレーに変更
                        .clipShape(.rect(cornerRadius: 15))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                        .padding(.horizontal, 8)
                    }
                }
            } else {
                //データがないときの表示にする（プレースホルダー）
                HStack {
                    ForEach(0..<3, id: \.self) { _ in
                        //１日分の天気予報のUI
                        VStack(spacing: 5) {  //各部品の感覚を５に指定
                            //日付(年月日)
                            Text("--年--月--日").font(.callout)

                            //天気アイコン画像
                            Image(systemName: "cloud.sun")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                                .padding(.vertical, 4)

                            //天気の説明(晴れ、曇りなど）
                            Text("データなし").font(.headline)

                            //最高気温　°C/最低気温°C
                            HStack {
                                Text("--").foregroundStyle(.red)
                                Text("°C/").foregroundStyle(.red)
                                Text("--").foregroundStyle(.blue)
                                Text("°C").foregroundStyle(.blue)
                            }

                            //降水確率:〇〇％
                            HStack {
                                Text("降水確率：")
                                Text("--")  //数字が入る
                                Text("％")
                            }
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            
                            // 月情報がない場合のプレースホルダー（高さを確保）
                            Spacer()
                                .frame(height: 30)
                                .padding(.top, 4)
                        }
                        .padding()
                        .frame(
                            width: ScreenInfo.width / 2.5,
                            height: ScreenInfo.height / 3.5
                        )
                        .background(Color(white: 0.95))
                        .clipShape(.rect(cornerRadius: 15))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 5)
                        .padding(.horizontal, 8)
                    }
                }
            }

        }
    }
}



// 月の満ち欠けアセット名を取得するヘルパー関数
// (元のコードにあったSF Symbolsの関数は、weatherAPIModels.swiftで定義した
// moonPhaseImageNameに置き換えられたため、削除またはコメントアウトします。)
// func getMoonPhaseAssetName(moonPhaseValue: Double) -> String { ... }
// func getMoonPhaseSymbolName(moonPhaseValue: Double) -> String { ... }


#Preview {
    @Previewable @StateObject var weatherVM = WeatherViewModel()
    // 八幡平市大更の緯度・経度
    let lat: Double = 39.91167
    let lon: Double = 141.093459
    
    DailyWeatherView(weatherVM: weatherVM)
        .onAppear {
            // APIリクエストの呼び出しを有効化
            weatherVM.request3DaysForecast(lat: lat, lon: lon)
        }
}
