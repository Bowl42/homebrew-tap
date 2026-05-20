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

  test do
    assert_match(/0\.\d+\.\d+/, shell_output("#{bin}/pippin-mcp --version"))
  end
end
