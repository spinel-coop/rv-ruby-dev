require File.expand_path("../Abstract/portable-formula", __dir__)

class PortableZlibAT131 < PortableFormula
  desc "General-purpose lossless data-compression library"
  homepage "https://zlib.net/"
  url "https://zlib.net/zlib-1.3.1.tar.gz"
  mirror "https://downloads.sourceforge.net/project/libpng/zlib/1.3.1/zlib-1.3.1.tar.gz"
  mirror "http://fresh-center.net/linux/misc/zlib-1.3.1.tar.gz"
  mirror "http://fresh-center.net/linux/misc/legacy/zlib-1.3.1.tar.gz"
  sha256 "9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23"
  license "Zlib"

  livecheck do
    formula "zlib"
  end

  def install
    system "./configure", "--static", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    testpath.join("zpipe.c").write(File.read(File.expand_path("../test/fixture/zpipe.c", __dir__)))
    system ENV.cc, "zpipe.c", "-I#{include}", "-L#{lib}", "-lz", "-o", "zpipe"

    touch "foo.txt"
    output = "./zpipe < foo.txt > foo.txt.z"
    system output
    assert File.exist?("foo.txt.z")
  end
end
