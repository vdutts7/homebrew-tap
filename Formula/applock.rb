class Applock < Formula
  desc "Protect any macOS app behind Touch ID"
  homepage "https://github.com/vdutts7/applock-macos"
  url "https://github.com/vdutts7/applock-macos.git", tag: "v1.0.0"
  license "MIT"
  head "https://github.com/vdutts7/applock-macos.git", branch: "main"

  depends_on :macos

  def install
    # Use prebuilt binary (universal - Intel + Apple Silicon)
    bin.install "bin/applock"
  end

  test do
    assert_match "applock", shell_output("#{bin}/applock --version")
  end
end
