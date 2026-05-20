class PippinMcp < Formula
  desc "Apple's on-device AI exposed as an MCP server"
  homepage "https://github.com/Bowl42/pippin-mcp"
  url "https://github.com/Bowl42/pippin-mcp/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "6be621260f1aedd281354d96755e29d9177f121be27f81bc5fe960e2db84a8dc"
  license "MIT"
  head "https://github.com/Bowl42/pippin-mcp.git", branch: "main"

  depends_on xcode: ["16.0", :build]
  depends_on :macos

  def install
    system "swift", "build",
           "--disable-sandbox",
           "-c", "release",
           "--product", "pippin-mcp"
    bin.install ".build/release/pippin-mcp"
  end

  service do
    run [opt_bin/"pippin-mcp", "serve",
         "--transport", "http",
         "--host", "127.0.0.1",
         "--port", "1996"]
    keep_alive true
    log_path var/"log/pippin-mcp.log"
    error_log_path var/"log/pippin-mcp.log"
    environment_variables PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      Start the HTTP server (binds to 127.0.0.1:1996 by default):
        brew services start pippin-mcp

      To expose on your LAN, edit the generated plist:
        ~/Library/LaunchAgents/homebrew.mxcl.pippin-mcp.plist
      change --host to 0.0.0.0 and add --bind-public, then:
        brew services restart pippin-mcp

      Once running, any LAN device can fetch a self-targeted skill:
        curl http://<this-mac>.local:1996/skill.md
    EOS
  end

  test do
    assert_match(/0\.\d+\.\d+/, shell_output("#{bin}/pippin-mcp --version"))
  end
end
