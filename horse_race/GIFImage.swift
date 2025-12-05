import SwiftUI
import WebKit

// 這就是我們自製的 GIF 播放器元件
struct GifImage: UIViewRepresentable {
    private let name: String

    // 初始化時傳入 GIF 檔案的名稱（不含 .gif 副檔名）
    init(_ name: String) {
        self.name = name
    }

    // 建立一個迷你的網頁瀏覽器視圖 (WKWebView)
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        // 設定背景透明，這樣才不會有白底
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        // 禁止使用者滾動這個視圖
        webView.scrollView.isScrollEnabled = false
        return webView
    }

    // 告訴瀏覽器要載入哪個 GIF 檔案
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // 尋找檔案路徑
        if let url = Bundle.main.url(forResource: name, withExtension: "gif") {
            do {
                // 讀取 GIF 資料
                let data = try Data(contentsOf: url)
                // 告訴瀏覽器播放這些資料，並指定類型是 image/gif
                uiView.load(data, mimeType: "image/gif", characterEncodingName: "UTF-8", baseURL: url.deletingLastPathComponent())
            } catch {
                print("讀取 GIF 檔案失敗: \(error.localizedDescription)")
            }
        } else {
            print("找不到 GIF 檔案: \(name).gif")
        }
    }
}

// 預覽用，可以不用理會
struct GifImage_Previews: PreviewProvider {
    static var previews: some View {
        // 假設你有一個叫做 horse_running.gif 的檔案
        GifImage("horse_running")
            .frame(width: 120, height: 100)
    }
}
