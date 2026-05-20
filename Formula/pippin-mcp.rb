class PippinMcp < Formula
  desc "Apple's on-device AI exposed as an MCP server"
  homepage "https://github.com/Bowl42/pippin-mcp"
  url "https://github.com/Bowl42/pippin-mcp/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "6d16ce2ca6012f674c773409afc60c1f4e9b216d9dc0e02925560fd24eb98d3e"
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

    # Default config file — installed only if absent, so user edits survive upgrades.
    conf = etc/"pippin-mcp/config.json"
    unless conf.exist?
      conf.dirname.mkpath
      conf.write <<~JSON
        {
          "host": "127.0.0.1",
          "port": 1996,
          "bindPublic": false,
          "maxBodyMb": 256,
          "authToken": null
        }
      JSON
    end
  end

  service do
    run [opt_bin/"pippin-mcp", "serve", "--transport", "http"]
    keep_alive true
    log_path var/"log/pippin-mcp.log"
    error_log_path var/"log/pippin-mcp.log"
    environment_variables PATH: std_service_path_env
  end

  def caveats
    <<~EOS
      Start the HTTP server:
        brew services start pippin-mcp

      Defaults bind 127.0.0.1:1996. To customize, edit:
        #{etc}/pippin-mcp/config.json

      To expose on your LAN, set in that file:
        "host": "0.0.0.0",
        "bindPublic": true

      Then apply:
        brew services restart pippin-mcp

      Inspect the live config and capability availability:
        pippin-mcp doctor

      Any LAN device can fetch a self-targeted skill from a running server:
        curl http://<this-mac>.local:1996/skill.md
    EOS
  end

  test do
    assert_match(/0\.\d+\.\d+/, shell_output("#{bin}/pippin-mcp --version"))
  end
end
