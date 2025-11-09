//
//  AsyncImageView.swift
//  Weather
//
//  Created by tsuda kazumi on 2025/11/09.
//

import SwiftUI

struct AsyncImageView: View {
    //画像URLの文字列
    let urlStr: String

    var body: some View {
        //URL型に変換
        if let url = URL(string: urlStr) {
            AsyncImage(url: url) { image in
                image  // この部分が取得した画像を表示するビュー
                    .resizable()  // リサイズ可能に
            } placeholder: {  // 画像が無いときや読み込み中の表示
                ProgressView()  // 進捗のインジケータのビュー
                    .scaledToFit()
            }
        } else {
            Text("No Image")
        }
    }
}

#Preview {
    // 八幡平市の市章画像のURL文字列
    let urlStr = "https://www.city.hachimantai.lg.jp/img/common/top_logo.png"
    AsyncImageView(urlStr: urlStr)
}
