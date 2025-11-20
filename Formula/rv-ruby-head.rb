require File.expand_path("../Abstract/rv-ruby-34", __dir__)

class RvRubyHead < RvRuby34
  head "https://github.com/ruby/ruby.git", branch: "master"

  depends_on "autoconf" => :build

  def install
    system "./autogen.sh"
    super
  end
end
