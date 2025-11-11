//
//  weatherAPIModels.swift
//  Weather
//
//  Created by tsuda kazumi on 2025/11/09.
//

import Foundation

//レスポンス全体の大枠
struct WeatherInfo: Codable {
    let location: UserLocation
    let forecast: Forecast
}

//ユーザーの位置とそれに関連した情報
struct UserLocation: Codable {
    let name: String
    let region: String
    let country: String
    let timezoneID: String
    let localTime: String

    //キャメルケース⇔スネークケースの相互変換するための記述
    //変換不要のものも含めたすべてのcaseについて書く
    enum CodingKeys: String, CodingKey {
        case name
        case region
        case country
        case timezoneID = "tz_id"
        case localTime = "localtime"
    }
}

//天気予報の情報全体
struct Forecast: Codable {
    //取得した日数分の予報
    let forecastsDay: [ForecastDay]

    enum CodingKeys: String, CodingKey {
        case forecastsDay = "forecastday"
    }
}

// 月の満ち欠け情報を格納する構造体
// 「astro」の箱の設計図です。
struct Astro: Codable, Hashable {
    let moonPhase: String
    
    // APIレスポンスのキー名が "moon_phase" の場合を想定
    enum CodingKeys: String, CodingKey {
        case moonPhase = "moon_phase"
    }
    
    // moonPhase (String) を Double に変換する計算プロパティ
    var moonPhaseValue: Double? {
        // APIによっては "New Moon" のような文字列が来る場合もあるため、Doubleに変換できるか確認します
        return Double(moonPhase)
    }
}

//１日分の天気予報（１日と時間ごと）
struct ForecastDay: Codable, Hashable {
    let date: String
    let day: DailyForecast
    let hour: [HourlyForecast]
    // Astro構造体への参照を追加（修正部分）
    let astro: Astro?

    // 「2024-12-23」 →Date型に変換→String型「2024年12月23日」の形式に変換する関数
    func toDisplayDate(_ date: String) -> String {
        let formatter = DateFormatter() // フォーマッター生成
        formatter.dateFormat = "yyyy-MM-dd" // 日付の形式を指定
        guard let date = formatter.date(from: date) else { return "" } // String型を一度Date型に変換
        formatter.dateFormat = "yyyy年MM月dd日" // 日付の形式を再度指定
        return formatter.string(from: date) // Date型から指定した形式にしてString型に変換して返す
    }
}

//日毎の予報
struct DailyForecast: Codable, Hashable {
    let maxTemp: Double
    let minTemp: Double
    let dailyChanceOfRain: Double
    let condition: Condition

    enum CodingKeys: String, CodingKey {
        case maxTemp = "maxtemp_c"
        case minTemp = "mintemp_c"
        case dailyChanceOfRain = "daily_chance_of_rain"
        case condition
    }
}

//時間ごとの予報
struct HourlyForecast: Codable, Hashable {
    let time: String
    let temperature: Double
    let condition: Condition
    let chanceOfRain: Double

    enum CodingKeys: String, CodingKey {
        case time
        case temperature = "temp_c"
        case condition
        case chanceOfRain = "chance_of_rain"
    }
    // 時間毎の予報を表示用の構造体の形に変換
    func toDisplayFormat(hourlyForecast: HourlyForecast) -> HourlyDisplayForecast{
        let dateAndTime: (String, String) = splitTime(timeString: hourlyForecast.time)
        let displayWeather = HourlyDisplayForecast(
            date: dateAndTime.0,
            time: dateAndTime.1,
            weatherIcon: hourlyForecast.condition.icon,
            temperature: hourlyForecast.temperature,
            chanceOfRain: hourlyForecast.chanceOfRain
        )
        return displayWeather
    }
    
    // timeに入っている「日時」の文字列→「日付」、「時間」に分割して(日付、時間)の文字列のタプルで返す。
    func splitTime(timeString: String) -> (String, String){
        
        var dateAndTimeString: (String, String) = ("----年--月--日", "--:--")
        // 日付と時刻のフォーマットを指定
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        // 文字列をDate型に変換
        if let date = dateFormatter.date(from: timeString) {
            // Calendarを使って日付と時刻を抽出
            let calendar = Calendar.current // ユーザーの現在の暦を取得
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            
            // 日付と時刻の文字列を作成
            let dateString = "\(components.year!)年\(components.month!)月\(components.day!)日"
            let timeString = "\(components.hour!)" // 何時だけを表示(例: 11)
            
            dateAndTimeString = (dateString, timeString)
            return dateAndTimeString
        } else {
            print("日付の変換に失敗しました")
            return dateAndTimeString
        }
    }
    
}

struct Condition: Codable, Hashable {
    let text: String
    let icon: String
}

// 毎時予報の表示用の構造体
struct HourlyDisplayForecast: Identifiable {
    var id = UUID()
    let date: String
    let time: String
    let weatherIcon: String
    let temperature: Double
    let chanceOfRain: Double
}


 //APIから取得した月の満ち欠けの英語名に基づき、Assets内の画像ファイル名を返します。
 
 // Parameter phase: Weather APIから取得した moon_phase の文字列 (例: "New Moon")
 //Returns: Assetsフォルダ内の月の満ち欠けの画像ファイル名
 
func moonPhaseImageName(for phase: String) -> String {
    // APIレスポンスとAssetsフォルダ内の画像ファイル名の対応付けを行います。
    let mapping: [String: String] = [
        "New Moon": "New Moon",
        "Waxing Crescent": "Waxing Crescent",
        "First Quarter": "First Quarter",
        "Waxing Gibbous": "Waxing Gibbous",
        "Full Moon": "Full Moon",
        "Waning Gibbous": "Waning Gibbous",
        // 「Third Quarter」のファイル名を「Last Quarter」に変更したという指示に対応
        "Third Quarter": "Last Quarter",
        "Last Quarter": "Last Quarter", // APIが "Last Quarter" と返す場合も対応
        "Waning Crescent": "Waning Crescent"
    ]
    
    let trimmedPhase = phase.trimmingCharacters(in: .whitespacesAndNewlines)
    
    return mapping[trimmedPhase] ?? ""
}
