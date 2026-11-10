import Foundation

enum AdBlock {
    /// WebKit 네트워크 차단 규칙 (광고·추적 서버 요청을 아예 막음)
    static let contentRules = """
    [
      {"trigger":{"url-filter":"^https?://([^/]+\\\\.)?doubleclick\\\\.net"},"action":{"type":"block"}},
      {"trigger":{"url-filter":"^https?://([^/]+\\\\.)?googlesyndication\\\\.com"},"action":{"type":"block"}},
      {"trigger":{"url-filter":"^https?://([^/]+\\\\.)?googleadservices\\\\.com"},"action":{"type":"block"}},
      {"trigger":{"url-filter":"^https?://([^/]+\\\\.)?google-analytics\\\\.com"},"action":{"type":"block"}},
      {"trigger":{"url-filter":"youtube\\\\.com/pagead/"},"action":{"type":"block"}},
      {"trigger":{"url-filter":"youtube\\\\.com/api/stats/ads"},"action":{"type":"block"}},
      {"trigger":{"url-filter":"youtube\\\\.com/ptracking"},"action":{"type":"block"}},
      {"trigger":{"url-filter":"youtube\\\\.com/get_midroll_"},"action":{"type":"block"}},
      {"trigger":{"url-filter":".*"},"action":{"type":"css-display-none","selector":"ytm-promoted-sparkles-web-renderer, ytm-promoted-video-renderer, ytm-companion-ad-renderer, ad-slot-renderer, ytm-ad-slot-renderer, ytm-display-ad-renderer, ytm-mealbar-promo-renderer, ytm-paid-content-overlay-renderer, ytm-statement-banner-renderer, .ytp-ad-overlay-container, #player-ads"}}
    ]
    """

    /// 페이지 안에서 실행되는 광고 제거 스크립트
    static let script = #"""
    (function () {
      if (window.__adFreeTube) return;
      window.__adFreeTube = true;

      // ── 1. 영상 정보(JSON)에서 광고 목록을 지워서 광고가 아예 예약되지 않게 함 ──
      const AD_KEYS = ['adPlacements', 'playerAds', 'adSlots', 'adBreakHeartbeatParams'];
      const prune = (o) => {
        if (!o || typeof o !== 'object') return o;
        AD_KEYS.forEach(k => { if (k in o) delete o[k]; });
        if (o.playerResponse) prune(o.playerResponse);
        if (Array.isArray(o)) o.forEach(prune);
        return o;
      };

      const origParse = JSON.parse;
      JSON.parse = function () {
        const r = origParse.apply(this, arguments);
        try { prune(r); } catch (e) {}
        return r;
      };

      const origJson = Response.prototype.json;
      Response.prototype.json = function () {
        return origJson.apply(this, arguments).then(r => { try { prune(r); } catch (e) {} return r; });
      };

      let _ipr;
      try {
        Object.defineProperty(window, 'ytInitialPlayerResponse', {
          configurable: true,
          get() { return _ipr; },
          set(v) { _ipr = prune(v); }
        });
      } catch (e) {}

      // ── 2. 그래도 광고가 재생되면 즉시 건너뛰기 ──
      let wasAd = false;
      const skipAds = () => {
        const player = document.querySelector('#movie_player, .html5-video-player');
        const video = document.querySelector('video');
        const isAd = !!player && (player.classList.contains('ad-showing') || player.classList.contains('ad-interrupting'));

        document.querySelectorAll(
          '.ytp-ad-skip-button, .ytp-ad-skip-button-modern, .ytp-skip-ad-button, .ytp-ad-skip-button-container button'
        ).forEach(b => b.click());

        if (video && isAd) {
          video.muted = true;
          video.playbackRate = 16;
          if (isFinite(video.duration) && video.duration > 0) video.currentTime = video.duration;
          wasAd = true;
        } else if (video && wasAd) {
          video.muted = false;
          video.playbackRate = 1;
          wasAd = false;
        }
      };
      setInterval(skipAds, 250);

      // ── 3. 앱을 나가도/화면을 꺼도 재생이 멈추지 않게 (백그라운드 재생) ──
      try {
        Object.defineProperty(document, 'hidden', { get: () => false, configurable: true });
        Object.defineProperty(document, 'visibilityState', { get: () => 'visible', configurable: true });
      } catch (e) {}
      ['visibilitychange', 'webkitvisibilitychange', 'pagehide', 'blur'].forEach(ev => {
        window.addEventListener(ev, e => e.stopImmediatePropagation(), true);
        document.addEventListener(ev, e => e.stopImmediatePropagation(), true);
      });
    })();
    """#
}
