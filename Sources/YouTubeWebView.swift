import SwiftUI
import WebKit

struct YouTubeWebView: UIViewRepresentable {
    static let home = URL(string: "https://m.youtube.com")!

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []

        // 1) 페이지가 열리기 전에 광고 제거 스크립트 주입
        let script = WKUserScript(source: AdBlock.script,
                                  injectionTime: .atDocumentStart,
                                  forMainFrameOnly: false)
        config.userContentController.addUserScript(script)

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = .black

        // 당겨서 새로고침
        let refresh = UIRefreshControl()
        refresh.addTarget(context.coordinator, action: #selector(Coordinator.reload(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refresh
        context.coordinator.webView = webView

        // 2) 광고 서버로 가는 네트워크 요청 자체를 차단한 뒤 첫 페이지 로드
        WKContentRuleListStore.default().compileContentRuleList(
            forIdentifier: "AdFreeTubeRules",
            encodedContentRuleList: AdBlock.contentRules
        ) { list, _ in
            if let list { config.userContentController.add(list) }
            webView.load(URLRequest(url: Self.home))
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        weak var webView: WKWebView?

        @objc func reload(_ sender: UIRefreshControl) {
            webView?.reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { sender.endRefreshing() }
        }

        // 새 창(target=_blank) 링크는 같은 화면에서 열기
        func webView(_ webView: WKWebView,
                     createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil { webView.load(navigationAction.request) }
            return nil
        }

        // 유튜브 이외의 링크는 Safari로 넘기기
        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url, let host = url.host?.lowercased() else {
                decisionHandler(.allow); return
            }
            let allowed = ["youtube.com", "youtu.be", "google.com", "gstatic.com",
                           "googlevideo.com", "ytimg.com", "ggpht.com", "googleusercontent.com", "accounts.google"]
            let isMainFrame = navigationAction.targetFrame?.isMainFrame ?? true
            if isMainFrame && navigationAction.navigationType == .linkActivated
                && !allowed.contains(where: { host.contains($0) }) {
                UIApplication.shared.open(url)
                decisionHandler(.cancel); return
            }
            decisionHandler(.allow)
        }
    }
}
