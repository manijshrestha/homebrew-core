class Asciidoc < Formula
  desc "Formatter/translator for text files to numerous formats. Includes a2x"
  homepage "http://asciidoc.org/"
  # This release is listed as final on GitHub, but not listed on asciidoc.org.
  url "https://github.com/asciidoc/asciidoc/archive/8.6.10.tar.gz"
  sha256 "9e52f8578d891beaef25730a92a6e723596ddbd07bfe0d2a56486fcf63a0b983"
  head "https://github.com/asciidoc/asciidoc.git"

  bottle do
    cellar :any_skip_relocation
    sha256 "8210eb22d33a041cdeaa78b5a2e922e0c45b3140f68fad4e77e891df47973282" => :high_sierra
    sha256 "0f6e983fd2e62ddc4c13e0028e76f2e206a83f9a7371f4158c0c7997ab14634c" => :sierra
    sha256 "2e2ab0cd2462155296a05f8982b4d0c69b48db53ab26e49483c3fc116d955b67" => :el_capitan
    sha256 "e460dd7a372d465bdb2e932c02fb1339e96b7e28f47c8f750ae0546e56e517f9" => :yosemite
    sha256 "fe63d108847b9b197ee4f853b52faa8eb6d5c3990cc9919567d799f1b3dbd674" => :mavericks
  end

  depends_on "autoconf" => :build
  depends_on "docbook-xsl" => :build
  depends_on "docbook"

  def install
    ENV["XML_CATALOG_FILES"] = etc/"xml/catalog"

    system "autoconf"
    system "./configure", "--prefix=#{prefix}"

    inreplace "asciidoc.py", "#!/usr/bin/env python2", "#!/usr/bin/python"
    # otherwise macOS's xmllint bails out
    inreplace "Makefile", "-f manpage", "-f manpage -L"
    system "make", "install"
    system "make", "docs"
  end

  def caveats
    <<~EOS
      If you intend to process AsciiDoc files through an XML stage
      (such as a2x for manpage generation) you need to add something
      like:

        export XML_CATALOG_FILES=#{etc}/xml/catalog

      to your shell rc file so that xmllint can find AsciiDoc's
      catalog files.

      See `man 1 xmllint' for more.
    EOS
  end

  test do
    (testpath/"test.txt").write("== Hello World!")
    system "#{bin}/asciidoc", "-b", "html5", "-o", "test.html", "test.txt"
    assert_match %r{\<h2 id="_hello_world"\>Hello World!\</h2\>}, File.read("test.html")
  end
end
