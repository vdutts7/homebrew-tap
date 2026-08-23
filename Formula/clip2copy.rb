class Clip2copy < Formula
  desc "Auto-copy macOS screenshots and screen recordings to clipboard"
  homepage "https://github.com/vdutts7/clip2copy"
  url "https://github.com/vdutts7/clip2copy.git", tag: "v1.4.1"
  license "MIT"
  head "https://github.com/vdutts7/clip2copy.git", branch: "main"

  depends_on :macos
  depends_on "fswatch"

  def install
    system "make", "build-fast"
    bin.install "bin/clip2copy"

    rm_f libexec/"clip2copy-watch"
    libexec.install "scripts/clip2copy-watch.sh" => "clip2copy-watch"
    chmod 0755, libexec/"clip2copy-watch"
    # launchd PATH is empty — bake brew paths at install time
    inreplace libexec/"clip2copy-watch",
              'FSWATCH="${CLIP2COPY_FSWATCH:-$(command -v fswatch 2>/dev/null)}"',
              "FSWATCH=\"${CLIP2COPY_FSWATCH:-#{Formula["fswatch"].opt_bin}/fswatch}\""
    inreplace libexec/"clip2copy-watch",
              'CLIP="${CLIP2COPY_BIN:-$(command -v clip2copy 2>/dev/null)}"',
              "CLIP=\"${CLIP2COPY_BIN:-#{bin}/clip2copy}\""
  end

  def post_install
    # Upgrade swaps bin/watch but launchd keeps the old process until restart.
    # Fresh install: no plist yet → skip. Wizard is never auto-run.
    plist = File.expand_path("~/Library/LaunchAgents/homebrew.mxcl.#{name}.plist")
    return unless File.exist?(plist)

    ohai "Restarting #{name} (existing LaunchAgent)"
    system HOMEBREW_BREW_FILE, "services", "restart", name
  rescue StandardError
    opoo "Could not restart #{name}; run: brew services restart #{name}"
  end

  service do
    run [opt_libexec/"clip2copy-watch"]
    keep_alive true
    log_path var/"log/clip2copy.log"
    error_log_path var/"log/clip2copy.err"
  end

  def caveats
    <<~EOS
      Fresh install:
        clip2copy setup
        brew services start clip2copy

      After brew upgrade (if service was already running):
        brew services restart clip2copy
        # post_install restarts automatically when the LaunchAgent plist exists
        # setup is optional — missing record-* keys default to on / sr / on

      CLI config anytime:
        clip2copy config show
        clip2copy config set location downloads
        clip2copy config set location desktop
        clip2copy config set location ~/Pictures/Screenshots
        clip2copy config set rename off
        clip2copy config set prefix ss
        clip2copy config set record-rename on
        clip2copy config set record-prefix sr
        clip2copy config set record-clipboard on
        clip2copy config set shadow on
        clip2copy config validate location ~/Desktop

      macOS factory default (when unset): ~/Desktop
      Note: location is shared by screenshots and screen recordings.
    EOS
  end

  test do
    assert_match "clip2copy", shell_output("#{bin}/clip2copy --version")
    assert_predicate bin/"clip2copy", :exist?
    assert_predicate libexec/"clip2copy-watch", :exist?
  end
end
