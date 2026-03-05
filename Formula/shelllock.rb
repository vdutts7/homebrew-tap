class Shelllock < Formula
  desc "Protect any shell command behind Touch ID"
  homepage "https://github.com/vdutts7/shelllock-macos"
  url "https://github.com/vdutts7/shelllock-macos.git", tag: "v1.0.1"
  license "MIT"
  head "https://github.com/vdutts7/shelllock-macos.git", branch: "main"

  depends_on :macos

  def install
    system "make", "build-fast"
    bin.install "bin/shelllock"
  end

  test do
    assert_match "shelllock", shell_output("#{bin}/shelllock --version")
  end
end
