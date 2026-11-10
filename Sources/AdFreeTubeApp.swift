import SwiftUI
import AVFoundation

@main
struct AdFreeTubeApp: App {
    init() {
        // 화면을 꺼도 소리가 계속 나오도록(백그라운드 재생) 오디오 세션 설정
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    var body: some Scene {
        WindowGroup {
            YouTubeWebView()
                .ignoresSafeArea(edges: .bottom)
                .background(Color.black)
        }
    }
}
